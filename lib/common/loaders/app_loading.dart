import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';

/// Loading indicator size variants
enum AppLoadingSize { small, medium, large }

/// MYBIKE Brand Loading Indicator
class AppLoading extends StatelessWidget {
  final AppLoadingSize size;
  final Color? color;
  final String? message;
  final bool isHorizontal;

  const AppLoading({
    super.key,
    this.size = AppLoadingSize.medium,
    this.color,
    this.message,
    this.isHorizontal = false,
  });

  const AppLoading.small({
    super.key,
    this.color,
    this.message,
    this.isHorizontal = true,
  }) : size = AppLoadingSize.small;

  const AppLoading.large({
    super.key,
    this.color,
    this.message,
    this.isHorizontal = false,
  }) : size = AppLoadingSize.large;

  double get _dimension {
    switch (size) {
      case AppLoadingSize.small:
        return 16;
      case AppLoadingSize.medium:
        return 24;
      case AppLoadingSize.large:
        return 40;
    }
  }

  double get _strokeWidth {
    switch (size) {
      case AppLoadingSize.small:
        return 2.0;
      case AppLoadingSize.medium:
        return 2.5;
      case AppLoadingSize.large:
        return 3.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryYellow;

    final indicator = SizedBox(
      width: _dimension,
      height: _dimension,
      child: CircularProgressIndicator(
        strokeWidth: _strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
        backgroundColor: effectiveColor.withValues(alpha: 0.15),
      ),
    );

    if (message == null || message!.isEmpty) {
      return Center(child: indicator);
    }

    final text = Text(
      message!,
      style: AppTypography.bodySmall.copyWith(
        color: context.isDarkMode
            ? AppColors.darkSecondaryText
            : AppColors.lightSecondaryText,
      ),
    );

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          indicator,
          const SizedBox(width: AppDimensions.spacing10),
          Flexible(child: text),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        indicator,
        const SizedBox(height: AppDimensions.spacing12),
        text,
      ],
    );
  }
}
