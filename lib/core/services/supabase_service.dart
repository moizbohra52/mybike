import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Centralized Access to Supabase Services
class SupabaseService {
  SupabaseService._();

  /// Returns the SupabaseClient instance if initialized
  static SupabaseClient? get client {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Auth client shortcut
  static GoTrueClient? get auth => client?.auth;

  /// Current logged-in user
  static User? get currentUser => auth?.currentUser;

  /// Current user ID
  static String? get currentUserId => currentUser?.id;

  /// Is user authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Storage client shortcut
  static SupabaseStorageClient? get storage => client?.storage;

  /// Quick query builder for any table
  static SupabaseQueryBuilder? from(String table) => client?.from(table);

  /// Stands in for the round-trip Supabase would have taken.
  ///
  /// Every service falls back to seeded in-memory data when [client] is null.
  /// That resolves in a microtask, so a cubit's `isLoading` state is emitted and
  /// replaced *before the next frame* — the skeleton never paints and the page
  /// looks like it has no loading state at all. Awaiting this in a demo-data
  /// branch restores the frame boundary a real network call provides, so the
  /// loading UI is actually reachable while developing.
  ///
  /// Debug-only: a release build must never be slowed down by it.
  static Future<void> devLatency() async {
    if (kDebugMode) await Future<void>.delayed(const Duration(milliseconds: 450));
  }
}
