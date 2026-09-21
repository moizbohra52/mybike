import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/query/query_filter_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

class StatusFilterChips extends StatelessWidget {
  final StatusFilter selectedFilter;
  final List<String> availableStatuses;
  final Map<String, int>? statusCounts;
  final Map<String, Color>? statusColors;
  final ValueChanged<StatusFilter> onChanged;
  final bool allowMultiSelect;

  const StatusFilterChips({
    super.key,
    required this.selectedFilter,
    required this.availableStatuses,
    this.statusCounts,
    this.statusColors,
    required this.onChanged,
    this.allowMultiSelect = true,
  });

  Color _getStatusColor(String status) {
    if (statusColors != null && statusColors!.containsKey(status)) {
      return statusColors![status]!;
    }
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
      case 'active':
      case 'in_stock':
      case 'delivered':
        return AppColors.success;
      case 'rejected':
      case 'cancelled':
      case 'inactive':
      case 'out_of_stock':
        return AppColors.error;
      case 'pending':
      case 'in_review':
      case 'booked':
        return AppColors.warning;
      default:
        return AppColors.primaryYellowDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "All" chip
          FilterChip(
            selected: selectedFilter.allStatuses || selectedFilter.selectedStatuses.isEmpty,
            label: const Text('All Statuses'),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: (selectedFilter.allStatuses || selectedFilter.selectedStatuses.isEmpty)
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: (selectedFilter.allStatuses || selectedFilter.selectedStatuses.isEmpty)
                  ? AppColors.primaryYellowDark
                  : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
            ),
            selectedColor: AppColors.primaryYellow.withValues(alpha: 0.18),
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              side: BorderSide(
                color: (selectedFilter.allStatuses || selectedFilter.selectedStatuses.isEmpty)
                    ? AppColors.primaryYellowDark
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            onSelected: (_) {
              onChanged(const StatusFilter(allStatuses: true, selectedStatuses: []));
            },
          ),
          const SizedBox(width: 8),

          // Individual Status chips
          ...availableStatuses.map((status) {
            final isSelected = selectedFilter.selectedStatuses.contains(status);
            final color = _getStatusColor(status);
            final count = statusCounts?[status];

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(status.replaceAll('_', ' ').toUpperCase()),
                    if (count != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? color
                      : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                ),
                selectedColor: color.withValues(alpha: 0.15),
                backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  side: BorderSide(
                    color: isSelected
                        ? color
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                ),
                onSelected: (selected) {
                  if (allowMultiSelect) {
                    onChanged(selectedFilter.toggleStatus(status));
                  } else {
                    if (selected) {
                      onChanged(StatusFilter(allStatuses: false, selectedStatuses: [status]));
                    } else {
                      onChanged(const StatusFilter(allStatuses: true, selectedStatuses: []));
                    }
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
