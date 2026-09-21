import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/query/query_filter_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import 'advanced_filter_modal.dart';
import 'app_search_bar.dart';
import 'date_range_filter_picker.dart';
import 'global_search_modal.dart';
import 'showroom_filter_dropdown.dart';
import 'sort_menu_button.dart';
import 'status_filter_chips.dart';

class SearchFilterBar extends StatelessWidget {
  final AdvancedQueryCriteria criteria;
  final ValueChanged<AdvancedQueryCriteria> onCriteriaChanged;
  final String searchHintText;
  final bool showDateFilter;
  final bool showShowroomFilter;
  final bool showStatusFilter;
  final bool showAdvancedFilter;
  final Map<String, String> showrooms;
  final List<String> availableStatuses;
  final Map<String, int>? statusCounts;
  final List<SortDescriptor> sortOptions;
  final List<FilterableFieldDefinition> filterableFields;

  const SearchFilterBar({
    super.key,
    required this.criteria,
    required this.onCriteriaChanged,
    this.searchHintText = 'Search records...',
    this.showDateFilter = true,
    this.showShowroomFilter = false,
    this.showStatusFilter = false,
    this.showAdvancedFilter = true,
    this.showrooms = const {},
    this.availableStatuses = const [],
    this.statusCounts,
    this.sortOptions = const [],
    this.filterableFields = const [],
  });

