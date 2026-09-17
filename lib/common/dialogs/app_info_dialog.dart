import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';

/// Informational / Alert Modal Dialog
class AppInfoDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String buttonText;
  final IconData icon;
  final Color? iconColor;

  const AppInfoDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.buttonText = 'Close',
    this.icon = Icons.info_outline_rounded,
    this.iconColor,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    String buttonText = 'Close',
    IconData icon = Icons.info_outline_rounded,
    Color? iconColor,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AppInfoDialog(
        title: title,
        message: message,
        content: content,
        buttonText: buttonText,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final effectiveIconColor = iconColor ?? (isDark ? AppColors.primaryYellowLight : AppColors.primaryYellowDark);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: AppDimensions.borderWidth,
        ),
      ),
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimensions.maxDialogWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: effectiveIconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Icon(icon, color: effectiveIconColor, size: AppDimensions.iconMd),
                  ),
                  const SizedBox(width: AppDimensions.spacing16),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),
              if (message != null)
                Text(
                  message!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    height: 1.4,
                  ),
                ),
              if (content != null) ...[
                if (message != null) const SizedBox(height: AppDimensions.spacing12),
                content!,
              ],
              const SizedBox(height: AppDimensions.spacing24),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    foregroundColor: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing20,
                      vertical: AppDimensions.spacing12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText,
                    style: AppTypography.buttonText.copyWith(
                      color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
