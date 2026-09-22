import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';

/// MYBIKE Supabase Configuration Manager
class SupabaseConfig {
  SupabaseConfig._();

  static String get url => AppConfig.current.supabaseUrl;
  static String get anonKey => AppConfig.current.supabaseAnonKey;

  /// Check if live Supabase credentials are configured
  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      !url.contains('placeholder') &&
      !url.contains('internal') &&
      anonKey != 'dev_anon_key_placeholder' &&
      anonKey != 'prod_anon_key_secure_placeholder' &&
      anonKey != 'staging_anon_key_placeholder';

  /// Safe Supabase initialization
  static Future<void> initialize() async {
    try {
      if (isConfigured) {
        await Supabase.initialize(
          url: url,
          // ignore: deprecated_member_use
          anonKey: anonKey,
          debug: kDebugMode && AppConfig.current.isDevelopment,
        );
        debugPrint('✅ Supabase initialized with live credentials ($url)');
      } else {
        debugPrint(
          'ℹ️ Supabase initialized in [${AppConfig.current.environment.name.toUpperCase()}] mode (live server URL: $url)',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('⚠️ Supabase initialization warning: $e');
      debugPrint('$stackTrace');
    }
  }
}
