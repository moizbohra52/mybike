import 'package:equatable/equatable.dart';

/// Available filter comparison operators
enum FilterOperator {
  equals,
  notEquals,
  contains,
  startsWith,
  greaterThan,
  greaterThanOrEqual,
  lessThan,
  lessThanOrEqual,
  between,
  inList,
  isNull,
  isNotNull,
}

extension FilterOperatorExtension on FilterOperator {
  String get label {
    switch (this) {
      case FilterOperator.equals:
        return 'Equals (=)';
      case FilterOperator.notEquals:
        return 'Not Equals (≠)';
      case FilterOperator.contains:
        return 'Contains';
      case FilterOperator.startsWith:
        return 'Starts With';
      case FilterOperator.greaterThan:
        return 'Greater Than (>)';
      case FilterOperator.greaterThanOrEqual:
        return 'Greater Than or Equal (≥)';
      case FilterOperator.lessThan:
        return 'Less Than (<)';
      case FilterOperator.lessThanOrEqual:
        return 'Less Than or Equal (≤)';
      case FilterOperator.between:
        return 'Between Range';
      case FilterOperator.inList:
        return 'In List';
      case FilterOperator.isNull:
        return 'Is Empty / Null';
      case FilterOperator.isNotNull:
        return 'Is Not Empty';
    }
  }
}

/// Generic Filter Descriptor for dynamic rule building
class FilterDescriptor extends Equatable {
  final String field;
  final String label;
  final FilterOperator operator;
  final dynamic value;
  final dynamic secondValue; // For 'between' ranges
  final bool isActive;

  const FilterDescriptor({
    required this.field,
    required this.label,
    required this.operator,
    required this.value,
    this.secondValue,
    this.isActive = true,
  });

  FilterDescriptor copyWith({
    String? field,
    String? label,
    FilterOperator? operator,
    dynamic value,
    dynamic secondValue,
    bool? isActive,
  }) {
    return FilterDescriptor(
      field: field ?? this.field,
      label: label ?? this.label,
      operator: operator ?? this.operator,
      value: value ?? this.value,
      secondValue: secondValue ?? this.secondValue,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [field, label, operator, value, secondValue, isActive];
}

/// Sorting direction
enum SortDirection { ascending, descending }

/// Sort Descriptor
class SortDescriptor extends Equatable {
  final String field;
  final String label;
  final SortDirection direction;

  const SortDescriptor({
    required this.field,
    required this.label,
    this.direction = SortDirection.ascending,
  });

  bool get isAscending => direction == SortDirection.ascending;
  bool get isDescending => direction == SortDirection.descending;

  SortDescriptor toggleDirection() {
    return SortDescriptor(
      field: field,
      label: label,
      direction: isAscending ? SortDirection.descending : SortDirection.ascending,
    );
  }

  SortDescriptor copyWith({
    String? field,
    String? label,
    SortDirection? direction,
  }) {
    return SortDescriptor(
      field: field ?? this.field,
      label: label ?? this.label,
      direction: direction ?? this.direction,
    );
  }

  @override
  List<Object?> get props => [field, label, direction];
}

/// Standardized Pagination Parameters
class PaginationParams extends Equatable {
  final int page; // 1-indexed
  final int pageSize;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 25,
  }) : assert(page >= 1, 'Page must be >= 1'),
       assert(pageSize >= 1, 'PageSize must be >= 1');

  int get offset => (page - 1) * pageSize;

