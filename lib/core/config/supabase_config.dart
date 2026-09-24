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

  /// True once [initialize] has reached the live project.
  ///
  /// Deliberately separate from [isConfigured]: that one only says credentials
  /// were supplied, this one says they actually worked. Without it a wrong key
  /// is indistinguishable from demo mode — the services swallow their query
  /// errors and quietly serve the local seed data.
  static bool isLive = false;

  /// Safe Supabase initialization.
  ///
  /// Never throws: the app stays usable on local demo data when credentials are
  /// missing or rejected, but says so loudly instead of failing silently.
  static Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint('🧪 Supabase NOT connected — running on local demo data.');
      debugPrint('   Connect with: flutter run --dart-define-from-file=env.json');
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        // ignore: deprecated_member_use
        anonKey: anonKey,
        debug: kDebugMode && AppConfig.current.isDevelopment,
      );

      // One round-trip to prove the credentials actually work. The SDK's
      // initialize() only sets up the client, so a rejected key would otherwise
      // look identical to a healthy connection until the first real query.
      // ponytail: costs one request at launch; drop it if start-up latency matters.
      await Supabase.instance.client.from('settings').select('key').limit(1);
      isLive = true;
      debugPrint('✅ Supabase connected: $url');
    } catch (e, stackTrace) {
      debugPrint('❌ Supabase connection FAILED ($url): $e');
      debugPrint('   Running on local demo data. Check SUPABASE_URL / SUPABASE_ANON_KEY');
      debugPrint('   and that supabase/migrations/*.sql have been applied in order.');
      debugPrint('$stackTrace');
    }
  }
}
