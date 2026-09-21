import 'dart:async';

/// Request Deduplicator to join concurrent identical in-flight network/database requests.
///
/// Prevents redundant parallel calls across widgets, cubits, or services by coalescing
/// concurrent calls with the same key into a single shared Future.
class RequestDeduplicator {
  static final RequestDeduplicator _instance = RequestDeduplicator._internal();
  factory RequestDeduplicator() => _instance;
  static RequestDeduplicator get instance => _instance;

  RequestDeduplicator._internal();

  /// Visible for testing to create isolated deduplicators.
  factory RequestDeduplicator.custom() => RequestDeduplicator._internal();

  final Map<String, Completer<dynamic>> _inFlight = {};

  /// Current number of in-flight deduplicated requests.
  int get pendingCount => _inFlight.length;

  /// Check whether a specific request key is currently in-flight.
  bool isPending(String requestKey) => _inFlight.containsKey(requestKey);

  /// Run [action] deduplicated by [requestKey].
  ///
  /// If a request with [requestKey] is already executing, subsequent callers
  /// will receive the result of the ongoing execution without initiating a new call.
  Future<T> runDeduplicated<T>(
    String requestKey,
    Future<T> Function() action,
  ) async {
    final existing = _inFlight[requestKey];
    if (existing != null) {
      return (await existing.future) as T;
    }

    final completer = Completer<T>();
    // Suppress unhandled error in zone if no concurrent callers listen
    completer.future.ignore();
    _inFlight[requestKey] = completer;

    try {
      final result = await action();
      completer.complete(result);
      return result;
    } catch (e, stack) {
      completer.completeError(e, stack);
      rethrow;
    } finally {
      _inFlight.remove(requestKey);
    }
  }

  /// Cancels/clears tracked in-flight requests.
  void clear() {
    _inFlight.clear();
  }
}
