import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/context_extensions.dart';
import '../loaders/app_shimmer.dart';
import '../components/app_empty_state.dart';

/// Column descriptor for AppDataTable
class AppDataColumn<T> {
  final String title;
  final Widget Function(BuildContext context, T item) cellBuilder;
  final int flex;
  final double? width;
  final bool isNumeric;
  final VoidCallback? onSort;
  final bool? isSortedAscending;

  const AppDataColumn({
    required this.title,
    required this.cellBuilder,
    this.flex = 1,
    this.width,
    this.isNumeric = false,
    this.onSort,
    this.isSortedAscending,
  });
}

/// Responsive Data Table for MYBIKE ERP Lists
class AppDataTable<T> extends StatelessWidget {
  final List<AppDataColumn<T>> columns;
  final List<T> items;
  final ValueChanged<T>? onRowTap;
  final bool isLoading;
  final String emptyTitle;
  final String emptyMessage;
  final double minWidth;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.items,
    this.onRowTap,
    this.isLoading = false,
    this.emptyTitle = 'No records found',
    this.emptyMessage = 'There are no records to display at this time.',
    this.minWidth = 600,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    if (isLoading) {
      return Column(
        children: List.generate(5, (_) => AppShimmer.tableRow(columns: columns.length)),
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing32),
        child: AppEmptyState(
          title: emptyTitle,
          description: emptyMessage,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableContent = Column(
          children: [
            // Header Row
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing16,
                vertical: AppDimensions.spacing12,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: AppDimensions.borderWidth,
                  ),
                ),
              ),
              child: Row(
                children: columns.map((col) {
                  Widget titleText = Text(
                    col.title.toUpperCase(),
                    textAlign: col.isNumeric ? TextAlign.right : TextAlign.left,
                    style: AppTypography.overline.copyWith(
                      color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  );

                  Widget headerCell;
                  if (col.onSort != null) {
                    headerCell = InkWell(
                      onTap: col.onSort,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: col.isNumeric ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Flexible(child: titleText),
                          const SizedBox(width: AppDimensions.spacing4),
                          Icon(
                            col.isSortedAscending == true
                                ? Icons.arrow_upward_rounded
                                : (col.isSortedAscending == false ? Icons.arrow_downward_rounded : Icons.swap_vert_rounded),
                            size: 14,
                            color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          ),
                        ],
                      ),
                    );
                  } else {
                    headerCell = titleText;
                  }

                  if (col.width != null) {
                    return SizedBox(width: col.width, child: headerCell);
                  }
                  return Expanded(flex: col.flex, child: headerCell);
                }).toList(),
              ),
            ),
            // Data Rows
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isEven = index % 2 == 0;

              return Material(
                color: isEven
                    ? Colors.transparent
                    : (isDark
                        ? AppColors.darkSurface.withValues(alpha: 0.3)
                        : AppColors.lightBackground.withValues(alpha: 0.5)),
                child: InkWell(
                  onTap: onRowTap != null ? () => onRowTap!(item) : null,
                  hoverColor: isDark
                      ? AppColors.primaryYellow.withValues(alpha: 0.05)
                      : AppColors.primaryYellow.withValues(alpha: 0.08),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing16,
                      vertical: AppDimensions.spacing12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                          width: AppDimensions.borderWidthThin,
                        ),
                      ),
                    ),
                    child: Row(
                      children: columns.map((col) {
                        Widget cell = col.cellBuilder(context, item);
                        if (col.width != null) {
                          return SizedBox(width: col.width, child: cell);
                        }
                        return Expanded(flex: col.flex, child: cell);
                      }).toList(),
                    ),
                  ),
                ),
              );
            }),
          ],
        );

        if (constraints.maxWidth < minWidth) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: minWidth,
              child: tableContent,
            ),
          );
        }

        return tableContent;
      },
    );
  }
}