  void _openAdvancedFilterModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AdvancedFilterModal(
        initialFilters: criteria.filters,
        availableFields: filterableFields,
        onApply: (newFilters) {
          onCriteriaChanged(criteria.copyWith(
            filters: newFilters,
            pagination: criteria.pagination.copyWith(page: 1),
          ));
        },
      ),
    );
  }

  void _clearAllFilters() {
    onCriteriaChanged(AdvancedQueryCriteria(
      sort: criteria.sort,
      pagination: criteria.pagination.copyWith(page: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isMobile = context.isMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Row: Search bar & primary action filters
        if (isMobile) ...[
          AppSearchBar(
            initialValue: criteria.searchQuery,
            hintText: searchHintText,
            activeFilterCount: criteria.activeFiltersCount,
            onChanged: (q) {
              onCriteriaChanged(criteria.copyWith(
                searchQuery: q,
                pagination: criteria.pagination.copyWith(page: 1),
              ));
            },
            onCommandPaletteTap: () => GlobalSearchModal.show(context),
            onFilterTap: showAdvancedFilter && filterableFields.isNotEmpty
                ? () => _openAdvancedFilterModal(context)
                : null,
          ),
          const SizedBox(height: AppDimensions.spacing8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (showDateFilter) ...[
                  DateRangeFilterPicker(
                    selectedFilter: criteria.dateRange,
                    onChanged: (d) => onCriteriaChanged(criteria.copyWith(
                      dateRange: d,
                      pagination: criteria.pagination.copyWith(page: 1),
                    )),
                  ),
                  const SizedBox(width: 8),
                ],
                if (showShowroomFilter && showrooms.isNotEmpty) ...[
                  ShowroomFilterDropdown(
                    selectedFilter: criteria.showroomFilter,
                    showrooms: showrooms,
                    onChanged: (s) => onCriteriaChanged(criteria.copyWith(
                      showroomFilter: s,
                      pagination: criteria.pagination.copyWith(page: 1),
                    )),
                  ),
                  const SizedBox(width: 8),
                ],
                if (sortOptions.isNotEmpty) ...[
                  SortMenuButton(
                    currentSort: criteria.sort,
                    options: sortOptions,
                    onSortChanged: (s) => onCriteriaChanged(criteria.copyWith(sort: s)),
                    onToggleDirection: () {
                      if (criteria.sort != null) {
                        onCriteriaChanged(criteria.copyWith(sort: criteria.sort!.toggleDirection()));
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ] else ...[
          Row(
            children: [
              // Search Input
              Expanded(
                flex: 3,
                child: AppSearchBar(
                  initialValue: criteria.searchQuery,
                  hintText: searchHintText,
                  onChanged: (q) {
                    onCriteriaChanged(criteria.copyWith(
                      searchQuery: q,
                      pagination: criteria.pagination.copyWith(page: 1),
                    ));
                  },
                  onCommandPaletteTap: () => GlobalSearchModal.show(context),
                ),
              ),
              const SizedBox(width: AppDimensions.spacing12),

              // Date Range Picker
              if (showDateFilter) ...[
                DateRangeFilterPicker(
                  selectedFilter: criteria.dateRange,
                  onChanged: (d) => onCriteriaChanged(criteria.copyWith(
                    dateRange: d,
                    pagination: criteria.pagination.copyWith(page: 1),
                  )),
                ),
                const SizedBox(width: AppDimensions.spacing12),
              ],

              // Showroom Dropdown
              if (showShowroomFilter && showrooms.isNotEmpty) ...[
                ShowroomFilterDropdown(
                  selectedFilter: criteria.showroomFilter,
                  showrooms: showrooms,
                  onChanged: (s) => onCriteriaChanged(criteria.copyWith(
                    showroomFilter: s,
                    pagination: criteria.pagination.copyWith(page: 1),
                  )),
                ),
                const SizedBox(width: AppDimensions.spacing12),
              ],

              // Sort Menu Button
              if (sortOptions.isNotEmpty) ...[
                SortMenuButton(
                  currentSort: criteria.sort,
                  options: sortOptions,
                  onSortChanged: (s) => onCriteriaChanged(criteria.copyWith(sort: s)),
                  onToggleDirection: () {
                    if (criteria.sort != null) {
                      onCriteriaChanged(criteria.copyWith(sort: criteria.sort!.toggleDirection()));
                    }
                  },
                  onClear: () => onCriteriaChanged(criteria.copyWith(clearSort: true)),
                ),
                const SizedBox(width: AppDimensions.spacing12),
              ],

              // Advanced Filters Button
              if (showAdvancedFilter && filterableFields.isNotEmpty) ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    side: BorderSide(
                      color: criteria.filters.isNotEmpty
                          ? AppColors.primaryYellowDark
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                  onPressed: () => _openAdvancedFilterModal(context),
                  icon: Badge(
                    isLabelVisible: criteria.filters.isNotEmpty,
                    label: Text('${criteria.filters.length}'),
                    child: const Icon(Icons.tune_rounded, size: 16),
                  ),
                  label: const Text('Filters', style: TextStyle(fontSize: 13)),
                ),
              ],
            ],
          ),
        ],

        // Status Chips row (if enabled)
        if (showStatusFilter && availableStatuses.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacing12),
          StatusFilterChips(
            selectedFilter: criteria.statusFilter,
            availableStatuses: availableStatuses,
            statusCounts: statusCounts,
            onChanged: (s) => onCriteriaChanged(criteria.copyWith(
              statusFilter: s,
              pagination: criteria.pagination.copyWith(page: 1),
            )),
          ),
        ],

        // Active filter tags row (if any active filters exist)
        if (criteria.hasActiveFilters) ...[
          const SizedBox(height: AppDimensions.spacing8),
          _buildActiveFiltersChipsRow(context, isDark),
        ],
      ],
    );
  }

  Widget _buildActiveFiltersChipsRow(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(
            'Active Filters:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
            ),
          ),
          const SizedBox(width: 8),

          // Search tag
          if (criteria.searchQuery.trim().isNotEmpty) ...[
            _buildRemovableChip(
              label: 'Search: "${criteria.searchQuery.trim()}"',
              onRemove: () => onCriteriaChanged(criteria.copyWith(searchQuery: '')),
              isDark: isDark,
            ),
            const SizedBox(width: 6),
          ],

          // Date range tag
          if (criteria.dateRange.hasActiveDateFilter) ...[
            _buildRemovableChip(
              label: criteria.dateRange.preset != DateRangePreset.custom
                  ? criteria.dateRange.preset.label
                  : 'Custom Date',
              onRemove: () => onCriteriaChanged(criteria.copyWith(
                dateRange: const DateRangeFilter(preset: DateRangePreset.all),
              )),
              isDark: isDark,
            ),
            const SizedBox(width: 6),
          ],

          // Showroom tag
          if (criteria.showroomFilter.isFiltered) ...[
            _buildRemovableChip(
              label: '${criteria.showroomFilter.selectedShowroomIds.length} Showrooms',
              onRemove: () => onCriteriaChanged(criteria.copyWith(
                showroomFilter: const ShowroomFilter(allShowrooms: true, selectedShowroomIds: []),
              )),
              isDark: isDark,
            ),
            const SizedBox(width: 6),
          ],

          // Status tags
          if (criteria.statusFilter.isFiltered) ...[
            _buildRemovableChip(
              label: 'Status: ${criteria.statusFilter.selectedStatuses.join(", ").toUpperCase()}',
              onRemove: () => onCriteriaChanged(criteria.copyWith(
                statusFilter: const StatusFilter(allStatuses: true, selectedStatuses: []),
              )),
              isDark: isDark,
            ),
            const SizedBox(width: 6),
          ],

          // Dynamic rule tags
          ...criteria.filters.map((f) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _buildRemovableChip(
                label: '${f.label} ${f.operator.name} ${f.value}',
                onRemove: () {
                  final updated = List<FilterDescriptor>.from(criteria.filters)
                    ..removeWhere((item) => item.field == f.field);
                  onCriteriaChanged(criteria.copyWith(filters: updated));
                },
                isDark: isDark,
              ),
            );
          }),

          // Clear All Button
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear All', style: TextStyle(fontSize: 11, color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildRemovableChip({
    required String label,
    required VoidCallback onRemove,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: AppColors.primaryYellowDark.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 13, color: AppColors.primaryYellowDark),
          ),
        ],
      ),
    );
  }
}
