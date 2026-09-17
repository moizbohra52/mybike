import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// MYBIKE Supabase Configuration Manager
class SupabaseConfig {
  SupabaseConfig._();

  // ─── Environment / Constant Credentials ───
  static const String _envUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder.supabase.co',
  );

  static const String _envAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  static String url = _envUrl;
  static String anonKey = _envAnonKey;

  /// Check if live Supabase credentials are configured
  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      !url.contains('placeholder.supabase.co') &&
      anonKey != 'placeholder-anon-key';

  /// Safe Supabase initialization
  static Future<void> initialize() async {
    try {
      if (isConfigured) {
        await Supabase.initialize(
          url: url,
          // ignore: deprecated_member_use
          anonKey: anonKey,
          debug: kDebugMode,
        );
        debugPrint('✅ Supabase initialized with live credentials');
      } else {
        debugPrint(
          'ℹ️ Supabase initialized in offline/development mode (set SUPABASE_URL & SUPABASE_ANON_KEY for live database connection)',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('⚠️ Supabase initialization warning: $e');
      debugPrint('$stackTrace');
    }
  }
}
