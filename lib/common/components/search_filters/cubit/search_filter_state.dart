import 'package:equatable/equatable.dart';
import '../../../../core/query/query_filter_models.dart';

class SearchFilterState extends Equatable {
  final AdvancedQueryCriteria criteria;
  final List<SortDescriptor> availableSortOptions;
  final List<String> availableStatuses;
  final Map<String, String> availableShowrooms;

  const SearchFilterState({
    this.criteria = const AdvancedQueryCriteria(),
    this.availableSortOptions = const [],
    this.availableStatuses = const [],
    this.availableShowrooms = const {},
  });

  bool get hasActiveFilters => criteria.hasActiveFilters;
  int get activeFiltersCount => criteria.activeFiltersCount;

  SearchFilterState copyWith({
    AdvancedQueryCriteria? criteria,
    List<SortDescriptor>? availableSortOptions,
    List<String>? availableStatuses,
    Map<String, String>? availableShowrooms,
  }) {
    return SearchFilterState(
      criteria: criteria ?? this.criteria,
      availableSortOptions: availableSortOptions ?? this.availableSortOptions,
      availableStatuses: availableStatuses ?? this.availableStatuses,
      availableShowrooms: availableShowrooms ?? this.availableShowrooms,
    );
  }

  @override
  List<Object?> get props => [
        criteria,
        availableSortOptions,
        availableStatuses,
        availableShowrooms,
      ];
}
