import 'package:equatable/equatable.dart';

/// Notification Preferences Domain Entity
class NotificationPreferenceEntity extends Equatable {
  final String id;
  final String userId;
  final bool inventoryAlerts;
  final bool salesMilestones;
  final bool financeAlerts;
  final bool gstReminders;
  final bool systemAlerts;
  final bool pushEnabled;
  final bool soundEnabled;

  const NotificationPreferenceEntity({
    required this.id,
    required this.userId,
    this.inventoryAlerts = true,
    this.salesMilestones = true,
    this.financeAlerts = true,
    this.gstReminders = true,
    this.systemAlerts = true,
    this.pushEnabled = true,
    this.soundEnabled = true,
  });

  NotificationPreferenceEntity copyWith({
    String? id,
    String? userId,
    bool? inventoryAlerts,
    bool? salesMilestones,
    bool? financeAlerts,
    bool? gstReminders,
    bool? systemAlerts,
    bool? pushEnabled,
    bool? soundEnabled,
  }) {
    return NotificationPreferenceEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      inventoryAlerts: inventoryAlerts ?? this.inventoryAlerts,
      salesMilestones: salesMilestones ?? this.salesMilestones,
      financeAlerts: financeAlerts ?? this.financeAlerts,
      gstReminders: gstReminders ?? this.gstReminders,
      systemAlerts: systemAlerts ?? this.systemAlerts,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        inventoryAlerts,
        salesMilestones,
        financeAlerts,
        gstReminders,
        systemAlerts,
        pushEnabled,
        soundEnabled,
      ];
}
