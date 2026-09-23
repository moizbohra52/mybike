import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/query/query_filter_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

class AppPaginationBar extends StatelessWidget {
  final PaginationParams pagination;
  final int totalCount;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onPageSizeChanged;
  final List<int> availablePageSizes;

  const AppPaginationBar({
    super.key,
    required this.pagination,
    required this.totalCount,
    required this.onPageChanged,
    this.onPageSizeChanged,
    this.availablePageSizes = const [10, 25, 50, 100],
  });

  int get totalPages => (totalCount / pagination.pageSize).ceil() == 0 ? 1 : (totalCount / pagination.pageSize).ceil();
  bool get hasPrevious => pagination.page > 1;
  bool get hasNext => pagination.page < totalPages;

  int get startIndex => totalCount == 0 ? 0 : ((pagination.page - 1) * pagination.pageSize) + 1;
  int get endIndex {
    final computed = pagination.page * pagination.pageSize;
    return computed > totalCount ? totalCount : computed;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isMobile = context.isMobile;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: AppDimensions.spacing8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: isMobile ? _buildMobileLayout(context, isDark) : _buildDesktopLayout(context, isDark),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Summary & Page Size selector
        Row(
          children: [
            Text(
              'Showing $startIndex–$endIndex of $totalCount results',
              style: AppTypography.captionMedium.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
            ),
            if (onPageSizeChanged != null) ...[
              const SizedBox(width: AppDimensions.spacing16),
              Text(
                'Rows per page:',
                style: AppTypography.captionSmall.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: availablePageSizes.contains(pagination.pageSize)
                    ? pagination.pageSize
                    : availablePageSizes.first,
                isDense: true,
                underline: const SizedBox.shrink(),
                items: availablePageSizes
                    .map((s) => DropdownMenuItem<int>(
                          value: s,
                          child: Text('$s', style: AppTypography.captionLarge),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) onPageSizeChanged!(val);
                },
              ),
            ],
          ],
        ),

        // Right: Page controls
        Row(
          children: [
            // First Page
            IconButton(
              icon: const Icon(Icons.first_page, size: 18),
              tooltip: 'First Page',
              onPressed: hasPrevious ? () => onPageChanged(1) : null,
            ),
            // Previous Page
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 18),
              tooltip: 'Previous Page',
              onPressed: hasPrevious ? () => onPageChanged(pagination.page - 1) : null,
            ),
            const SizedBox(width: 4),

            // Page Indicator chips
            ..._buildPageNumbers(isDark),

            const SizedBox(width: 4),
            // Next Page
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 18),
              tooltip: 'Next Page',
              onPressed: hasNext ? () => onPageChanged(pagination.page + 1) : null,
            ),
            // Last Page
            IconButton(
              icon: const Icon(Icons.last_page, size: 18),
              tooltip: 'Last Page',
              onPressed: hasNext ? () => onPageChanged(totalPages) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return Column(
      children: [
        Text(
          'Showing $startIndex–$endIndex of $totalCount results',
          style: AppTypography.captionSmall.copyWith(
            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: hasPrevious ? () => onPageChanged(pagination.page - 1) : null,
            ),
            Text(
              'Page ${pagination.page} of $totalPages',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: hasNext ? () => onPageChanged(pagination.page + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers(bool isDark) {
    final List<Widget> widgets = [];
    final current = pagination.page;

    // Show up to 5 page pills centered around current
    int start = current - 2;
    int end = current + 2;

    if (start < 1) {
      end += (1 - start);
      start = 1;
    }
    if (end > totalPages) {
      start -= (end - totalPages);
      end = totalPages;
    }
    if (start < 1) start = 1;

    for (int p = start; p <= end; p++) {
      final isCurrent = p == current;
      widgets.add(
        InkWell(
          onTap: () => onPageChanged(p),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primaryYellowDark
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
              border: Border.all(
                color: isCurrent
                    ? AppColors.primaryYellowDark
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            child: Text(
              '$p',
              style: AppTypography.captionLarge.copyWith(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent
                    ? Colors.white
                    : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
