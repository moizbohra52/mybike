import 'dart:async';
import '../../features/notifications/data/models/app_notification_model.dart';
import '../../features/notifications/domain/entities/app_notification_entity.dart';
import '../../features/notifications/domain/entities/notification_preference_entity.dart';
import 'fcm_notification_provider.dart';
import 'supabase_service.dart';

/// Central Notification & Alert Management Service
class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  factory NotificationService({FcmNotificationProvider? fcmProvider}) {
    if (fcmProvider != null) {
      instance._fcmProvider = fcmProvider;
    }
    return instance;
  }

  NotificationService._internal() {
    _initSeededNotifications();
    _unreadCountController = StreamController<int>.broadcast();
    _unreadCountController.add(unreadCount);
  }

  FcmNotificationProvider _fcmProvider = FcmNotificationProvider();
  FcmNotificationProvider get fcmProvider => _fcmProvider;

  late final StreamController<int> _unreadCountController;
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  final List<AppNotificationEntity> _notifications = [];
  final Map<String, NotificationPreferenceEntity> _preferences = {};

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _notifyUnreadCountChanged() {
    if (!_unreadCountController.isClosed) {
      _unreadCountController.add(unreadCount);
    }
  }

  // ─────────────────────────────────────────────────────────
  // Fetch & Query Notifications
  // ─────────────────────────────────────────────────────────

  Future<List<AppNotificationEntity>> fetchNotifications({
    String? showroomId,
    String? userId,
    String? role,
    String? category,
    bool? unreadOnly,
  }) async {
    await SupabaseService.devLatency();
    List<AppNotificationEntity> results = List.from(_notifications);

    if (showroomId != null) {
      results = results.where((n) => n.showroomId == null || n.showroomId == showroomId).toList();
    }

    if (userId != null) {
      results = results.where((n) => n.userId == null || n.userId == userId).toList();
    }

    if (role != null) {
      results = results.where((n) => n.targetRole == null || n.targetRole == role).toList();
    }

    if (category != null && category != 'all') {
      results = results.where((n) => n.category == category).toList();
    }

    if (unreadOnly == true) {
      results = results.where((n) => !n.isRead).toList();
    }

    // Sort newest first
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  // ─────────────────────────────────────────────────────────
  // Read Status & Deletion
  // ─────────────────────────────────────────────────────────

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
      _notifyUnreadCountChanged();
    }
  }

  Future<void> markAllAsRead({String? userId, String? showroomId}) async {
    final now = DateTime.now();
    for (int i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      if (!n.isRead) {
        if (userId == null || n.userId == null || n.userId == userId) {
          _notifications[i] = n.copyWith(isRead: true, readAt: now);
        }
      }
    }
    _notifyUnreadCountChanged();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notifyUnreadCountChanged();
  }

  Future<void> clearReadNotifications() async {
    _notifications.removeWhere((n) => n.isRead);
    _notifyUnreadCountChanged();
  }

  // ─────────────────────────────────────────────────────────
  // Alert Dispatchers & Automation
  // ─────────────────────────────────────────────────────────

  Future<AppNotificationEntity> sendNotification(AppNotificationEntity notification) async {
    _notifications.insert(0, notification);
    _notifyUnreadCountChanged();
    _fcmProvider.dispatchIncomingMessage(notification);
    return notification;
  }

  Future<AppNotificationEntity> triggerLowStockAlert({
    required String? showroomId,
    required String sku,
    required String itemName,
    required int currentQty,
    required int reorderLevel,
  }) async {
    final notification = AppNotificationEntity(
      id: 'notif_stock_${DateTime.now().millisecondsSinceEpoch}',
      showroomId: showroomId,
      targetRole: 'inventory_manager',
      category: 'inventory',
      priority: currentQty == 0 ? 'urgent' : 'high',
      title: 'Low Stock Alert: $itemName',
      message: 'Available inventory for $itemName ($sku) is $currentQty units, below minimum threshold ($reorderLevel). Restock required.',
      actionRoute: '/inventory',
      data: {
        'sku': sku,
        'item_name': itemName,
        'current_stock': currentQty,
        'reorder_level': reorderLevel,
      },
      createdAt: DateTime.now(),
    );

    return sendNotification(notification);
  }

  Future<AppNotificationEntity> triggerBookingConfirmedAlert({
    required String? showroomId,
    required String bookingId,
    required String customerName,
    required String vehicleModel,
    required double advancePaid,
  }) async {
    final notification = AppNotificationEntity(
      id: 'notif_booking_${DateTime.now().millisecondsSinceEpoch}',
      showroomId: showroomId,
      targetRole: 'sales_executive',
      category: 'booking',
      priority: 'high',
      title: 'New Booking: $vehicleModel',
      message: 'Booking #$bookingId confirmed for $customerName with advance of ₹ ${advancePaid.toStringAsFixed(0)}.',
      actionRoute: '/bookings',
      data: {
        'booking_id': bookingId,
        'customer_name': customerName,
        'vehicle_model': vehicleModel,
        'advance_paid': advancePaid,
      },
      createdAt: DateTime.now(),
    );

    return sendNotification(notification);
  }

  Future<AppNotificationEntity> triggerOverdueReceivableAlert({
    required String? showroomId,
    required String customerName,
    required String invoiceNumber,
    required double overdueAmount,
    required int overdueDays,
  }) async {
    final notification = AppNotificationEntity(
      id: 'notif_finance_${DateTime.now().millisecondsSinceEpoch}',
      showroomId: showroomId,
      targetRole: 'accountant',
      category: 'finance',
      priority: overdueDays > 30 ? 'urgent' : 'high',
      title: 'Payment Overdue: $customerName',
      message: 'Invoice $invoiceNumber has an outstanding amount of ₹ ${overdueAmount.toStringAsFixed(0)} overdue by $overdueDays days.',
      actionRoute: '/finance/outstandings',
      data: {
        'customer_name': customerName,
        'invoice_number': invoiceNumber,
        'overdue_amount': overdueAmount,
        'overdue_days': overdueDays,
      },
      createdAt: DateTime.now(),
    );

    return sendNotification(notification);
  }

  Future<AppNotificationEntity> triggerGstFilingReminder({
    required String period,
    required String returnType,
    required String dueDate,
  }) async {
    final notification = AppNotificationEntity(
      id: 'notif_gst_${DateTime.now().millisecondsSinceEpoch}',
      targetRole: 'accountant',
      category: 'gst',
      priority: 'urgent',
      title: 'Statutory GST Reminder: Form $returnType',
      message: 'Form $returnType for period $period is due by $dueDate. Please ensure Output and ITC reconciliations are complete.',
      actionRoute: returnType == 'GSTR-1' ? '/gst/gstr-1' : '/gst/gstr-3b',
      data: {
        'period': period,
        'return_type': returnType,
        'due_date': dueDate,
      },
      createdAt: DateTime.now(),
    );

    return sendNotification(notification);
  }

  // ─────────────────────────────────────────────────────────
  // User Preferences
  // ─────────────────────────────────────────────────────────

  Future<NotificationPreferenceEntity> getPreferences(String userId) async {
    return _preferences[userId] ??
        NotificationPreferenceEntity(
          id: 'pref_$userId',
          userId: userId,
        );
  }

  Future<void> updatePreferences(NotificationPreferenceEntity preferences) async {
    _preferences[preferences.userId] = preferences;
  }

  // ─────────────────────────────────────────────────────────
  // Pre-Seeded Development Alerts
  // ─────────────────────────────────────────────────────────

  void _initSeededNotifications() {
    _notifications.addAll([
      AppNotificationModel(
        id: 'notif-seed-01',
        category: 'inventory',
        priority: 'urgent',
        title: 'Low Stock Warning: EV Battery Pack 72V',
        message: 'Stock for Lithium Iron Phosphate 72V battery pack is at 1 unit (reorder threshold: 3). Restock required.',
        actionRoute: '/inventory',
        data: const {'sku': 'BAT-72V-LFP', 'current_stock': 1, 'reorder_level': 3},
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      AppNotificationModel(
        id: 'notif-seed-02',
        category: 'booking',
        priority: 'high',
        title: 'New Customer Booking Allocated',
        message: 'Booking #BK-2026-0042 for Rahul Verma (Speedster 250 DLX) has been confirmed with Rs. 10,000 token advance.',
        actionRoute: '/bookings',
        data: const {'booking_id': 'BK-2026-0042', 'customer': 'Rahul Verma', 'advance': 10000},
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      AppNotificationModel(
        id: 'notif-seed-03',
        category: 'finance',
        priority: 'high',
        title: 'Overdue Receivables Alert',
        message: 'Customer Moiz Bohra has an outstanding balance of Rs. 20,000 against Tax Invoice IND-MUM-INV-00101 exceeding 15 days.',
        actionRoute: '/finance/outstandings',
        data: const {'invoice_number': 'IND-MUM-INV-00101', 'balance': 20000, 'overdue_days': 15},
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotificationModel(
        id: 'notif-seed-04',
        category: 'transfer',
        priority: 'normal',
        title: 'Stock Transfer Dispatched',
        message: 'Stock Transfer #TR-0089 with 2 units of Activa 6G DLX dispatched from Central Depot to Mumbai Showroom.',
        actionRoute: '/inventory/transfer',
        data: const {'transfer_id': 'TR-0089', 'units': 2},
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(hours: 1)),
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      AppNotificationModel(
        id: 'notif-seed-05',
        category: 'gst',
        priority: 'urgent',
        title: 'Statutory Reminder: GSTR-3B Monthly Return Due',
        message: 'GSTR-3B return filing deadline for the prior tax period is approaching on the 20th. Ensure Output/ITC reconciliation.',
        actionRoute: '/gst/gstr-3b',
        data: const {'period': 'Feb-2026', 'due_date': '20-Mar-2026'},
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }
}