  PaginationParams copyWith({
    int? page,
    int? pageSize,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [page, pageSize];
}

/// Standardized Paginated Result container
class PaginatedResult<T> extends Equatable {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  int get totalPages => (totalCount / pageSize).ceil() == 0 ? 1 : (totalCount / pageSize).ceil();
  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
  int get startItemIndex => totalCount == 0 ? 0 : ((page - 1) * pageSize) + 1;
  int get endItemIndex {
    final computed = page * pageSize;
    return computed > totalCount ? totalCount : computed;
  }

  @override
  List<Object?> get props => [items, totalCount, page, pageSize];
}

/// Date range preset options
enum DateRangePreset {
  all,
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisQuarter,
  thisYear,
  custom,
}

extension DateRangePresetExtension on DateRangePreset {
  String get label {
    switch (this) {
      case DateRangePreset.all:
        return 'All Time';
      case DateRangePreset.today:
        return 'Today';
      case DateRangePreset.yesterday:
        return 'Yesterday';
      case DateRangePreset.thisWeek:
        return 'This Week';
      case DateRangePreset.lastWeek:
        return 'Last Week';
      case DateRangePreset.thisMonth:
        return 'This Month';
      case DateRangePreset.lastMonth:
        return 'Last Month';
      case DateRangePreset.thisQuarter:
        return 'This Quarter (Q)';
      case DateRangePreset.thisYear:
        return 'Financial Year (FY)';
      case DateRangePreset.custom:
        return 'Custom Range';
    }
  }
}

/// Date range filter descriptor
class DateRangeFilter extends Equatable {
  final DateRangePreset preset;
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRangeFilter({
    this.preset = DateRangePreset.all,
    this.startDate,
    this.endDate,
  });

  static DateRangeFilter calculateForPreset(DateRangePreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (preset) {
      case DateRangePreset.all:
        return const DateRangeFilter(preset: DateRangePreset.all);
      case DateRangePreset.today:
        return DateRangeFilter(
          preset: preset,
          startDate: today,
          endDate: today.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1)),
        );
      case DateRangePreset.yesterday:
        final yest = today.subtract(const Duration(days: 1));
        return DateRangeFilter(
          preset: preset,
          startDate: yest,
          endDate: today.subtract(const Duration(microseconds: 1)),
        );
      case DateRangePreset.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return DateRangeFilter(
          preset: preset,
          startDate: startOfWeek,
          endDate: now,
        );
      case DateRangePreset.lastWeek:
        final startOfLastWeek = today.subtract(Duration(days: today.weekday + 6));
        final endOfLastWeek = startOfLastWeek.add(const Duration(days: 7)).subtract(const Duration(microseconds: 1));
        return DateRangeFilter(
          preset: preset,
          startDate: startOfLastWeek,
          endDate: endOfLastWeek,
        );
      case DateRangePreset.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return DateRangeFilter(
          preset: preset,
          startDate: startOfMonth,
          endDate: now,
        );
      case DateRangePreset.lastMonth:
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59);
        return DateRangeFilter(
          preset: preset,
          startDate: startOfLastMonth,
          endDate: endOfLastMonth,
        );
      case DateRangePreset.thisQuarter:
        final quarterMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        final startOfQuarter = DateTime(now.year, quarterMonth, 1);
        return DateRangeFilter(
          preset: preset,
          startDate: startOfQuarter,
          endDate: now,
        );
      case DateRangePreset.thisYear:
        // Indian Financial Year: April 1 to March 31
        final fyStartYear = now.month >= 4 ? now.year : now.year - 1;
        final startOfFy = DateTime(fyStartYear, 4, 1);
        return DateRangeFilter(
          preset: preset,
          startDate: startOfFy,
          endDate: now,
        );
      case DateRangePreset.custom:
        return const DateRangeFilter(preset: DateRangePreset.custom);
    }
  }

  bool get hasActiveDateFilter => preset != DateRangePreset.all && (startDate != null || endDate != null);

  DateRangeFilter copyWith({
    DateRangePreset? preset,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDates = false,
  }) {
    return DateRangeFilter(
      preset: preset ?? this.preset,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }

  @override
  List<Object?> get props => [preset, startDate, endDate];
}

/// Showroom Branch Filter Value Object
class ShowroomFilter extends Equatable {
  final bool allShowrooms;
  final List<String> selectedShowroomIds;

  const ShowroomFilter({
    this.allShowrooms = true,
    this.selectedShowroomIds = const [],
  });

  bool get isFiltered => !allShowrooms && selectedShowroomIds.isNotEmpty;

  ShowroomFilter toggleShowroom(String id) {
    if (selectedShowroomIds.contains(id)) {
      final updated = List<String>.from(selectedShowroomIds)..remove(id);
      return ShowroomFilter(
        allShowrooms: updated.isEmpty,
        selectedShowroomIds: updated,
      );
    } else {
      return ShowroomFilter(
        allShowrooms: false,
        selectedShowroomIds: [...selectedShowroomIds, id],
      );
    }
  }

  ShowroomFilter copyWith({
    bool? allShowrooms,
    List<String>? selectedShowroomIds,
  }) {
    return ShowroomFilter(
      allShowrooms: allShowrooms ?? this.allShowrooms,
      selectedShowroomIds: selectedShowroomIds ?? this.selectedShowroomIds,
    );
  }

  @override
  List<Object?> get props => [allShowrooms, selectedShowroomIds];
}

/// Status Multi-Select Filter Value Object
class StatusFilter extends Equatable {
  final bool allStatuses;
  final List<String> selectedStatuses;

  const StatusFilter({
    this.allStatuses = true,
    this.selectedStatuses = const [],
  });

  bool get isFiltered => !allStatuses && selectedStatuses.isNotEmpty;

