import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';
import 'app_loading.dart';

/// Full-page or container-level overlay loader
class AppPageLoader extends StatelessWidget {
  final String? message;
  final bool isModal;
  final Color? backgroundColor;

  const AppPageLoader({
    super.key,
    this.message,
    this.isModal = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    Widget content = Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing24,
          vertical: AppDimensions.spacing20,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: AppDimensions.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoading(size: AppLoadingSize.large),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.lightPrimaryText,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (isModal) {
      return Container(
        color: (backgroundColor ?? Colors.black).withValues(alpha: 0.5),
        child: content,
      );
    }

    return Container(
      color: backgroundColor ??
          (isDark ? AppColors.darkBackground : AppColors.lightBackground),
      child: content,
    );
  }
}
