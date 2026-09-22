import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';

/// Standard Section & Dashboard Container Card
class AppDashboardCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? headerAction;
  final Widget child;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final double? height;

  const AppDashboardCard({
    super.key,
    required this.title,
    this.subtitle,
    this.headerAction,
    required this.child,
    this.footer,
    this.padding = const EdgeInsets.all(AppDimensions.spacing20),
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: AppDimensions.borderWidth,
        ),
        boxShadow: isDark ? AppShadows.cardDark : AppShadows.cardLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacing20,
              AppDimensions.spacing16,
              AppDimensions.spacing16,
              AppDimensions.spacing12,
            ),
            child: context.isMobile && headerAction != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppDimensions.spacing2),
                        Text(
                          subtitle!,
                          style: AppTypography.captionMedium.copyWith(
                            color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppDimensions.spacing12),
                      headerAction!,
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: AppDimensions.spacing2),
                              Text(
                                subtitle!,
                                style: AppTypography.captionMedium.copyWith(
                                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      ?headerAction,
                    ],
                  ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
          // Content
          Padding(
            padding: padding,
            child: child,
          ),
          // Optional Footer
          if (footer != null) ...[
            Divider(
              height: 1,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing20,
                vertical: AppDimensions.spacing12,
              ),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}
