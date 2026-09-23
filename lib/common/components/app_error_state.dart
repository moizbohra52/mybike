import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';

/// Visual Error State with Retry
class AppErrorState extends StatefulWidget {
  final String title;
  final String message;
  final String? technicalDetails;
  final VoidCallback? onRetry;
  final String retryLabel;
  final VoidCallback? onBack;

  const AppErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'An unexpected error occurred while loading this data. Please try again.',
    this.technicalDetails,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.onBack,
  });

  @override
  State<AppErrorState> createState() => _AppErrorStateState();
}

class _AppErrorStateState extends State<AppErrorState> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: AppDimensions.borderWidth,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing20),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  height: 1.4,
                ),
              ),
            ),
            if (widget.technicalDetails != null && widget.technicalDetails!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacing16),
              TextButton.icon(
                onPressed: () => setState(() => _showDetails = !_showDetails),
                icon: Icon(
                  _showDetails ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: AppDimensions.iconSm,
                  color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                ),
                label: Text(
                  _showDetails ? 'Hide details' : 'View error details',
                  style: AppTypography.captionMedium.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
              ),
              if (_showDetails)
                Container(
                  margin: const EdgeInsets.only(top: AppDimensions.spacing8),
                  padding: const EdgeInsets.all(AppDimensions.spacing12),
                  constraints: const BoxConstraints(maxWidth: 460),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: SelectableText(
                    widget.technicalDetails!,
                    style: AppTypography.captionMedium.copyWith(
                      fontFamily: 'monospace',
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: AppDimensions.spacing24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onBack != null) ...[
                  OutlinedButton(
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing20,
                        vertical: AppDimensions.spacing12,
                      ),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: const Text('Go Back'),
                  ),
                  const SizedBox(width: AppDimensions.spacing12),
                ],
                if (widget.onRetry != null)
                  FilledButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: AppDimensions.iconSm),
                    label: Text(widget.retryLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.primaryBlack,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing20,
                        vertical: AppDimensions.spacing12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
