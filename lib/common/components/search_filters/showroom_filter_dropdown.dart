import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/query/query_filter_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

class ShowroomFilterDropdown extends StatelessWidget {
  final ShowroomFilter selectedFilter;
  final Map<String, String> showrooms; // Map of showroomId -> showroomName
  final ValueChanged<ShowroomFilter> onChanged;

  const ShowroomFilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.showrooms,
    required this.onChanged,
  });

  String _getDisplayLabel() {
    if (selectedFilter.allShowrooms || selectedFilter.selectedShowroomIds.isEmpty) {
      return 'All Showrooms';
    }
    if (selectedFilter.selectedShowroomIds.length == 1) {
      final id = selectedFilter.selectedShowroomIds.first;
      return showrooms[id] ?? 'Showroom ($id)';
    }
    return '${selectedFilter.selectedShowroomIds.length} Showrooms';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isFiltered = selectedFilter.isFiltered;

    return PopupMenuButton<String>(
      tooltip: 'Filter by Showroom Branch',
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSelected: (val) {
        if (val == '__ALL__') {
          onChanged(const ShowroomFilter(allShowrooms: true, selectedShowroomIds: []));
        } else {
          onChanged(selectedFilter.toggleShowroom(val));
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem<String>(
          value: '__ALL__',
          child: Row(
            children: [
              Icon(
                selectedFilter.allShowrooms ? Icons.check_circle : Icons.circle_outlined,
                size: 16,
                color: selectedFilter.allShowrooms ? AppColors.primaryYellowDark : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'All Showrooms',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selectedFilter.allShowrooms ? FontWeight.bold : FontWeight.normal,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        ...showrooms.entries.map((entry) {
          final isSelected = selectedFilter.selectedShowroomIds.contains(entry.key);
          return PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 16,
                  color: isSelected ? AppColors.primaryYellowDark : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  entry.value,
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
      ],
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isFiltered
              ? AppColors.primaryYellow.withValues(alpha: 0.15)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(
            color: isFiltered
                ? AppColors.primaryYellowDark
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 16,
              color: isFiltered ? AppColors.primaryYellowDark : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                _getDisplayLabel(),
                overflow: TextOverflow.ellipsis,
                style: AppTypography.captionMedium.copyWith(
                  fontWeight: isFiltered ? FontWeight.w600 : FontWeight.normal,
                  color: isFiltered
                      ? (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText)
                      : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                ),
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
    );
  }
}
