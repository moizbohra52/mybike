import 'package:flutter/foundation.dart';
import '../services/permission_service.dart';
import '../services/showroom_service.dart';
import '../utils/performance_optimizer.dart';

/// Enterprise Session Lifecycle and Inactivity Security Manager.
///
/// Automatically tracks user activity, enforces idle timeout limits (default: 30 minutes),
/// and performs a secure memory purge upon expiration or logout.
class SessionSecurityManager {
  static final SessionSecurityManager _instance = SessionSecurityManager._internal();
  factory SessionSecurityManager() => _instance;
  static SessionSecurityManager get instance => _instance;

  SessionSecurityManager._internal();

  /// Visible for testing to instantiate isolated managers.
  factory SessionSecurityManager.custom({
    Duration idleTimeout = const Duration(minutes: 30),
  }) {
    final mgr = SessionSecurityManager._internal();
    mgr._idleTimeout = idleTimeout;
    return mgr;
  }

  Duration _idleTimeout = const Duration(minutes: 30);
  DateTime? _lastActivityTime;

  Duration get idleTimeout => _idleTimeout;
  DateTime? get lastActivityTime => _lastActivityTime;

  /// Update the idle timeout duration.
  void setIdleTimeout(Duration duration) {
    _idleTimeout = duration;
  }

  /// Records user interaction heartbeat (touch, key press, navigation).
  void recordActivity() {
    _lastActivityTime = DateTime.now();
  }

  /// Checks whether the user's session has expired due to inactivity.
  bool get isSessionExpired {
    if (_lastActivityTime == null) return false;
    final elapsed = DateTime.now().difference(_lastActivityTime!);
    return elapsed > _idleTimeout;
  }

  /// Returns remaining time before idle session expiration.
  Duration get remainingSessionTime {
    if (_lastActivityTime == null) return _idleTimeout;
    final elapsed = DateTime.now().difference(_lastActivityTime!);
    final remaining = _idleTimeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Purges in-memory caches, session credentials, and resets context securely.
  Future<void> securePurgeSession() async {
    if (kDebugMode) {
      debugPrint('🔒 [SECURITY] Purging session memory and tenant credentials');
    }

    _lastActivityTime = null;

    // 1. Wipe client-side permissions & role cache
    PermissionService.instance.clear();

    // 2. Wipe active showroom context and persistent showroom preference
    await ShowroomService.instance.clear();

    // 3. Clear image memory cache and LRU CacheService
    PerformanceOptimizer.trimMemory();
  }
}