  StatusFilter toggleStatus(String statusKey) {
    if (selectedStatuses.contains(statusKey)) {
      final updated = List<String>.from(selectedStatuses)..remove(statusKey);
      return StatusFilter(
        allStatuses: updated.isEmpty,
        selectedStatuses: updated,
      );
    } else {
      return StatusFilter(
        allStatuses: false,
        selectedStatuses: [...selectedStatuses, statusKey],
      );
    }
  }

  StatusFilter copyWith({
    bool? allStatuses,
    List<String>? selectedStatuses,
  }) {
    return StatusFilter(
      allStatuses: allStatuses ?? this.allStatuses,
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
    );
  }

  @override
  List<Object?> get props => [allStatuses, selectedStatuses];
}

/// Master Unified Query Criteria Object
class AdvancedQueryCriteria extends Equatable {
  final String searchQuery;
  final List<FilterDescriptor> filters;
  final DateRangeFilter dateRange;
  final ShowroomFilter showroomFilter;
  final StatusFilter statusFilter;
  final SortDescriptor? sort;
  final PaginationParams pagination;

  const AdvancedQueryCriteria({
    this.searchQuery = '',
    this.filters = const [],
    this.dateRange = const DateRangeFilter(),
    this.showroomFilter = const ShowroomFilter(),
    this.statusFilter = const StatusFilter(),
    this.sort,
    this.pagination = const PaginationParams(),
  });

  bool get hasActiveFilters {
    return searchQuery.trim().isNotEmpty ||
        filters.any((f) => f.isActive) ||
        dateRange.hasActiveDateFilter ||
        showroomFilter.isFiltered ||
        statusFilter.isFiltered;
  }

  int get activeFiltersCount {
    int count = 0;
    if (searchQuery.trim().isNotEmpty) count++;
    count += filters.where((f) => f.isActive).length;
    if (dateRange.hasActiveDateFilter) count++;
    if (showroomFilter.isFiltered) count++;
    if (statusFilter.isFiltered) count++;
    return count;
  }

  AdvancedQueryCriteria copyWith({
    String? searchQuery,
    List<FilterDescriptor>? filters,
    DateRangeFilter? dateRange,
    ShowroomFilter? showroomFilter,
    StatusFilter? statusFilter,
    SortDescriptor? sort,
    PaginationParams? pagination,
    bool clearSort = false,
  }) {
    return AdvancedQueryCriteria(
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      dateRange: dateRange ?? this.dateRange,
      showroomFilter: showroomFilter ?? this.showroomFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      sort: clearSort ? null : (sort ?? this.sort),
      pagination: pagination ?? this.pagination,
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        filters,
        dateRange,
        showroomFilter,
        statusFilter,
        sort,
        pagination,
      ];
}

/// Dynamic In-Memory Filter Evaluator
class QueryFilterEvaluator {
  const QueryFilterEvaluator._();

