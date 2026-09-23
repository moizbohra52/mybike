import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';

/// Single Filter Option Model
class AppFilterOption<T> {
  final String label;
  final T value;
  final int? count;
  final IconData? icon;

  const AppFilterOption({
    required this.label,
    required this.value,
    this.count,
    this.icon,
  });
}

/// Horizontal Filter Bar with Filter Chips
class AppFilter<T> extends StatelessWidget {
  final List<AppFilterOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T> onSelected;
  final VoidCallback? onClear;
  final String? allLabel;
  final bool showAllOption;

  const AppFilter({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.onClear,
    this.allLabel = 'All',
    this.showAllOption = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onClear != null && selectedValue != null) ...[
            ActionChip(
              avatar: const Icon(Icons.close_rounded, size: 14),
              label: const Text('Clear'),
              onPressed: onClear,
              backgroundColor: isDark ? AppColors.darkCard : AppColors.lightBackground,
              side: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              labelStyle: AppTypography.captionMedium.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
            ),
            const SizedBox(width: AppDimensions.spacing8),
          ],
          ...options.map((option) {
            final isSelected = selectedValue == option.value;

            return Padding(
              padding: const EdgeInsets.only(right: AppDimensions.spacing8),
              child: FilterChip(
                selected: isSelected,
                showCheckmark: false,
                avatar: option.icon != null
                    ? Icon(
                        option.icon,
                        size: 14,
                        color: isSelected
                            ? AppColors.primaryBlack
                            : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText),
                      )
                    : null,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(option.label),
                    if (option.count != null) ...[
                      const SizedBox(width: AppDimensions.spacing6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBlack.withValues(alpha: 0.2)
                              : (isDark ? AppColors.darkSurface : AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Text(
                          option.count.toString(),
                          style: AppTypography.captionSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryBlack
                                : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                labelStyle: AppTypography.captionMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryBlack
                      : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                ),
                backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
                selectedColor: AppColors.primaryYellow,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryYellow
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: AppDimensions.borderWidth,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacing10,
                  vertical: AppDimensions.spacing6,
                ),
                onSelected: (_) => onSelected(option.value),
              ),
            );
          }),
        ],
      ),
    );
  }
}
