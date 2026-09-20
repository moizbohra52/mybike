import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/fcm_notification_provider.dart';
import 'package:mybike/core/services/notification_service.dart';
import 'package:mybike/features/notifications/data/models/app_notification_model.dart';
import 'package:mybike/features/notifications/data/models/notification_preference_model.dart';
import 'package:mybike/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:mybike/features/notifications/domain/entities/notification_preference_entity.dart';
import 'package:mybike/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:mybike/features/notifications/presentation/cubit/notification_state.dart';

void main() {
  group('Phase 18 — Notification Domain & Model Tests', () {
    test('AppNotificationModel serializes and deserializes JSON correctly', () {
      final json = {
        'id': 'notif-101',
        'showroom_id': 'show-mumbai',
        'user_id': 'user-007',
        'target_role': 'inventory_manager',
        'category': 'inventory',
        'priority': 'urgent',
        'title': 'Critically Low Stock: Spark Plugs',
        'message': 'Spark plug inventory dropped to 2 units.',
        'action_route': '/inventory',
        'data': {'sku': 'SP-NGK-01', 'stock': 2},
        'is_read': false,
        'read_at': null,
        'created_at': '2026-03-15T10:30:00.000Z',
      };

      final model = AppNotificationModel.fromJson(json);
      expect(model.id, 'notif-101');
      expect(model.showroomId, 'show-mumbai');
      expect(model.category, 'inventory');
      expect(model.priority, 'urgent');
      expect(model.isUrgent, isTrue);
      expect(model.priorityLabel, 'URGENT');
      expect(model.categoryLabel, 'Inventory & Stock');
      expect(model.actionRoute, '/inventory');

      final serialized = model.toJson();
      expect(serialized['id'], 'notif-101');
      expect(serialized['category'], 'inventory');
      expect(serialized['priority'], 'urgent');
      expect(serialized['data']['sku'], 'SP-NGK-01');
    });

    test('NotificationPreferenceModel serializes and deserializes correctly', () {
      final json = {
        'id': 'pref-01',
        'user_id': 'usr-admin',
        'inventory_alerts': true,
        'sales_milestones': true,
        'finance_alerts': false,
        'gst_reminders': true,
        'system_alerts': true,
        'push_enabled': true,
        'sound_enabled': false,
      };

      final model = NotificationPreferenceModel.fromJson(json);
      expect(model.userId, 'usr-admin');
      expect(model.financeAlerts, isFalse);
      expect(model.soundEnabled, isFalse);
      expect(model.inventoryAlerts, isTrue);

      final serialized = model.toJson();
      expect(serialized['finance_alerts'], isFalse);
      expect(serialized['sound_enabled'], isFalse);
    });
  });

  group('Phase 18 — FCM Notification Provider Tests', () {
    late FcmNotificationProvider fcmProvider;

    setUp(() {
      fcmProvider = FcmNotificationProvider();
    });

    tearDown(() {
      fcmProvider.dispose();
    });

    test('initializes and requests unique platform device token', () async {
      final token = await fcmProvider.requestToken(userId: 'user-01');
      expect(token, isNotNull);
      expect(token, contains('fcm_'));
      expect(fcmProvider.currentToken, token);
    });

    test('subscribes and unsubscribes from operational notification topics', () async {
      await fcmProvider.subscribeToTopic('showroom_mumbai');
      await fcmProvider.subscribeToTopic('role_inventory_manager');

      expect(fcmProvider.subscribedTopics, contains('showroom_mumbai'));
      expect(fcmProvider.subscribedTopics, contains('role_inventory_manager'));

      await fcmProvider.unsubscribeFromTopic('showroom_mumbai');
      expect(fcmProvider.subscribedTopics, isNot(contains('showroom_mumbai')));
      expect(fcmProvider.subscribedTopics, contains('role_inventory_manager'));
    });

    test('dispatches incoming push messages to stream listener', () async {
      final notification = AppNotificationEntity(
        id: 'push-test-1',
        category: 'sales',
        priority: 'high',
        title: 'New Vehicle Invoice Created',
        message: 'Invoice #IND-MUM-INV-00101 issued.',
        createdAt: DateTime.now(),
      );

      expectLater(
        fcmProvider.onMessageReceived,
        emits(notification),
      );

      fcmProvider.dispatchIncomingMessage(notification);
    });
  });

  group('Phase 18 — NotificationService Alert Engine Tests', () {
    late NotificationService service;

    setUp(() {
      service = NotificationService.instance;
    });

    test('fetches notifications with category and unread filters', () async {
      final all = await service.fetchNotifications();
      expect(all, isNotEmpty);

      final unread = await service.fetchNotifications(unreadOnly: true);
      for (final n in unread) {
        expect(n.isRead, isFalse);
      }

      final inventoryOnly = await service.fetchNotifications(category: 'inventory');
      for (final n in inventoryOnly) {
        expect(n.category, 'inventory');
      }
    });

    test('marks single notification as read and updates unread count', () async {
      final list = await service.fetchNotifications();
      final target = list.firstWhere((n) => !n.isRead);

      final initialUnread = service.unreadCount;
      await service.markAsRead(target.id);

      expect(service.unreadCount, equals(initialUnread - 1));

      final updated = await service.fetchNotifications();
      final check = updated.firstWhere((n) => n.id == target.id);
      expect(check.isRead, isTrue);
      expect(check.readAt, isNotNull);
    });

    test('triggers Low Stock Warning with urgent priority if out of stock', () async {
      final notifZero = await service.triggerLowStockAlert(
        showroomId: 'show-01',
        sku: 'OIL-FILTER-01',
        itemName: 'Engine Oil Filter Cartridge',
        currentQty: 0,
        reorderLevel: 5,
      );

      expect(notifZero.category, 'inventory');
      expect(notifZero.priority, 'urgent');
      expect(notifZero.actionRoute, '/inventory');

      final notifLow = await service.triggerLowStockAlert(
        showroomId: 'show-01',
        sku: 'BRAKE-PAD-01',
        itemName: 'Ceramic Disc Brake Pad',
        currentQty: 2,
        reorderLevel: 5,
      );

      expect(notifLow.category, 'inventory');
      expect(notifLow.priority, 'high');
    });

    test('triggers Booking Confirmed alert', () async {
      final notif = await service.triggerBookingConfirmedAlert(
        showroomId: 'show-mumbai',
        bookingId: 'BK-2026-099',
        customerName: 'Pooja Sharma',
        vehicleModel: 'Activa 6G DLX',
        advancePaid: 5000,
      );

      expect(notif.category, 'booking');
      expect(notif.title, contains('Activa 6G DLX'));
      expect(notif.message, contains('Pooja Sharma'));
      expect(notif.actionRoute, '/bookings');
    });

    test('triggers Overdue Receivable alert', () async {
      final notif = await service.triggerOverdueReceivableAlert(
        showroomId: 'show-mumbai',
        customerName: 'Ajay Patel',
        invoiceNumber: 'IND-MUM-INV-00088',
        overdueAmount: 45000,
        overdueDays: 40,
      );

      expect(notif.category, 'finance');
      expect(notif.priority, 'urgent'); // > 30 days is urgent
      expect(notif.actionRoute, '/finance/outstandings');
    });

    test('triggers Statutory GST Filing reminder', () async {
      final notif = await service.triggerGstFilingReminder(
        period: 'March 2026',
        returnType: 'GSTR-3B',
        dueDate: '20-April-2026',
      );

      expect(notif.category, 'gst');
      expect(notif.priority, 'urgent');
      expect(notif.actionRoute, '/gst/gstr-3b');
    });

    test('saves and retrieves user notification preferences', () async {
      const prefs = NotificationPreferenceEntity(
        id: 'pref-usr-1',
        userId: 'usr-1',
        inventoryAlerts: true,
        salesMilestones: false,
        financeAlerts: true,
        pushEnabled: false,
      );

      await service.updatePreferences(prefs);
      final retrieved = await service.getPreferences('usr-1');

      expect(retrieved.userId, 'usr-1');
      expect(retrieved.salesMilestones, isFalse);
      expect(retrieved.pushEnabled, isFalse);
      expect(retrieved.financeAlerts, isTrue);
    });

    test('markAllAsRead clears all unread notifications', () async {
      await service.markAllAsRead();
      expect(service.unreadCount, equals(0));
    });
  });

  group('Phase 18 — NotificationCubit State Management Tests', () {
    late NotificationCubit cubit;

    setUp(() {
      cubit = NotificationCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has empty list and unread count', () {
      expect(cubit.state.status, NotificationStatus.initial);
      expect(cubit.state.activeCategory, 'all');
    });

    test('loadNotifications loads notifications and sets unreadCount', () async {
      await cubit.loadNotifications();
      expect(cubit.state.status, NotificationStatus.success);
      expect(cubit.state.notifications, isNotEmpty);
    });

    test('filtering by category and priority works as expected', () async {
      await cubit.loadNotifications();

      cubit.setCategoryFilter('inventory');
      expect(cubit.state.activeCategory, 'inventory');
      for (final n in cubit.state.filteredNotifications) {
        expect(n.category, 'inventory');
      }

      cubit.setCategoryFilter('urgent');
      expect(cubit.state.activeCategory, 'urgent');
      for (final n in cubit.state.filteredNotifications) {
        expect(n.isUrgent || n.isHighPriority, isTrue);
      }

      cubit.setCategoryFilter('all');
      expect(cubit.state.filteredNotifications.length, equals(cubit.state.notifications.length));
    });

    test('markAsRead updates item in cubit state', () async {
      await cubit.loadNotifications();
      final item = cubit.state.notifications.first;

      await cubit.markAsRead(item.id);
      final updated = cubit.state.notifications.firstWhere((n) => n.id == item.id);
      expect(updated.isRead, isTrue);
    });

    test('deleteNotification removes item from cubit state', () async {
      await cubit.loadNotifications();
      final initialCount = cubit.state.notifications.length;
      final target = cubit.state.notifications.first;

      await cubit.deleteNotification(target.id);
      expect(cubit.state.notifications.length, equals(initialCount - 1));
      expect(cubit.state.notifications.any((n) => n.id == target.id), isFalse);
    });
  });
}
