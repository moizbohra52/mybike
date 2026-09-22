import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Note: assuming these services exist, they might need adjustments based on exact location
// import '../../services/permission_service.dart';
// import '../../services/showroom_service.dart';

class SessionSecurityManager {
  static final SessionSecurityManager _instance = SessionSecurityManager._internal();
  static SessionSecurityManager get instance => _instance;
  
  SessionSecurityManager._internal();

  /// Default idle timeout is 30 minutes
  Duration _idleTimeout = const Duration(minutes: 30);
  DateTime? _lastActivityTime;
  Timer? _idleTimer;
  
  /// Callbacks to execute on session expiration
  final List<VoidCallback> _onSessionExpiredCallbacks = [];

  void initialize({Duration? timeoutDuration}) {
    if (timeoutDuration != null) {
      _idleTimeout = timeoutDuration;
    }
    _lastActivityTime = DateTime.now();
    _startTimer();
  }

  /// Records user activity (touch, scroll, navigation) to keep session alive
  void recordActivity() {
    _lastActivityTime = DateTime.now();
    _startTimer();
  }

  /// Registers a callback to be notified when the session expires
  void onSessionExpired(VoidCallback callback) {
    if (!_onSessionExpiredCallbacks.contains(callback)) {
      _onSessionExpiredCallbacks.add(callback);
    }
  }

  void _startTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleTimeout, _handleSessionTimeout);
  }

  /// Returns true if the session has expired due to inactivity
  bool get isSessionExpired {
    if (_lastActivityTime == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_lastActivityTime!);
    return difference >= _idleTimeout;
  }

  Future<void> _handleSessionTimeout() async {
    debugPrint('Session expired due to inactivity. Purging secure data...');
    await _securePurge();
    
    for (final callback in _onSessionExpiredCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('Error in session expiration callback: $e');
      }
    }
  }

  /// Manually force a session logout and purge
  Future<void> forceLogout() async {
    _idleTimer?.cancel();
    await _securePurge();
  }

  Future<void> _securePurge() async {
    try {
      // Clear auth tokens
      await Supabase.instance.client.auth.signOut();
      
      // We would clear services like this in a real app:
      // PermissionService.instance.clearCache();
      // ShowroomService.instance.clearContext();
      // CacheService.instance.purgeSensitiveData();
      
      _lastActivityTime = null;
    } catch (e) {
      debugPrint('Error during secure purge: $e');
    }
  }
  
  void dispose() {
    _idleTimer?.cancel();
    _onSessionExpiredCallbacks.clear();
  }
}
