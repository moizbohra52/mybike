import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/cache_service.dart';
import 'package:mybike/core/network/request_deduplicator.dart';
import 'package:mybike/core/utils/performance_profiler.dart';
import 'package:mybike/core/utils/performance_optimizer.dart';
import 'package:mybike/core/query/pagination_helper.dart';
import 'package:mybike/core/query/query_filter_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CacheService Tests', () {
    test('Stores and retrieves values with hit/miss telemetry', () {
      final cache = CacheService.custom(maxCapacity: 10);
      expect(cache.hits, 0);
      expect(cache.misses, 0);

      // Miss
      expect(cache.get<String>('missing_key'), isNull);
      expect(cache.misses, 1);
      expect(cache.hits, 0);

      // Set and Hit
      cache.set('key1', 'value1');
      expect(cache.get<String>('key1'), equals('value1'));
      expect(cache.hits, 1);
      expect(cache.hitRatio, equals(0.5));
    });

    test('Evicts least recently used entry when max capacity is reached', () {
      final cache = CacheService.custom(maxCapacity: 3);

      cache.set('a', 'alpha');
      cache.set('b', 'beta');
      cache.set('c', 'gamma');

      expect(cache.size, 3);
      expect(cache.evictions, 0);

      // Access 'a' to make it most recently used (b becomes oldest)
      expect(cache.get('a'), 'alpha');

      // Adding 4th element should evict 'b'
      cache.set('d', 'delta');
      expect(cache.size, 3);
      expect(cache.evictions, 1);

      expect(cache.get('b'), isNull); // Evicted!
      expect(cache.get('a'), equals('alpha'));
      expect(cache.get('c'), equals('gamma'));
      expect(cache.get('d'), equals('delta'));
    });

    test('Expires entries when TTL has elapsed', () async {
      final cache = CacheService.custom(
        defaultTtl: const Duration(milliseconds: 20),
      );

      cache.set('temp', 'temporary_value', ttl: const Duration(milliseconds: 20));
      expect(cache.get('temp'), equals('temporary_value'));

      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(cache.get('temp'), isNull);
      expect(cache.containsKey('temp'), isFalse);
    });

    test('Namespaces isolate keys and support bulk namespace invalidation', () {
      final cache = CacheService.custom(maxCapacity: 50);

      cache.set('id_1', 'Vehicle Apache', namespace: 'vehicles');
      cache.set('id_2', 'Vehicle Ronin', namespace: 'vehicles');
      cache.set('id_1', 'Customer Moiz', namespace: 'customers');

      expect(cache.get('id_1', namespace: 'vehicles'), equals('Vehicle Apache'));
      expect(cache.get('id_1', namespace: 'customers'), equals('Customer Moiz'));

      // Invalidate vehicles namespace
      cache.invalidateNamespace('vehicles');

      expect(cache.get('id_1', namespace: 'vehicles'), isNull);
      expect(cache.get('id_2', namespace: 'vehicles'), isNull);
      expect(cache.get('id_1', namespace: 'customers'), equals('Customer Moiz'));
    });

    test('Cache-aside getOrFetch executes fetcher only once', () async {
      final cache = CacheService.custom(maxCapacity: 10);
      int fetchCount = 0;

      Future<String> fetchShowrooms() async {
        fetchCount++;
        return 'Showroom List Data';
      }

      final res1 = await cache.getOrFetch('list', fetchShowrooms, namespace: 'showrooms');
      final res2 = await cache.getOrFetch('list', fetchShowrooms, namespace: 'showrooms');

      expect(res1, equals('Showroom List Data'));
      expect(res2, equals('Showroom List Data'));
      expect(fetchCount, equals(1)); // Only called once
    });
  });

  group('RequestDeduplicator Tests', () {
    test('Deduplicates concurrent identical in-flight requests', () async {
      final deduplicator = RequestDeduplicator.custom();
      int executionCount = 0;

      Future<String> heavyQuery() async {
        executionCount++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return 'Query Result';
      }

      // Fire 3 simultaneous requests with identical key
      final future1 = deduplicator.runDeduplicated('tax_rates', heavyQuery);
      final future2 = deduplicator.runDeduplicated('tax_rates', heavyQuery);
      final future3 = deduplicator.runDeduplicated('tax_rates', heavyQuery);

      expect(deduplicator.isPending('tax_rates'), isTrue);

      final results = await Future.wait([future1, future2, future3]);

      expect(results[0], equals('Query Result'));
      expect(results[1], equals('Query Result'));
      expect(results[2], equals('Query Result'));
      expect(executionCount, equals(1)); // Only executed once!
      expect(deduplicator.isPending('tax_rates'), isFalse);
    });

    test('Subsequent request after completion executes again', () async {
      final deduplicator = RequestDeduplicator.custom();
      int executionCount = 0;

      Future<int> fetchNumber() async {
        executionCount++;
        return executionCount;
      }

      final first = await deduplicator.runDeduplicated('count', fetchNumber);
      expect(first, 1);

      final second = await deduplicator.runDeduplicated('count', fetchNumber);
      expect(second, 2);
      expect(executionCount, 2);
    });

    test('Cleans up in-flight state properly when an exception occurs', () async {
      final deduplicator = RequestDeduplicator.custom();

      Future<String> failingCall() async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        throw Exception('Database timeout');
      }

      await expectLater(
        deduplicator.runDeduplicated('failing_call', failingCall),
        throwsException,
      );

      // Verify not stuck in flight
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(deduplicator.isPending('failing_call'), isFalse);
    });
  });

  group('PaginationHelper Tests', () {
    test('Clamps pagination parameters to safe boundaries', () {
      const oversizedParams = PaginationParams(page: 1, pageSize: 500);
      final clamped = PaginationHelper.clamp(oversizedParams, maxPageSize: 100);

      expect(clamped.page, 1);
      expect(clamped.pageSize, 100);
    });

    test('Calculates total pages accurately', () {
      expect(PaginationHelper.calculateTotalPages(0, 25), 1);
      expect(PaginationHelper.calculateTotalPages(25, 25), 1);
      expect(PaginationHelper.calculateTotalPages(26, 25), 2);
      expect(PaginationHelper.calculateTotalPages(101, 25), 5);
    });

    test('Paginates list in-memory safely', () {
      final list = List.generate(55, (i) => 'Item $i');

      final page1 = PaginationHelper.paginateList(
        list,
        const PaginationParams(page: 1, pageSize: 20),
      );
      expect(page1.length, 20);
      expect(page1.first, 'Item 0');
      expect(page1.last, 'Item 19');

      final page3 = PaginationHelper.paginateList(
        list,
        const PaginationParams(page: 3, pageSize: 20),
      );
      expect(page3.length, 15);
      expect(page3.first, 'Item 40');
      expect(page3.last, 'Item 54');

      final pageOutOfRange = PaginationHelper.paginateList(
        list,
        const PaginationParams(page: 10, pageSize: 20),
      );
      expect(pageOutOfRange, isEmpty);
    });

    test('Creates PaginatedResult with total count and metadata', () {
      final list = List.generate(42, (i) => i);
      final result = PaginationHelper.createPaginatedResult(
        list,
        const PaginationParams(page: 2, pageSize: 10),
      );

      expect(result.totalCount, 42);
      expect(result.page, 2);
      expect(result.pageSize, 10);
      expect(result.totalPages, 5);
      expect(result.items, [10, 11, 12, 13, 14, 15, 16, 17, 18, 19]);
    });
  });

  group('PerformanceProfiler Tests', () {
    test('Measures execution latency for synchronous and asynchronous operations', () async {
      final profiler = PerformanceProfiler.custom();

      final syncResult = profiler.trace('fast_sync_op', () {
        int sum = 0;
        for (int i = 0; i < 1000; i++) {
          sum += i;
        }
        return sum;
      });

      expect(syncResult, 499500);
      expect(profiler.traces.length, 1);
      expect(profiler.traces.first.name, 'fast_sync_op');

      final asyncResult = await profiler.traceAsync(
        'simulated_db_call',
        () async {
          await Future<void>.delayed(const Duration(milliseconds: 25));
          return 'DB_SUCCESS';
        },
        slowThresholdMs: 15, // Low threshold to test slow operation flag
      );

      expect(asyncResult, 'DB_SUCCESS');
      expect(profiler.traces.length, 2);
      expect(profiler.slowTraces.length, 1);
      expect(profiler.slowTraces.first.name, 'simulated_db_call');
      expect(profiler.slowTraces.first.isSlow, isTrue);
    });
  });

  group('PerformanceOptimizer Tests', () {
    test('Initializes PerformanceOptimizer and trims memory safely', () async {
      final elapsedMs = await PerformanceOptimizer.initialize();
      expect(elapsedMs, isNonNegative);
      expect(PerformanceOptimizer.isInitialized, isTrue);

      // Ensure trimMemory executes cleanly without throwing
      expect(() => PerformanceOptimizer.trimMemory(), returnsNormally);
    });
  });
}
