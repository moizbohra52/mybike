import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';
import '../loaders/app_loading.dart';
import 'app_button.dart';

/// Bordered Outlined Button
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? borderColor;
  final Color? textColor;

  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.borderColor,
    this.textColor,
  });

  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.buttonHeightSm;
      case AppButtonSize.medium:
        return AppDimensions.buttonHeightMd;
      case AppButtonSize.large:
        return AppDimensions.buttonHeightLg;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return AppDimensions.iconXs;
      case AppButtonSize.medium:
        return AppDimensions.iconSm;
      case AppButtonSize.large:
        return AppDimensions.iconMd;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: AppDimensions.spacing12);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppDimensions.spacing20);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: AppDimensions.spacing28);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isEnabled = onPressed != null && !isLoading;

    final defaultBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final defaultText = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;

    final effectiveBorderColor = isEnabled
        ? (borderColor ?? defaultBorder)
        : (borderColor ?? defaultBorder).withValues(alpha: 0.4);
    final effectiveTextColor = isEnabled
        ? (textColor ?? defaultText)
        : (textColor ?? defaultText).withValues(alpha: 0.4);

    return SizedBox(
      height: _height,
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: effectiveBorderColor, width: AppDimensions.borderWidth),
          padding: _padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          foregroundColor: effectiveTextColor,
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              AppLoading(size: AppLoadingSize.small, color: effectiveTextColor),
              const SizedBox(width: AppDimensions.spacing8),
            ] else if (leadingIcon != null) ...[
              Icon(leadingIcon, size: _iconSize, color: effectiveTextColor),
              const SizedBox(width: AppDimensions.spacing8),
            ],
            Text(
              label,
              style: AppTypography.buttonText.copyWith(color: effectiveTextColor),
            ),
            if (!isLoading && trailingIcon != null) ...[
              const SizedBox(width: AppDimensions.spacing8),
              Icon(trailingIcon, size: _iconSize, color: effectiveTextColor),
            ],
          ],
        ),
      ),
    );
  }
}
