import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/entities/notification_preference_entity.dart';
import 'notification_state.dart';

/// Notification Management Cubit
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _service;
  StreamSubscription<int>? _unreadSub;
  StreamSubscription<AppNotificationEntity>? _fcmSub;

  NotificationCubit({NotificationService? service})
      : _service = service ?? NotificationService.instance,
        super(const NotificationState()) {
    _initSubscriptions();
  }

  void _initSubscriptions() {
    _unreadSub = _service.unreadCountStream.listen((count) {
      if (!isClosed) {
        emit(state.copyWith(unreadCount: count));
      }
    });

    _fcmSub = _service.fcmProvider.onMessageReceived.listen((notification) {
      if (!isClosed) {
        final updatedList = [notification, ...state.notifications];
        emit(state.copyWith(
          notifications: updatedList,
          unreadCount: updatedList.where((n) => !n.isRead).length,
        ));
      }
    });
  }

  Future<void> loadNotifications({
    String? showroomId,
    String? userId,
    String? role,
  }) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    try {
      final list = await _service.fetchNotifications(
        showroomId: showroomId,
        userId: userId,
        role: role,
      );
      emit(state.copyWith(
        status: NotificationStatus.success,
        notifications: list,
        unreadCount: list.where((n) => !n.isRead).length,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void setCategoryFilter(String category) {
    emit(state.copyWith(activeCategory: category));
  }

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
    final updated = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true, readAt: DateTime.now());
      }
      return n;
    }).toList();

    emit(state.copyWith(
      notifications: updated,
      unreadCount: updated.where((n) => !n.isRead).length,
    ));
  }

  Future<void> markAllAsRead({String? userId}) async {
    await _service.markAllAsRead(userId: userId);
    final now = DateTime.now();
    final updated = state.notifications.map((n) {
      return n.copyWith(isRead: true, readAt: now);
    }).toList();

    emit(state.copyWith(
      notifications: updated,
      unreadCount: 0,
    ));
  }

  Future<void> deleteNotification(String id) async {
    await _service.deleteNotification(id);
    final updated = state.notifications.where((n) => n.id != id).toList();
    emit(state.copyWith(
      notifications: updated,
      unreadCount: updated.where((n) => !n.isRead).length,
    ));
  }

  Future<void> clearReadNotifications() async {
    await _service.clearReadNotifications();
    final updated = state.notifications.where((n) => !n.isRead).toList();
    emit(state.copyWith(
      notifications: updated,
      unreadCount: updated.length,
    ));
  }

  Future<void> loadPreferences(String userId) async {
    final prefs = await _service.getPreferences(userId);
    emit(state.copyWith(preferences: prefs));
  }

  Future<void> updatePreferences(NotificationPreferenceEntity preferences) async {
    await _service.updatePreferences(preferences);
    emit(state.copyWith(preferences: preferences));
  }

  @override
  Future<void> close() {
    _unreadSub?.cancel();
    _fcmSub?.cancel();
    return super.close();
  }
}
