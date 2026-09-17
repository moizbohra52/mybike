import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';

/// ERP Pagination Bar
class AppPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onPageSizeChanged;

  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.pageSize,
    this.pageSizeOptions = const [10, 25, 50, 100],
    required this.onPageChanged,
    this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isMobile = context.isMobile;

    final startRecord = totalRecords == 0 ? 0 : ((currentPage - 1) * pageSize) + 1;
    final endRecord = (currentPage * pageSize).clamp(0, totalRecords);

    final infoText = Text(
      'Showing $startRecord–$endRecord of $totalRecords',
      style: AppTypography.captionMedium.copyWith(
        color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
      ),
    );

    final pageSizeSelector = onPageSizeChanged != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rows per page: ',
                style: AppTypography.captionMedium.copyWith(
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
              ),
              DropdownButton<int>(
                value: pageSize,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.arrow_drop_down_rounded, size: 18),
                items: pageSizeOptions.map((size) {
                  return DropdownMenuItem<int>(
                    value: size,
                    child: Text(
                      size.toString(),
                      style: AppTypography.captionMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newSize) {
                  if (newSize != null) onPageSizeChanged!(newSize);
                },
              ),
            ],
          )
        : const SizedBox.shrink();

    final paginationButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          iconSize: AppDimensions.iconMd,
          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
          disabledColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
          tooltip: 'Previous page',
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
            vertical: AppDimensions.spacing6,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: AppDimensions.borderWidth,
            ),
          ),
          child: Text(
            '$currentPage / ${totalPages > 0 ? totalPages : 1}',
            style: AppTypography.captionMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          iconSize: AppDimensions.iconMd,
          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
          disabledColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
          tooltip: 'Next page',
        ),
      ],
    );

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing12,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                infoText,
                pageSizeSelector,
              ],
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Center(child: paginationButtons),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing20,
        vertical: AppDimensions.spacing12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          infoText,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              pageSizeSelector,
              const SizedBox(width: AppDimensions.spacing24),
              paginationButtons,
            ],
          ),
        ],
      ),
    );
  }
}