  /// Evaluates an AdvancedQueryCriteria against a list of items using a property extractor map
  static PaginatedResult<T> evaluate<T>({
    required List<T> items,
    required AdvancedQueryCriteria criteria,
    required Map<String, dynamic Function(T item)> propertyExtractors,
    List<String>? searchFields,
  }) {
    List<T> filtered = List.from(items);

    // 1. Text Search across defined search fields
    if (criteria.searchQuery.trim().isNotEmpty) {
      final query = criteria.searchQuery.trim().toLowerCase();
      final fieldsToSearch = searchFields ?? propertyExtractors.keys.toList();

      filtered = filtered.where((item) {
        for (final field in fieldsToSearch) {
          final extractor = propertyExtractors[field];
          if (extractor != null) {
            final val = extractor(item);
            if (val != null && val.toString().toLowerCase().contains(query)) {
              return true;
            }
          }
        }
        return false;
      }).toList();
    }

    // 2. Status Filter
    if (criteria.statusFilter.isFiltered) {
      final statusExtractor = propertyExtractors['status'];
      if (statusExtractor != null) {
        filtered = filtered.where((item) {
          final val = statusExtractor(item)?.toString().toLowerCase();
          return criteria.statusFilter.selectedStatuses
              .map((s) => s.toLowerCase())
              .contains(val);
        }).toList();
      }
    }

    // 3. Showroom Filter
    if (criteria.showroomFilter.isFiltered) {
      final showroomExtractor = propertyExtractors['showroom_id'] ?? propertyExtractors['showroomId'];
      if (showroomExtractor != null) {
        filtered = filtered.where((item) {
          final val = showroomExtractor(item)?.toString();
          return val == null || criteria.showroomFilter.selectedShowroomIds.contains(val);
        }).toList();
      }
    }

    // 4. Date Range Filter
    if (criteria.dateRange.hasActiveDateFilter) {
      final dateExtractor = propertyExtractors['created_at'] ??
          propertyExtractors['createdAt'] ??
          propertyExtractors['date'];
      if (dateExtractor != null) {
        filtered = filtered.where((item) {
          final val = dateExtractor(item);
          if (val is DateTime) {
            if (criteria.dateRange.startDate != null && val.isBefore(criteria.dateRange.startDate!)) {
              return false;
            }
            if (criteria.dateRange.endDate != null && val.isAfter(criteria.dateRange.endDate!)) {
              return false;
            }
            return true;
          }
          return true;
        }).toList();
      }
    }

    // 5. Dynamic Rules / Filter Descriptors
    for (final rule in criteria.filters.where((r) => r.isActive)) {
      final extractor = propertyExtractors[rule.field];
      if (extractor != null) {
        filtered = filtered.where((item) {
          final val = extractor(item);
          return _evaluateOperator(val, rule.operator, rule.value, rule.secondValue);
        }).toList();
      }
    }

    // 6. Sorting
    if (criteria.sort != null) {
      final extractor = propertyExtractors[criteria.sort!.field];
      if (extractor != null) {
        filtered.sort((a, b) {
          final valA = extractor(a);
          final valB = extractor(b);

          if (valA == null && valB == null) return 0;
          if (valA == null) return criteria.sort!.isAscending ? -1 : 1;
          if (valB == null) return criteria.sort!.isAscending ? 1 : -1;

          int comp = 0;
          if (valA is Comparable && valB is Comparable) {
            comp = valA.compareTo(valB);
          } else {
            comp = valA.toString().compareTo(valB.toString());
          }

          return criteria.sort!.isAscending ? comp : -comp;
        });
      }
    }

    // 7. Pagination
    final totalCount = filtered.length;
    final page = criteria.pagination.page;
    final pageSize = criteria.pagination.pageSize;
    final offset = (page - 1) * pageSize;

    List<T> pageItems;
    if (offset >= totalCount) {
      pageItems = [];
    } else {
      final end = (offset + pageSize) > totalCount ? totalCount : (offset + pageSize);
      pageItems = filtered.sublist(offset, end);
    }

    return PaginatedResult<T>(
      items: pageItems,
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
    );
  }

  static bool _evaluateOperator(dynamic actual, FilterOperator op, dynamic target, dynamic secondTarget) {
    switch (op) {
      case FilterOperator.equals:
        return actual?.toString().toLowerCase() == target?.toString().toLowerCase();
      case FilterOperator.notEquals:
        return actual?.toString().toLowerCase() != target?.toString().toLowerCase();
      case FilterOperator.contains:
        return actual?.toString().toLowerCase().contains(target?.toString().toLowerCase() ?? '') ?? false;
      case FilterOperator.startsWith:
        return actual?.toString().toLowerCase().startsWith(target?.toString().toLowerCase() ?? '') ?? false;
      case FilterOperator.greaterThan:
        if (actual is num && target is num) return actual > target;
        if (actual is DateTime && target is DateTime) return actual.isAfter(target);
        return false;
      case FilterOperator.greaterThanOrEqual:
        if (actual is num && target is num) return actual >= target;
        if (actual is DateTime && target is DateTime) return actual.isAfter(target) || actual.isAtSameMomentAs(target);
        return false;
      case FilterOperator.lessThan:
        if (actual is num && target is num) return actual < target;
        if (actual is DateTime && target is DateTime) return actual.isBefore(target);
        return false;
      case FilterOperator.lessThanOrEqual:
        if (actual is num && target is num) return actual <= target;
        if (actual is DateTime && target is DateTime) return actual.isBefore(target) || actual.isAtSameMomentAs(target);
        return false;
      case FilterOperator.between:
        if (actual is num && target is num && secondTarget is num) {
          return actual >= target && actual <= secondTarget;
        }
        if (actual is DateTime && target is DateTime && secondTarget is DateTime) {
          return (actual.isAfter(target) || actual.isAtSameMomentAs(target)) &&
              (actual.isBefore(secondTarget) || actual.isAtSameMomentAs(secondTarget));
        }
        return false;
      case FilterOperator.inList:
        if (target is Iterable) {
          return target.any((t) => t?.toString().toLowerCase() == actual?.toString().toLowerCase());
        }
        return false;
      case FilterOperator.isNull:
        return actual == null || (actual is String && actual.trim().isEmpty);
      case FilterOperator.isNotNull:
        return actual != null && (actual is! String || actual.trim().isNotEmpty);
    }
  }
}
