import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/common/components/search_filters/cubit/search_filter_cubit.dart';
import 'package:mybike/core/query/query_filter_models.dart';
import 'package:mybike/core/services/global_search_service.dart';

class SampleVehicleRecord {
  final String id;
  final String vin;
  final String model;
  final double price;
  final String status;
  final String showroomId;
  final DateTime createdAt;

  SampleVehicleRecord({
    required this.id,
    required this.vin,
    required this.model,
    required this.price,
    required this.status,
    required this.showroomId,
    required this.createdAt,
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleVehicles = [
    SampleVehicleRecord(
      id: 'v-1',
      vin: 'VIN-ACT-001',
      model: 'Honda Activa 6G Standard',
      price: 82000.0,
      status: 'in_stock',
      showroomId: 'sh-01',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SampleVehicleRecord(
      id: 'v-2',
      vin: 'VIN-ACT-002',
      model: 'Honda Activa 6G Deluxe',
      price: 87500.0,
      status: 'booked',
      showroomId: 'sh-01',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    SampleVehicleRecord(
      id: 'v-3',
      vin: 'VIN-SHN-001',
      model: 'Honda CB Shine 125',
      price: 94000.0,
      status: 'in_stock',
      showroomId: 'sh-02',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SampleVehicleRecord(
      id: 'v-4',
      vin: 'VIN-JUP-001',
      model: 'TVS Jupiter 110 ZX',
      price: 91000.0,
      status: 'delivered',
      showroomId: 'sh-02',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    SampleVehicleRecord(
      id: 'v-5',
      vin: 'VIN-DIO-001',
      model: 'Honda Dio 125 Repsol',
      price: 96000.0,
      status: 'in_stock',
      showroomId: 'sh-01',
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
    ),
  ];

  final extractors = <String, dynamic Function(SampleVehicleRecord)>{
    'id': (item) => item.id,
    'vin': (item) => item.vin,
    'model': (item) => item.model,
    'price': (item) => item.price,
    'status': (item) => item.status,
    'showroomId': (item) => item.showroomId,
    'createdAt': (item) => item.createdAt,
  };

  group('Phase 22: Query Filter Models & Operators', () {
    test('FilterOperator labels and descriptions are descriptive', () {
      expect(FilterOperator.equals.label, contains('Equals'));
      expect(FilterOperator.greaterThan.label, contains('Greater Than'));
      expect(FilterOperator.between.label, contains('Between'));
      expect(FilterOperator.inList.label, contains('In List'));
    });

    test('DateRangeFilter presets calculate accurate business date bounds', () {
      final todayFilter = DateRangeFilter.calculateForPreset(DateRangePreset.today);
      expect(todayFilter.hasActiveDateFilter, isTrue);
      expect(todayFilter.startDate, isNotNull);
      expect(todayFilter.endDate, isNotNull);

      final thisMonthFilter = DateRangeFilter.calculateForPreset(DateRangePreset.thisMonth);
      expect(thisMonthFilter.startDate!.day, equals(1));

      final fyFilter = DateRangeFilter.calculateForPreset(DateRangePreset.thisYear);
      expect(fyFilter.startDate!.month, equals(4)); // April FY start
    });

    test('SortDescriptor toggles ascending and descending correctly', () {
      const sort = SortDescriptor(field: 'price', label: 'Price');
      expect(sort.isAscending, isTrue);

      final toggled = sort.toggleDirection();
      expect(toggled.isDescending, isTrue);
      expect(toggled.direction, equals(SortDirection.descending));

      final toggledBack = toggled.toggleDirection();
      expect(toggledBack.isAscending, isTrue);
    });

    test('PaginationParams computes offsets and PaginatedResult calculates ranges', () {
      const params = PaginationParams(page: 2, pageSize: 25);
      expect(params.offset, equals(25));

      final result = PaginatedResult<String>(
        items: const ['item1', 'item2'],
        totalCount: 48,
        page: 2,
        pageSize: 25,
      );

      expect(result.totalPages, equals(2));
      expect(result.hasNextPage, isFalse);
      expect(result.hasPreviousPage, isTrue);
      expect(result.startItemIndex, equals(26));
      expect(result.endItemIndex, equals(48));
    });
  });

  group('Phase 22: QueryFilterEvaluator In-Memory Engine', () {
    test('filters records by text search query across properties', () {
      const criteria = AdvancedQueryCriteria(searchQuery: 'Activa');
      final result = QueryFilterEvaluator.evaluate(
        items: sampleVehicles,
        criteria: criteria,
        propertyExtractors: extractors,
      );

      expect(result.items.length, equals(2));
      expect(result.items.every((v) => v.model.contains('Activa')), isTrue);
    });

    test('filters records by status multi-select', () {
      const criteria = AdvancedQueryCriteria(
        statusFilter: StatusFilter(
          allStatuses: false,
          selectedStatuses: ['in_stock'],
        ),
      );
      final result = QueryFilterEvaluator.evaluate(
        items: sampleVehicles,
        criteria: criteria,
        propertyExtractors: extractors,
      );

      expect(result.items.length, equals(3));
      expect(result.items.every((v) => v.status == 'in_stock'), isTrue);
    });

    test('filters records by showroom tenancy', () {
      const criteria = AdvancedQueryCriteria(
        showroomFilter: ShowroomFilter(
          allShowrooms: false,
          selectedShowroomIds: ['sh-02'],
        ),
      );
      final result = QueryFilterEvaluator.evaluate(
        items: sampleVehicles,
        criteria: criteria,
        propertyExtractors: extractors,
      );

      expect(result.items.length, equals(2));
      expect(result.items.every((v) => v.showroomId == 'sh-02'), isTrue);
    });

    test('evaluates dynamic numerical filter rules (greater than & between)', () {
      // 1. Greater than: Price > 90,000
      final gtCriteria = const AdvancedQueryCriteria(
        filters: [
          FilterDescriptor(
            field: 'price',
            label: 'Price',
            operator: FilterOperator.greaterThan,
            value: 90000.0,
          ),
        ],
      );

      final gtResult = QueryFilterEvaluator.evaluate(
        items: sampleVehicles,
        criteria: gtCriteria,
        propertyExtractors: extractors,
      );

      expect(gtResult.items.length, equals(3));
      expect(gtResult.items.every((v) => v.price > 90000), isTrue);

      // 2. Between: Price between 85,000 and 95,000
      final betweenCriteria = const AdvancedQueryCriteria(
        filters: [
          FilterDescriptor(
            field: 'price',
            label: 'Price',
            operator: FilterOperator.between,
            value: 85000.0,
            secondValue: 95000.0,
          ),
        ],
      );

      final betweenResult = QueryFilterEvaluator.evaluate(
        items: sampleVehicles,
        criteria: betweenCriteria,
        propertyExtractors: extractors,
      );

      expect(betweenResult.items.length, equals(3));
      expect(betweenResult.items.every((v) => v.price >= 85000 && v.price <= 95000), isTrue);
    });

    test('sorts records ascending and descending', () {
      // Sort price descending
      final descCriteria = const AdvancedQueryCriteria(
        sort: SortDescriptor(
          field: 'price',
          label: 'Price',
          direction: SortDirection.descending,
        ),
      );

      final descResult = QueryFilterEvaluator.evaluate(
        items: sampleVehicles,
        criteria: descCriteria,
        propertyExtractors: extractors,
      );

      expect(descResult.items.first.price, equals(96000.0));
      expect(descResult.items.last.price, equals(82000.0));

      // Sort price ascending
      final ascCriteria = const AdvancedQueryCriteria(
        sort: SortDescriptor(
          field: 'price',
          label: 'Price',
          direction: SortDirection.ascending,
        ),
      );

      final ascResult = QueryFilterEvaluator.evaluate(
        items: sampleVehicles,
        criteria: ascCriteria,
        propertyExtractors: extractors,
      );

      expect(ascResult.items.first.price, equals(82000.0));
      expect(ascResult.items.last.price, equals(96000.0));
    });

    test('applies pagination slicing accurately', () {
      const page1Criteria = AdvancedQueryCriteria(
        pagination: PaginationParams(page: 1, pageSize: 2),
      );

      final page1Result = QueryFilterEvaluator.evaluate(
        items: sampleVehicles,
        criteria: page1Criteria,
        propertyExtractors: extractors,
      );

      expect(page1Result.items.length, equals(2));
      expect(page1Result.totalCount, equals(5));
      expect(page1Result.totalPages, equals(3));
      expect(page1Result.hasNextPage, isTrue);

      const page3Criteria = AdvancedQueryCriteria(
        pagination: PaginationParams(page: 3, pageSize: 2),
      );

      final page3Result = QueryFilterEvaluator.evaluate(
        items: sampleVehicles,
        criteria: page3Criteria,
        propertyExtractors: extractors,
      );

      expect(page3Result.items.length, equals(1)); // Remaining item
      expect(page3Result.hasNextPage, isFalse);
    });
  });

  group('Phase 22: GlobalSearchService (Command Palette)', () {
    test('searches across multiple modules and returns categorized hits', () async {
      final service = GlobalSearchService.instance;

      // Search for vehicle
      final vehHits = await service.search('Activa');
      expect(vehHits.isNotEmpty, isTrue);
      expect(vehHits.any((h) => h.category == SearchCategory.vehicles), isTrue);

      // Search for customer
      final custHits = await service.search('Amit');
      expect(custHits.isNotEmpty, isTrue);
      expect(custHits.any((h) => h.category == SearchCategory.customers), isTrue);

      // Search for inventory part
      final invHits = await service.search('Filter');
      expect(invHits.isNotEmpty, isTrue);
      expect(invHits.any((h) => h.category == SearchCategory.inventory), isTrue);
    });

    test('manages recent searches history', () {
      final service = GlobalSearchService.instance;
      service.clearRecentSearches();

      service.addRecentSearch('Honda Activa');
      service.addRecentSearch('VIN-12345');

      expect(service.recentSearches.length, equals(2));
      expect(service.recentSearches.first, equals('VIN-12345'));

      service.clearRecentSearches();
      expect(service.recentSearches.isEmpty, isTrue);
    });
  });

  group('Phase 22: SearchFilterCubit State Management', () {
    test('updates search query, date presets, statuses, and pagination', () {
      AdvancedQueryCriteria? notified;
      final cubit = SearchFilterCubit(
        onCriteriaChanged: (c) => notified = c,
      );

      // 1. Search Query
      cubit.setSearchQuery('Jupiter');
      expect(cubit.state.criteria.searchQuery, equals('Jupiter'));
      expect(notified?.searchQuery, equals('Jupiter'));

      // 2. Date preset
      cubit.setDateRangePreset(DateRangePreset.thisMonth);
      expect(cubit.state.criteria.dateRange.preset, equals(DateRangePreset.thisMonth));

      // 3. Status toggle
      cubit.toggleStatus('in_stock');
      expect(cubit.state.criteria.statusFilter.selectedStatuses, contains('in_stock'));

      // 4. Dynamic Rule
      cubit.addFilter(const FilterDescriptor(
        field: 'price',
        label: 'Price',
        operator: FilterOperator.greaterThan,
        value: 50000,
      ));
      expect(cubit.state.criteria.filters.length, equals(1));

      // 5. Pagination
      cubit.setPage(3);
      expect(cubit.state.criteria.pagination.page, equals(3));
      cubit.setPageSize(50);
      expect(cubit.state.criteria.pagination.pageSize, equals(50));

      // 6. Reset
      cubit.resetAllFilters();
      expect(cubit.state.hasActiveFilters, isFalse);

      cubit.close();
    });
  });
}
