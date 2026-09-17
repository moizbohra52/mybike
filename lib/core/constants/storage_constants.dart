/// MYBIKE Local Storage Key Constants
///
/// Used with SharedPreferences for persisting user preferences.
abstract final class StorageConstants {
  // ─── Theme ───
  static const String themeMode = 'theme_mode';

  // ─── Session ───
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';

  // ─── Showroom ───
  static const String selectedShowroomId = 'selected_showroom_id';
  static const String selectedShowroomName = 'selected_showroom_name';

  // ─── Preferences ───
  static const String locale = 'locale';
  static const String isFirstLaunch = 'is_first_launch';
  static const String lastSyncTimestamp = 'last_sync_timestamp';
}
