/// MYBIKE Application-wide Constants
abstract final class AppConstants {
  // ─── App Identity ───
  static const String appName = 'MYBIKE';
  static const String appTagline = 'Bike Dealership Management';
  static const String appVersion = '1.0.0';

  // ─── Pagination ───
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ─── Debounce ───
  static const Duration searchDebounce = Duration(milliseconds: 400);
  static const Duration inputDebounce = Duration(milliseconds: 300);

  // ─── Timeouts ───
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ─── Animation ───
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ─── Date / Time Formats ───
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy hh:mm a';
  static const String timeFormat = 'hh:mm a';
  static const String monthYearFormat = 'MMM yyyy';
  static const String financialYearFormat = 'yyyy-yy'; // e.g., 2026-27

  // ─── Currency ───
  static const String defaultCurrencyCode = 'INR';
  static const String defaultCurrencySymbol = '₹';
  static const int currencyDecimalPlaces = 2;

  // ─── Financial Year (Indian) ───
  static const int financialYearStartMonth = 4; // April
  static const int financialYearStartDay = 1;

  // ─── File Upload ───
  static const int maxFileSizeMB = 10;
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];
}
