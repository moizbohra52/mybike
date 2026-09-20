import 'package:equatable/equatable.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/entities/notification_preference_entity.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<AppNotificationEntity> notifications;
  final int unreadCount;
  final String activeCategory;
  final NotificationPreferenceEntity? preferences;
  final String? errorMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.activeCategory = 'all',
    this.preferences,
    this.errorMessage,
  });

  List<AppNotificationEntity> get filteredNotifications {
    if (activeCategory == 'all') {
      return notifications;
    } else if (activeCategory == 'unread') {
      return notifications.where((n) => !n.isRead).toList();
    } else if (activeCategory == 'urgent') {
      return notifications.where((n) => n.isUrgent || n.isHighPriority).toList();
    } else {
      return notifications.where((n) => n.category == activeCategory).toList();
    }
  }

  NotificationState copyWith({
    NotificationStatus? status,
    List<AppNotificationEntity>? notifications,
    int? unreadCount,
    String? activeCategory,
    NotificationPreferenceEntity? preferences,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      activeCategory: activeCategory ?? this.activeCategory,
      preferences: preferences ?? this.preferences,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        unreadCount,
        activeCategory,
        preferences,
        errorMessage,
      ];
}
