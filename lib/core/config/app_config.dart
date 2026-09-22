import 'app_version.dart';

/// MYBIKE Environment Enumeration
enum Environment {
  development,
  staging,
  production;

  static Environment fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'prod':
      case 'production':
        return Environment.production;
      case 'stage':
      case 'staging':
        return Environment.staging;
      case 'dev':
      case 'development':
      default:
        return Environment.development;
    }
  }
}

/// Structured Log Levels for runtime filtering
enum LogLevel { debug, info, warning, error, audit, none }

/// Centralized Application Configuration
///
/// Supports runtime presets and compile-time `--dart-define` overrides:
/// - `MYBIKE_ENV` (`development` | `staging` | `production`)
/// - `SUPABASE_URL`
/// - `SUPABASE_ANON_KEY`
/// - `FCM_PROJECT_ID`
class AppConfig {
  final Environment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String appName;
  final String fcmProjectId;
  final LogLevel minLogLevel;
  final bool enableDevOfflineFallback;
  final bool enableAuditLogTelemetry;

  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.appName = AppVersion.appName,
    this.fcmProjectId = 'mybike-erp-fcm',
    this.minLogLevel = LogLevel.info,
    this.enableDevOfflineFallback = false,
    this.enableAuditLogTelemetry = true,
  });

  /// Compile-time `--dart-define` overrides
  static const String _envDefine = String.fromEnvironment('MYBIKE_ENV', defaultValue: '');
  static const String _urlDefine = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String _anonKeyDefine = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const String _fcmDefine = String.fromEnvironment('FCM_PROJECT_ID', defaultValue: '');

  /// Development configuration preset
  static const AppConfig development = AppConfig(
    environment: Environment.development,
    supabaseUrl: 'https://dev-erp.mybike.internal',
    supabaseAnonKey: 'dev_anon_key_placeholder',
    appName: 'MYBIKE ERP (Dev)',
    fcmProjectId: 'mybike-erp-dev',
    minLogLevel: LogLevel.debug,
    enableDevOfflineFallback: true,
    enableAuditLogTelemetry: true,
  );

  /// Staging configuration preset
  static const AppConfig staging = AppConfig(
    environment: Environment.staging,
    supabaseUrl: 'https://staging-erp.mybike.internal',
    supabaseAnonKey: 'staging_anon_key_placeholder',
    appName: 'MYBIKE ERP (Staging)',
    fcmProjectId: 'mybike-erp-staging',
    minLogLevel: LogLevel.info,
    enableDevOfflineFallback: false,
    enableAuditLogTelemetry: true,
  );

  /// Production configuration preset
  static const AppConfig production = AppConfig(
    environment: Environment.production,
    supabaseUrl: 'https://api.mybike.internal',
    supabaseAnonKey: 'prod_anon_key_secure_placeholder',
    appName: 'MYBIKE ERP',
    fcmProjectId: 'mybike-erp-prod',
    minLogLevel: LogLevel.warning,
    enableDevOfflineFallback: false,
    enableAuditLogTelemetry: true,
  );

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;

  /// Currently active configuration.
  static AppConfig current = _resolveInitialConfig();

  /// Resolve initial configuration based on compile-time `--dart-define` or default to `development`
  static AppConfig _resolveInitialConfig() {
    if (_envDefine.isNotEmpty) {
      final env = Environment.fromString(_envDefine);
      final base = switch (env) {
        Environment.production => production,
        Environment.staging => staging,
        Environment.development => development,
      };

      return AppConfig(
        environment: env,
        supabaseUrl: _urlDefine.isNotEmpty ? _urlDefine : base.supabaseUrl,
        supabaseAnonKey: _anonKeyDefine.isNotEmpty ? _anonKeyDefine : base.supabaseAnonKey,
        appName: base.appName,
        fcmProjectId: _fcmDefine.isNotEmpty ? _fcmDefine : base.fcmProjectId,
        minLogLevel: base.minLogLevel,
        enableDevOfflineFallback: base.enableDevOfflineFallback,
        enableAuditLogTelemetry: base.enableAuditLogTelemetry,
      );
    }
    return development;
  }

  /// Switch active environment dynamically at runtime (useful for testing & switching profiles)
  static void setEnvironment(Environment env, {String? customUrl, String? customAnonKey}) {
    final base = switch (env) {
      Environment.production => production,
      Environment.staging => staging,
      Environment.development => development,
    };

    current = AppConfig(
      environment: env,
      supabaseUrl: customUrl ?? base.supabaseUrl,
      supabaseAnonKey: customAnonKey ?? base.supabaseAnonKey,
      appName: base.appName,
      fcmProjectId: base.fcmProjectId,
      minLogLevel: base.minLogLevel,
      enableDevOfflineFallback: base.enableDevOfflineFallback,
      enableAuditLogTelemetry: base.enableAuditLogTelemetry,
    );
  }
}
