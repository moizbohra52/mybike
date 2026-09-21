import 'dart:async';
import 'package:flutter/foundation.dart';

/// Represents a measured performance execution trace.
class PerformanceTrace {
  final String name;
  final int durationMs;
  final DateTime timestamp;
  final bool isSlow;

  const PerformanceTrace({
    required this.name,
    required this.durationMs,
    required this.timestamp,
    required this.isSlow,
  });

  @override
  String toString() =>
      'PerformanceTrace(name: $name, duration: ${durationMs}ms, isSlow: $isSlow, time: $timestamp)';
}

/// Latency tracer and slow operation detector for MYBIKE ERP operations.
class PerformanceProfiler {
  static final PerformanceProfiler _instance = PerformanceProfiler._internal();
  factory PerformanceProfiler() => _instance;
  static PerformanceProfiler get instance => _instance;

  PerformanceProfiler._internal({this.maxHistory = 200});

  /// Visible for testing.
  factory PerformanceProfiler.custom({int maxHistory = 200}) {
    return PerformanceProfiler._internal(maxHistory: maxHistory);
  }

  final int maxHistory;
  final List<PerformanceTrace> _traces = [];

  List<PerformanceTrace> get traces => List.unmodifiable(_traces);
  List<PerformanceTrace> get slowTraces =>
      List.unmodifiable(_traces.where((t) => t.isSlow));

  /// Trace a synchronous operation.
  T trace<T>(
    String operationName,
    T Function() operation, {
    int slowThresholdMs = 200,
  }) {
    final stopwatch = Stopwatch()..start();
    try {
      return operation();
    } finally {
      stopwatch.stop();
      _recordTrace(operationName, stopwatch.elapsedMilliseconds, slowThresholdMs);
    }
  }

  /// Trace an asynchronous operation.
  Future<T> traceAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    int slowThresholdMs = 200,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } finally {
      stopwatch.stop();
      _recordTrace(operationName, stopwatch.elapsedMilliseconds, slowThresholdMs);
    }
  }

  void _recordTrace(String name, int elapsedMs, int slowThresholdMs) {
    final isSlow = elapsedMs >= slowThresholdMs;
    final trace = PerformanceTrace(
      name: name,
      durationMs: elapsedMs,
      timestamp: DateTime.now(),
      isSlow: isSlow,
    );

    if (isSlow && kDebugMode) {
      debugPrint('⚠️ [PERF WARNING] Slow operation detected: "$name" took ${elapsedMs}ms (threshold: ${slowThresholdMs}ms)');
    }

    if (_traces.length >= maxHistory) {
      _traces.removeAt(0);
    }
    _traces.add(trace);
  }

  /// Calculate average duration for a specific operation.
  double getAverageDuration(String operationName) {
    final matching = _traces.where((t) => t.name == operationName).toList();
    if (matching.isEmpty) return 0.0;
    final total = matching.fold<int>(0, (sum, t) => sum + t.durationMs);
    return total / matching.length;
  }

  /// Clear in-memory traces.
  void clear() {
    _traces.clear();
  }
}
