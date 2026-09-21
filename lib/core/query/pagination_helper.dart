import 'dart:math';
import 'query_filter_models.dart';

/// Helper utility for safe pagination, boundary clamping, and payload limiting.
class PaginationHelper {
  PaginationHelper._();

  /// Default upper bound for maximum records per page request across MYBIKE ERP.
  static const int kMaxAllowedPageSize = 100;
  static const int kDefaultPageSize = 25;

  /// Clamps pagination parameters to safe boundaries to prevent memory exhaustion.
  static PaginationParams clamp(
    PaginationParams params, {
    int maxPageSize = kMaxAllowedPageSize,
  }) {
    final clampedPage = max(1, params.page);
    final clampedSize = max(1, min(maxPageSize, params.pageSize));
    return PaginationParams(page: clampedPage, pageSize: clampedSize);
  }

  /// Calculates the total number of pages given total items and page size.
  static int calculateTotalPages(int totalItems, int pageSize) {
    if (totalItems <= 0 || pageSize <= 0) return 1;
    return (totalItems / pageSize).ceil();
  }

  /// Extracts a safe paginated sublist from an in-memory collection.
  static List<T> paginateList<T>(
    List<T> items,
    PaginationParams params, {
    int maxPageSize = kMaxAllowedPageSize,
  }) {
    if (items.isEmpty) return <T>[];

    final safeParams = clamp(params, maxPageSize: maxPageSize);
    final start = safeParams.offset;
    if (start >= items.length) return <T>[];

    final end = min(start + safeParams.pageSize, items.length);
    return items.sublist(start, end);
  }

  /// Wraps an in-memory collection into a standardized [PaginatedResult].
  static PaginatedResult<T> createPaginatedResult<T>(
    List<T> allItems,
    PaginationParams params, {
    int maxPageSize = kMaxAllowedPageSize,
  }) {
    final safeParams = clamp(params, maxPageSize: maxPageSize);
    final pagedItems = paginateList(allItems, safeParams, maxPageSize: maxPageSize);
    return PaginatedResult<T>(
      items: pagedItems,
      totalCount: allItems.length,
      page: safeParams.page,
      pageSize: safeParams.pageSize,
    );
  }
}
