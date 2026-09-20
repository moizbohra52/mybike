import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/app_notification_entity.dart';

/// Notification Item Card Widget with Action Deep Links
class NotificationItemCard extends StatelessWidget {
  final AppNotificationEntity notification;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const NotificationItemCard({
    super.key,
    required this.notification,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: isDark
            ? (isUnread ? AppColors.darkCard : AppColors.darkSurface)
            : (isUnread ? AppColors.primaryYellow.withValues(alpha: 0.04) : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isUnread
              ? (notification.isUrgent
                  ? AppColors.error.withValues(alpha: 0.5)
                  : AppColors.primaryYellow.withValues(alpha: 0.5))
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isUnread ? 1.5 : 1.0,
        ),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: (notification.isUrgent ? AppColors.error : AppColors.primaryYellow)
                      .withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          onTap: () {
            if (isUnread) onMarkRead();
            if (notification.actionRoute != null && notification.actionRoute!.isNotEmpty) {
              context.push(notification.actionRoute!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Icon with Priority Ring
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: notification.priorityColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: notification.priorityColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    notification.categoryIcon,
                    color: notification.priorityColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing16),

                // Content Block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Category, Priority Badge, Time
                      Row(
                        children: [
                          // Category Label
                          Text(
                            notification.categoryLabel.toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Priority Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: notification.priorityColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            ),
                            child: Text(
                              notification.priorityLabel,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: notification.priorityColor,
                              ),
                            ),
                          ),
                          const Spacer(),

                          // Relative Time
                          Text(
                            notification.relativeTime,
                            style: AppTypography.captionSmall.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                            ),
                          ),

                          // Unread Blue/Yellow Dot
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: notification.isUrgent
                                    ? AppColors.error
                                    : AppColors.primaryYellowDark,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Notification Title
                      Text(
                        notification.title,
                        style: AppTypography.headlineSmall.copyWith(
                          fontSize: 14,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Notification Body Message
                      Text(
                        notification.message,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Action Button & Dismiss Toolbar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (notification.actionRoute != null &&
                              notification.actionRoute!.isNotEmpty)
                            FilledButton.tonalIcon(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () {
                                if (isUnread) onMarkRead();
                                context.push(notification.actionRoute!);
                              },
                              icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                              label: const Text('View Record'),
                            )
                          else
                            const SizedBox.shrink(),

                          Row(
                            children: [
                              if (isUnread)
                                IconButton(
                                  icon: const Icon(Icons.mark_email_read_outlined, size: 18),
                                  tooltip: 'Mark as read',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: onMarkRead,
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                tooltip: 'Dismiss',
                                visualDensity: VisualDensity.compact,
                                onPressed: onDelete,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
