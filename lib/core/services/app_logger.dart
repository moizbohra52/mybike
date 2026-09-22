import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Single structured log entry
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
    this.metadata,
  });

  String formatted() {
    final timeStr = timestamp.toIso8601String();
    final lvlStr = level.name.toUpperCase().padRight(5);
    final errorPart = error != null ? ' | Error: $error' : '';
    final metaPart = metadata != null && metadata!.isNotEmpty ? ' | Meta: $metadata' : '';
    return '[$timeStr] [$lvlStr] [$tag] $message$errorPart$metaPart';
  }
}

/// Production-Grade Structured Logger with Automatic PII Sanitization
class AppLogger {
  AppLogger._();

  static const int _maxInMemoryLogs = 200;
  static final Queue<LogEntry> _logBuffer = Queue<LogEntry>();

  /// Regex patterns for PII detection & masking
  static final RegExp _panPattern = RegExp(r'[A-Z]{5}[0-9]{4}[A-Z]{1}', caseSensitive: false);
  static final RegExp _aadhaarPattern = RegExp(r'\b\d{4}[ -]?\d{4}[ -]?\d{4}\b');
  static final RegExp _phonePattern = RegExp(r'(\+91[\-\s]?)?[6789]\d{9}');
  static final RegExp _tokenPattern = RegExp(r'(bearer\s+)?eyJ[a-zA-Z0-9_\-\.]+', caseSensitive: false);
  static final RegExp _passwordKeyPattern = RegExp(r'("?(?:password|token|secret|apiKey|auth_key)"?\s*[:=]\s*"?[^",\s\}]+"?\b)', caseSensitive: false);

  /// Sanitize sensitive data from log strings
  static String sanitize(String message) {
    var sanitized = message;

    // Mask passwords and tokens
    sanitized = sanitized.replaceAllMapped(_passwordKeyPattern, (m) => 'password: [REDACTED]');
    sanitized = sanitized.replaceAllMapped(_tokenPattern, (m) => '[TOKEN_REDACTED]');

    // Mask Aadhaar (show last 4 digits)
    sanitized = sanitized.replaceAllMapped(_aadhaarPattern, (m) {
      final clean = m.group(0)!.replaceAll(RegExp(r'[\s\-]'), '');
      if (clean.length == 12) {
        return 'XXXX-XXXX-${clean.substring(8)}';
      }
      return '[AADHAAR_REDACTED]';
    });

    // Mask PAN card (show first 2 and last 1 characters)
    sanitized = sanitized.replaceAllMapped(_panPattern, (m) {
      final pan = m.group(0)!;
      if (pan.length == 10) {
        return '${pan.substring(0, 2)}XXXXXXX${pan.substring(9)}';
      }
      return '[PAN_REDACTED]';
    });

    // Mask phone numbers (show last 4 digits)
    sanitized = sanitized.replaceAllMapped(_phonePattern, (m) {
      final phone = m.group(0)!;
      final clean = phone.replaceFirst(RegExp(r'^\+?91[\s\-]?'), '').replaceAll(RegExp(r'[\s\-]'), '');
      if (clean.length == 10) {
        return 'XXXXXX${clean.substring(6)}';
      }
      return '[PHONE_REDACTED]';
    });

    return sanitized;
  }

  /// Sanitize metadata map recursively
  static Map<String, dynamic>? sanitizeMetadata(Map<String, dynamic>? data) {
    if (data == null) return null;
    final Map<String, dynamic> clean = {};
    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      if (key.contains('password') || key.contains('token') || key.contains('secret') || key.contains('key')) {
        clean[entry.key] = '[REDACTED]';
      } else if (entry.value is String) {
        clean[entry.key] = sanitize(entry.value as String);
      } else if (entry.value is Map<String, dynamic>) {
        clean[entry.key] = sanitizeMetadata(entry.value as Map<String, dynamic>);
      } else {
        clean[entry.key] = entry.value;
      }
    }
    return clean;
  }

  static void debug(String tag, String message, {Map<String, dynamic>? metadata}) {
    _log(LogLevel.debug, tag, message, metadata: metadata);
  }

  static void info(String tag, String message, {Map<String, dynamic>? metadata}) {
    _log(LogLevel.info, tag, message, metadata: metadata);
  }

  static void warning(String tag, String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    _log(LogLevel.warning, tag, message, error: error, stackTrace: stackTrace, metadata: metadata);
  }

  static void error(String tag, String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    _log(LogLevel.error, tag, message, error: error, stackTrace: stackTrace, metadata: metadata);
  }

  static void audit(String tag, String message, {Map<String, dynamic>? metadata}) {
    _log(LogLevel.audit, tag, message, metadata: metadata);
  }

  static void _log(
    LogLevel level,
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final config = AppConfig.current;

    // Filter by configured minimum log level
    if (level.index < config.minLogLevel.index && level != LogLevel.audit) {
      return;
    }

    final sanitizedMsg = sanitize(message);
    final sanitizedMeta = sanitizeMetadata(metadata);

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: sanitizedMsg,
      error: error,
      stackTrace: stackTrace,
      metadata: sanitizedMeta,
    );

    // Buffer in memory
    _logBuffer.addLast(entry);
    if (_logBuffer.length > _maxInMemoryLogs) {
      _logBuffer.removeFirst();
    }

    // Output to console in debug / non-production or for errors
    if (kDebugMode || config.isDevelopment || level == LogLevel.error || level == LogLevel.warning || level == LogLevel.audit) {
      // ignore: avoid_print
      print(entry.formatted());
    }
  }

  /// Get in-memory log buffer for diagnostic export / bug report attachment
  static List<LogEntry> getRecentLogs() {
    return List.unmodifiable(_logBuffer);
  }

  /// Clear in-memory log buffer
  static void clearLogs() {
    _logBuffer.clear();
  }
}
