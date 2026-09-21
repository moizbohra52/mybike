import 'dart:async';
import 'dart:collection';

/// A wrapper around a cached value tracking creation time and time-to-live.
class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final DateTime? expiresAt;

  CacheEntry({
    required this.value,
    required this.createdAt,
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}

/// High-performance, thread-safe in-memory LRU Cache with TTL and Namespace support.
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  static CacheService get instance => _instance;

  CacheService._internal({
    this.maxCapacity = 500,
    this.defaultTtl = const Duration(minutes: 10),
  });

  /// Visible for testing to instantiate isolated cache instances.
  factory CacheService.custom({
    int maxCapacity = 500,
    Duration defaultTtl = const Duration(minutes: 10),
  }) {
    return CacheService._internal(
      maxCapacity: maxCapacity,
      defaultTtl: defaultTtl,
    );
  }

  final int maxCapacity;
  final Duration defaultTtl;

  // LinkedHashMap maintains iteration order based on insertion/update.
  final LinkedHashMap<String, CacheEntry<dynamic>> _cache = LinkedHashMap();

  // Telemetry metrics
  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;

  int get hits => _hits;
  int get misses => _misses;
  int get evictions => _evictions;
  int get size => _cache.length;

  double get hitRatio {
    final total = _hits + _misses;
    if (total == 0) return 0.0;
    return _hits / total;
  }

  String _buildKey(String key, String? namespace) {
    final ns = namespace != null && namespace.isNotEmpty ? namespace.trim() : 'global';
    return '$ns:$key';
  }

  /// Retrieve a cached value if present and unexpired.
  T? get<T>(String key, {String? namespace}) {
    final compositeKey = _buildKey(key, namespace);
    final entry = _cache[compositeKey];

    if (entry == null) {
      _misses++;
      return null;
    }

    if (entry.isExpired) {
      _cache.remove(compositeKey);
      _misses++;
      return null;
    }

    // Refresh LRU order: remove and re-insert at the end
    _cache.remove(compositeKey);
    _cache[compositeKey] = entry;

    _hits++;
    return entry.value as T;
  }

  /// Store a value in the cache with optional custom TTL.
  void set<T>(
    String key,
    T value, {
    String? namespace,
    Duration? ttl,
  }) {
    final compositeKey = _buildKey(key, namespace);
    final effectiveTtl = ttl ?? defaultTtl;
    final now = DateTime.now();

    final entry = CacheEntry<T>(
      value: value,
      createdAt: now,
      expiresAt: effectiveTtl > Duration.zero ? now.add(effectiveTtl) : null,
    );

    if (_cache.containsKey(compositeKey)) {
      _cache.remove(compositeKey);
    } else if (_cache.length >= maxCapacity) {
      // Evict least recently used (first element in LinkedHashMap)
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
      _evictions++;
    }

    _cache[compositeKey] = entry;
  }

  /// Cache-aside pattern: Returns cached value or executes fetcher and caches the result.
  Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetcher, {
    String? namespace,
    Duration? ttl,
  }) async {
    final cached = get<T>(key, namespace: namespace);
    if (cached != null) {
      return cached;
    }

    final fresh = await fetcher();
    set<T>(key, fresh, namespace: namespace, ttl: ttl);
    return fresh;
  }

  /// Checks if key exists and is not expired without updating LRU order or metrics.
  bool containsKey(String key, {String? namespace}) {
    final compositeKey = _buildKey(key, namespace);
    final entry = _cache[compositeKey];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(compositeKey);
      return false;
    }
    return true;
  }

  /// Invalidate a specific key.
  void invalidateKey(String key, {String? namespace}) {
    final compositeKey = _buildKey(key, namespace);
    _cache.remove(compositeKey);
  }

  /// Invalidate all keys under a given namespace.
  void invalidateNamespace(String namespace) {
    final prefix = '${namespace.trim()}:';
    final keysToRemove = _cache.keys.where((k) => k.startsWith(prefix)).toList();
    for (final k in keysToRemove) {
      _cache.remove(k);
    }
  }

  /// Remove all cached entries.
  void clear() {
    _cache.clear();
  }

  /// Reset telemetry metrics.
  void resetStats() {
    _hits = 0;
    _misses = 0;
    _evictions = 0;
  }
}
