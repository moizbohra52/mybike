import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';
import '../loaders/app_shimmer.dart';

/// Dealership KPI Metric Card
class AppStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? changePercentage;
  final bool isPositiveChange;
  final String? comparisonPeriod;
  final VoidCallback? onTap;
  final bool isLoading;

  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.changePercentage,
    this.isPositiveChange = true,
    this.comparisonPeriod = 'vs last month',
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AppShimmer.statCard();
    }

    final isDark = context.isDarkMode;
    final effectiveColor = iconColor ?? AppColors.primaryYellow;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: AppDimensions.borderWidth,
        ),
        boxShadow: isDark ? AppShadows.cardDark : AppShadows.cardLight,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.captionLarge.copyWith(
                          color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacing8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: effectiveColor.withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: AppDimensions.iconMd,
                          color: isDark
                              ? (effectiveColor == AppColors.primaryYellow ? AppColors.primaryYellowLight : effectiveColor)
                              : (effectiveColor == AppColors.primaryYellow ? AppColors.primaryYellowDark : effectiveColor),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing12),
                Text(
                  value,
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  ),
                ),
                if (changePercentage != null) ...[
                  const SizedBox(height: AppDimensions.spacing10),
                  Row(
                    children: [
                      Icon(
                        isPositiveChange ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: AppDimensions.iconSm,
                        color: isPositiveChange ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: AppDimensions.spacing4),
                      Text(
                        changePercentage!,
                        style: AppTypography.captionMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isPositiveChange ? AppColors.success : AppColors.error,
                        ),
                      ),
                      if (comparisonPeriod != null) ...[
                        const SizedBox(width: AppDimensions.spacing4),
                        Text(
                          comparisonPeriod!,
                          style: AppTypography.captionSmall.copyWith(
                            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
