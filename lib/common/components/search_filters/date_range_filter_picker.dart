import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/query/query_filter_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

class DateRangeFilterPicker extends StatelessWidget {
  final DateRangeFilter selectedFilter;
  final ValueChanged<DateRangeFilter> onChanged;

  const DateRangeFilterPicker({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  String _getDisplayLabel() {
    if (selectedFilter.preset == DateRangePreset.all) {
      return 'Date: All Time';
    }
    if (selectedFilter.preset != DateRangePreset.custom) {
      return 'Date: ${selectedFilter.preset.label}';
    }
    if (selectedFilter.startDate != null && selectedFilter.endDate != null) {
      final s = selectedFilter.startDate!;
      final e = selectedFilter.endDate!;
      return '${s.day}/${s.month} - ${e.day}/${e.month}/${e.year}';
    }
    return 'Date: Custom Range';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isActive = selectedFilter.hasActiveDateFilter;

    return PopupMenuButton<DateRangePreset>(
      tooltip: 'Filter by Date Range',
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSelected: (preset) async {
        if (preset == DateRangePreset.custom) {
          final now = DateTime.now();
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(now.year - 5),
            lastDate: DateTime(now.year + 2),
            initialDateRange: selectedFilter.startDate != null && selectedFilter.endDate != null
                ? DateTimeRange(start: selectedFilter.startDate!, end: selectedFilter.endDate!)
                : DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
          );
          if (picked != null) {
            onChanged(DateRangeFilter(
              preset: DateRangePreset.custom,
              startDate: picked.start,
              endDate: picked.end,
            ));
          }
        } else {
          onChanged(DateRangeFilter.calculateForPreset(preset));
        }
      },
      itemBuilder: (ctx) => [
        ...DateRangePreset.values.map(
          (p) => PopupMenuItem<DateRangePreset>(
            value: p,
            child: Row(
              children: [
                Icon(
                  p == selectedFilter.preset ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 16,
                  color: p == selectedFilter.preset ? AppColors.primaryYellowDark : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  p.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: p == selectedFilter.preset ? FontWeight.bold : FontWeight.normal,
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryYellow.withValues(alpha: 0.15)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(
            color: isActive
                ? AppColors.primaryYellowDark
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: isActive ? AppColors.primaryYellowDark : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
            ),
            const SizedBox(width: 8),
            Text(
              _getDisplayLabel(),
              style: AppTypography.captionMedium.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
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
    );
  }
}
