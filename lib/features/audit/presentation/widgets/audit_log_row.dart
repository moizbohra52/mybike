import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/audit_log_entity.dart';

class AuditLogRow extends StatelessWidget {
  final AuditLogEntity log;
  final VoidCallback onViewDiff;

  const AuditLogRow({
    super.key,
    required this.log,
    required this.onViewDiff,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: log.isCritical
              ? AppColors.error.withValues(alpha: 0.5)
              : (log.isWarning
                  ? AppColors.warning.withValues(alpha: 0.4)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
          width: log.isCritical ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          onTap: onViewDiff,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Action Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: log.actionColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Icon(log.actionIcon, color: log.actionColor, size: 20),
                ),
                const SizedBox(width: 12),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Action Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: log.actionColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: log.actionColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              log.action,
                              style: TextStyle(
                                color: log.actionColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Module Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              log.moduleLabel,
                              style: AppTypography.captionSmall.copyWith(
                                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (log.isCritical) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'CRITICAL',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),

                          // Timestamp
                          Text(
                            log.relativeTime,
                            style: AppTypography.captionMedium.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Record Title & ID
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              log.recordTitle ?? log.recordId,
                              style: AppTypography.titleSmall.copyWith(
                                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // User & Showroom Footnote
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 13,
                            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            log.userName ?? 'System',
                            style: AppTypography.captionSmall.copyWith(
                              color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (log.showroomName != null) ...[
                            const SizedBox(width: 8),
                            Text('•', style: TextStyle(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.storefront_outlined,
                              size: 13,
                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              log.showroomName!,
                              style: AppTypography.captionSmall.copyWith(
                                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (log.hasDiff)
                            Text(
                              'View Diff →',
                              style: TextStyle(
                                color: AppColors.primaryYellowDark,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
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
