/// MYBIKE Environment Configuration
///
/// Handles environment-specific settings (dev/staging/prod).
/// Supabase URL and anon key will be set in later phases.
enum Environment { development, staging, production }

class AppConfig {
  final Environment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String appName;
  final bool enableLogging;

  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.appName = 'MYBIKE',
    this.enableLogging = false,
  });

  /// Development configuration
  static const AppConfig development = AppConfig(
    environment: Environment.development,
    supabaseUrl: 'YOUR_SUPABASE_URL',
    supabaseAnonKey: 'YOUR_SUPABASE_ANON_KEY',
    enableLogging: true,
  );

  /// Staging configuration
  static const AppConfig staging = AppConfig(
    environment: Environment.staging,
    supabaseUrl: 'YOUR_STAGING_SUPABASE_URL',
    supabaseAnonKey: 'YOUR_STAGING_SUPABASE_ANON_KEY',
    enableLogging: true,
  );

  /// Production configuration
  static const AppConfig production = AppConfig(
    environment: Environment.production,
    supabaseUrl: 'YOUR_PROD_SUPABASE_URL',
    supabaseAnonKey: 'YOUR_PROD_SUPABASE_ANON_KEY',
    enableLogging: false,
  );

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;

  /// Currently active configuration.
  /// Change this to switch environments.
  static AppConfig current = development;
}
