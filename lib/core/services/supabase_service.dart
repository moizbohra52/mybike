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

  /// Check connectivity to Supabase backend
  static Future<bool> checkConnection() async {
    if (!SupabaseConfig.isConfigured) return false;
    try {
      final res = await client?.from('settings').select('key').limit(1);
      return res != null;
    } catch (e) {
      debugPrint('Supabase connection check failed: $e');
      return false;
    }
  }
}
