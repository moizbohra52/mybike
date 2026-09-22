/// Centralized application version, build channel, and release metadata.
class AppVersion {
  const AppVersion._();

  static const String appName = 'MYBIKE ERP';
  static const String appTagline = 'Multi-Showroom Automotive Dealership & Accounting ERP';
  static const String major = '1';
  static const String minor = '0';
  static const String patch = '0';
  static const int buildNumber = 100;
  static const String buildChannel = 'release';
  static const String releaseDate = '2026-09-22';
  static const String copyright = '© 2026 MYBIKE Automotives Pvt Ltd. All rights reserved.';

  /// Full Semantic Versioning String: e.g. "1.0.0+100"
  static String get fullVersion => '$major.$minor.$patch+$buildNumber';

  /// Human-friendly display string: e.g. "v1.0.0 (Build 100)"
  static String get displayVersion => 'v$major.$minor.$patch (Build $buildNumber)';

  /// Compact header badge: e.g. "v1.0.0"
  static String get shortVersion => 'v$major.$minor.$patch';
}
