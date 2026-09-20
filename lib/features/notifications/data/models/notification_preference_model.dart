import '../../domain/entities/notification_preference_entity.dart';

/// Notification Preferences Data Model with Supabase JSON serialization
class NotificationPreferenceModel extends NotificationPreferenceEntity {
  const NotificationPreferenceModel({
    required super.id,
    required super.userId,
    super.inventoryAlerts = true,
    super.salesMilestones = true,
    super.financeAlerts = true,
    super.gstReminders = true,
    super.systemAlerts = true,
    super.pushEnabled = true,
    super.soundEnabled = true,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      inventoryAlerts: json['inventory_alerts'] as bool? ?? true,
      salesMilestones: json['sales_milestones'] as bool? ?? true,
      financeAlerts: json['finance_alerts'] as bool? ?? true,
      gstReminders: json['gst_reminders'] as bool? ?? true,
      systemAlerts: json['system_alerts'] as bool? ?? true,
      pushEnabled: json['push_enabled'] as bool? ?? true,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'inventory_alerts': inventoryAlerts,
      'sales_milestones': salesMilestones,
      'finance_alerts': financeAlerts,
      'gst_reminders': gstReminders,
      'system_alerts': systemAlerts,
      'push_enabled': pushEnabled,
      'sound_enabled': soundEnabled,
    };
  }

  factory NotificationPreferenceModel.fromEntity(NotificationPreferenceEntity entity) {
    return NotificationPreferenceModel(
      id: entity.id,
      userId: entity.userId,
      inventoryAlerts: entity.inventoryAlerts,
      salesMilestones: entity.salesMilestones,
      financeAlerts: entity.financeAlerts,
      gstReminders: entity.gstReminders,
      systemAlerts: entity.systemAlerts,
      pushEnabled: entity.pushEnabled,
      soundEnabled: entity.soundEnabled,
    );
  }
}
