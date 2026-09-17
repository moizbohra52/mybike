import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';
import '../loaders/app_loading.dart';

/// Button visual variants
enum AppButtonVariant { primary, secondary, danger, ghost }

/// Button size variants
enum AppButtonSize { small, medium, large }

/// MYBIKE Standard Button
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
  }) : variant = AppButtonVariant.danger;

  const AppButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
  }) : variant = AppButtonVariant.ghost;

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

  TextStyle get _textStyle {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.captionLarge.copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.medium:
        return AppTypography.buttonText;
      case AppButtonSize.large:
        return AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isEnabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = AppColors.primaryYellow;
        foregroundColor = AppColors.primaryBlack;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = isDark ? AppColors.darkCard : AppColors.lightSurface;
        foregroundColor = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
        borderSide = BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: AppDimensions.borderWidth,
        );
        break;
      case AppButtonVariant.danger:
        backgroundColor = AppColors.error;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
        break;
    }

    if (!isEnabled && variant != AppButtonVariant.ghost) {
      backgroundColor = backgroundColor.withValues(alpha: 0.5);
      foregroundColor = foregroundColor.withValues(alpha: 0.5);
    }

    final buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          AppLoading(
            size: size == AppButtonSize.small ? AppLoadingSize.small : AppLoadingSize.small,
            color: foregroundColor,
          ),
          const SizedBox(width: AppDimensions.spacing8),
        ] else if (leadingIcon != null) ...[
          Icon(leadingIcon, size: _iconSize, color: foregroundColor),
          const SizedBox(width: AppDimensions.spacing8),
        ],
        Text(
          label,
          style: _textStyle.copyWith(color: foregroundColor),
        ),
        if (!isLoading && trailingIcon != null) ...[
          const SizedBox(width: AppDimensions.spacing8),
          Icon(trailingIcon, size: _iconSize, color: foregroundColor),
        ],
      ],
    );

    Widget button = SizedBox(
      height: _height,
      width: isFullWidth ? double.infinity : width,
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          side: borderSide,
        ),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          splashColor: foregroundColor.withValues(alpha: 0.1),
          highlightColor: foregroundColor.withValues(alpha: 0.05),
          child: Padding(
            padding: _padding,
            child: buttonContent,
          ),
        ),
      ),
    );

    return button;
  }
}
