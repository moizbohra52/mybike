import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/query/query_filter_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

class SortMenuButton extends StatelessWidget {
  final SortDescriptor? currentSort;
  final List<SortDescriptor> options;
  final ValueChanged<SortDescriptor> onSortChanged;
  final VoidCallback? onToggleDirection;
  final VoidCallback? onClear;

  const SortMenuButton({
    super.key,
    this.currentSort,
    required this.options,
    required this.onSortChanged,
    this.onToggleDirection,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final hasSort = currentSort != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<SortDescriptor>(
          tooltip: 'Sort by field',
          offset: const Offset(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          onSelected: onSortChanged,
          itemBuilder: (ctx) => [
            ...options.map((opt) {
              final isSelected = currentSort?.field == opt.field;
              return PopupMenuItem<SortDescriptor>(
                value: opt.copyWith(
                  direction: isSelected ? currentSort!.direction : opt.direction,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check : Icons.sort,
                      size: 16,
                      color: isSelected ? AppColors.primaryYellowDark : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      opt.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (hasSort && onClear != null) ...[
              const PopupMenuDivider(),
              PopupMenuItem<SortDescriptor>(
                onTap: onClear,
                child: const Row(
                  children: [
                    Icon(Icons.clear, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Clear Sort', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ],
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: hasSort
                  ? AppColors.primaryYellow.withValues(alpha: 0.15)
                  : (isDark ? AppColors.darkCard : AppColors.lightCard),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              border: Border.all(
                color: hasSort
                    ? AppColors.primaryYellowDark
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort,
                  size: 16,
                  color: hasSort ? AppColors.primaryYellowDark : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                ),
                const SizedBox(width: 6),
                Text(
                  hasSort ? 'Sort: ${currentSort!.label}' : 'Sort',
                  style: AppTypography.captionMedium.copyWith(
                    fontWeight: hasSort ? FontWeight.w600 : FontWeight.normal,
                    color: hasSort
                        ? (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText)
                        : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                ),
              ],
            ),
          ),
        ),
        if (hasSort && onToggleDirection != null) ...[
          const SizedBox(width: 4),
          IconButton(
            tooltip: currentSort!.isAscending ? 'Ascending (tap to flip)' : 'Descending (tap to flip)',
            icon: Icon(
              currentSort!.isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 18,
              color: AppColors.primaryYellowDark,
            ),
            onPressed: onToggleDirection,
          ),
        ],
      ],
    );
  }
}
