import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/query/query_filter_models.dart';
import 'search_filter_state.dart';

class SearchFilterCubit extends Cubit<SearchFilterState> {
  final void Function(AdvancedQueryCriteria criteria)? onCriteriaChanged;

  SearchFilterCubit({
    AdvancedQueryCriteria initialCriteria = const AdvancedQueryCriteria(),
    List<SortDescriptor> availableSortOptions = const [],
    List<String> availableStatuses = const [],
    Map<String, String> availableShowrooms = const {},
    this.onCriteriaChanged,
  }) : super(SearchFilterState(
          criteria: initialCriteria,
          availableSortOptions: availableSortOptions,
          availableStatuses: availableStatuses,
          availableShowrooms: availableShowrooms,
        ));

  void setSearchQuery(String query) {
    final updated = state.criteria.copyWith(
      searchQuery: query,
      pagination: state.criteria.pagination.copyWith(page: 1),
    );
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }

  void setDateRangePreset(DateRangePreset preset) {
    final filter = DateRangeFilter.calculateForPreset(preset);
    final updated = state.criteria.copyWith(
      dateRange: filter,
      pagination: state.criteria.pagination.copyWith(page: 1),
    );
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }

  void setCustomDateRange(DateTime? start, DateTime? end) {
    final filter = DateRangeFilter(
      preset: DateRangePreset.custom,
      startDate: start,
      endDate: end,
    );
    final updated = state.criteria.copyWith(
      dateRange: filter,
      pagination: state.criteria.pagination.copyWith(page: 1),
    );
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }

  void toggleStatus(String status) {
    final updatedStatus = state.criteria.statusFilter.toggleStatus(status);
    final updated = state.criteria.copyWith(
      statusFilter: updatedStatus,
      pagination: state.criteria.pagination.copyWith(page: 1),
    );
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }

  void setAllStatuses() {
    final updated = state.criteria.copyWith(
      statusFilter: const StatusFilter(allStatuses: true, selectedStatuses: []),
      pagination: state.criteria.pagination.copyWith(page: 1),
    );
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }

  void toggleShowroom(String showroomId) {
    final updatedShowrooms = state.criteria.showroomFilter.toggleShowroom(showroomId);
    final updated = state.criteria.copyWith(
      showroomFilter: updatedShowrooms,
      pagination: state.criteria.pagination.copyWith(page: 1),
    );
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }

  void setAllShowrooms() {
    final updated = state.criteria.copyWith(
      showroomFilter: const ShowroomFilter(allShowrooms: true, selectedShowroomIds: []),
      pagination: state.criteria.pagination.copyWith(page: 1),
    );
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }

  void setSort(SortDescriptor sort) {
    final updated = state.criteria.copyWith(
      sort: sort,
    );
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }

  void toggleSortDirection() {
    if (state.criteria.sort != null) {
      final updatedSort = state.criteria.sort!.toggleDirection();
      final updated = state.criteria.copyWith(sort: updatedSort);
      emit(state.copyWith(criteria: updated));
      onCriteriaChanged?.call(updated);
    }
  }

  void clearSort() {
    final updated = state.criteria.copyWith(clearSort: true);
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }

  void addFilter(FilterDescriptor filter) {
    final current = List<FilterDescriptor>.from(state.criteria.filters);
    current.removeWhere((f) => f.field == filter.field);
    current.add(filter);

    final updated = state.criteria.copyWith(
      filters: current,
      pagination: state.criteria.pagination.copyWith(page: 1),
    );
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }

  void removeFilter(String field) {
    final current = List<FilterDescriptor>.from(state.criteria.filters)
      ..removeWhere((f) => f.field == field);

    final updated = state.criteria.copyWith(
      filters: current,
      pagination: state.criteria.pagination.copyWith(page: 1),
    );
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }

  void setPage(int page) {
    final updated = state.criteria.copyWith(
      pagination: state.criteria.pagination.copyWith(page: page),
    );
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }

  void setPageSize(int pageSize) {
    final updated = state.criteria.copyWith(
      pagination: PaginationParams(page: 1, pageSize: pageSize),
    );
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }

  void resetAllFilters() {
    final updated = AdvancedQueryCriteria(
      sort: state.criteria.sort,
      pagination: PaginationParams(pageSize: state.criteria.pagination.pageSize),
    );
    emit(state.copyWith(criteria: updated));
    onCriteriaChanged?.call(updated);
  }
}
