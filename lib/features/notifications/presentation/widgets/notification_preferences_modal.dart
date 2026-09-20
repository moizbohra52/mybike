import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/notification_preference_entity.dart';

/// Modal Bottom Sheet for Customizing Dealership Alert Preferences
class NotificationPreferencesModal extends StatefulWidget {
  final NotificationPreferenceEntity initialPreferences;
  final ValueChanged<NotificationPreferenceEntity> onSave;

  const NotificationPreferencesModal({
    super.key,
    required this.initialPreferences,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required NotificationPreferenceEntity initialPreferences,
    required ValueChanged<NotificationPreferenceEntity> onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationPreferencesModal(
        initialPreferences: initialPreferences,
        onSave: onSave,
      ),
    );
  }

  @override
  State<NotificationPreferencesModal> createState() => _NotificationPreferencesModalState();
}

class _NotificationPreferencesModalState extends State<NotificationPreferencesModal> {
  late bool _inventoryAlerts;
  late bool _salesMilestones;
  late bool _financeAlerts;
  late bool _gstReminders;
  late bool _systemAlerts;
  late bool _pushEnabled;
  late bool _soundEnabled;

  @override
  void initState() {
    super.initState();
    _inventoryAlerts = widget.initialPreferences.inventoryAlerts;
    _salesMilestones = widget.initialPreferences.salesMilestones;
    _financeAlerts = widget.initialPreferences.financeAlerts;
    _gstReminders = widget.initialPreferences.gstReminders;
    _systemAlerts = widget.initialPreferences.systemAlerts;
    _pushEnabled = widget.initialPreferences.pushEnabled;
    _soundEnabled = widget.initialPreferences.soundEnabled;
  }

  void _save() {
    final updated = widget.initialPreferences.copyWith(
      inventoryAlerts: _inventoryAlerts,
      salesMilestones: _salesMilestones,
      financeAlerts: _financeAlerts,
      gstReminders: _gstReminders,
      systemAlerts: _systemAlerts,
      pushEnabled: _pushEnabled,
      soundEnabled: _soundEnabled,
    );
    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notification Preferences',
                        style: AppTypography.headlineMedium.copyWith(
                          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Configure alert channels and operational subscriptions',
                        style: AppTypography.captionMedium.copyWith(
                          color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),
              const Divider(),
              const SizedBox(height: AppDimensions.spacing8),

              // General Alert Channels
              Text(
                'DELIVERY CHANNELS',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryYellowDark,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildSwitchRow(
                title: 'Push Notifications (FCM)',
                subtitle: 'Receive real-time push alerts on mobile and desktop',
                value: _pushEnabled,
                onChanged: (v) => setState(() => _pushEnabled = v),
              ),
              _buildSwitchRow(
                title: 'In-App Sound & Chimes',
                subtitle: 'Play audio chimes when urgent alerts arrive',
                value: _soundEnabled,
                onChanged: (v) => setState(() => _soundEnabled = v),
              ),

              const SizedBox(height: AppDimensions.spacing16),
              Text(
                'OPERATIONAL CATEGORIES',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryYellowDark,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              _buildSwitchRow(
                title: 'Inventory & Stock Alerts',
                subtitle: 'Low stock thresholds, battery reorder alerts, transfers',
                value: _inventoryAlerts,
                onChanged: (v) => setState(() => _inventoryAlerts = v),
              ),
              _buildSwitchRow(
                title: 'Sales & Customer Bookings',
                subtitle: 'New booking confirmations, vehicle allocations, invoices',
                value: _salesMilestones,
                onChanged: (v) => setState(() => _salesMilestones = v),
              ),
              _buildSwitchRow(
                title: 'Finance & Overdue Receivables',
                subtitle: 'Customer payment overdue, loan disbursement receipts',
                value: _financeAlerts,
                onChanged: (v) => setState(() => _financeAlerts = v),
              ),
              _buildSwitchRow(
                title: 'GST & Statutory Reminders',
                subtitle: 'Monthly GSTR-1 and GSTR-3B filing deadlines',
                value: _gstReminders,
                onChanged: (v) => setState(() => _gstReminders = v),
              ),
              _buildSwitchRow(
                title: 'System & Security Alerts',
                subtitle: 'Role changes, new device logins, audit warnings',
                value: _systemAlerts,
                onChanged: (v) => setState(() => _systemAlerts = v),
              ),

              const SizedBox(height: AppDimensions.spacing20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save Preferences'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryYellowDark,
          ),
        ],
      ),
    );
  }
}
