import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';

/// Form Section Container for Grouped ERP Forms
class AppFormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool isCard;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const AppFormSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.isCard = true,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: AppDimensions.spacing4),
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
        ?trailing,
      ],
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        const SizedBox(height: AppDimensions.spacing20),
        ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacing16),
              child: child,
            )),
      ],
    );

    if (!isCard) {
      return Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: AppDimensions.spacing16),
        child: content,
      );
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.spacing20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: AppDimensions.borderWidth,
        ),
      ),
      child: content,
    );
  }
}
