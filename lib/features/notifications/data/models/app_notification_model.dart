import '../../domain/entities/app_notification_entity.dart';

/// Notification Data Model with Supabase JSON serialization
class AppNotificationModel extends AppNotificationEntity {
  const AppNotificationModel({
    required super.id,
    super.showroomId,
    super.userId,
    super.targetRole,
    required super.category,
    super.priority = 'normal',
    required super.title,
    required super.message,
    super.actionRoute,
    super.data = const {},
    super.isRead = false,
    super.readAt,
    required super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as String,
      showroomId: json['showroom_id'] as String?,
      userId: json['user_id'] as String?,
      targetRole: json['target_role'] as String?,
      category: json['category'] as String? ?? 'system',
      priority: json['priority'] as String? ?? 'normal',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      actionRoute: json['action_route'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : {},
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'showroom_id': showroomId,
      'user_id': userId,
      'target_role': targetRole,
      'category': category,
      'priority': priority,
      'title': title,
      'message': message,
      'action_route': actionRoute,
      'data': data,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AppNotificationModel.fromEntity(AppNotificationEntity entity) {
    return AppNotificationModel(
      id: entity.id,
      showroomId: entity.showroomId,
      userId: entity.userId,
      targetRole: entity.targetRole,
      category: entity.category,
      priority: entity.priority,
      title: entity.title,
      message: entity.message,
      actionRoute: entity.actionRoute,
      data: entity.data,
      isRead: entity.isRead,
      readAt: entity.readAt,
      createdAt: entity.createdAt,
    );
  }
}
