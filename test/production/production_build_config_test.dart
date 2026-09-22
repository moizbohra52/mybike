import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/config/app_version.dart';
import 'package:mybike/core/config/app_config.dart';
import 'package:mybike/core/config/supabase_config.dart';
import 'package:mybike/core/services/app_logger.dart';

void main() {
  group('Phase 27 — Production Build & Versioning Configuration', () {
    test('1. AppVersion metadata adheres to semantic versioning and release specifications', () {
      expect(AppVersion.appName, equals('MYBIKE ERP'));
      expect(AppVersion.major, equals('1'));
      expect(AppVersion.minor, equals('0'));
      expect(AppVersion.patch, equals('0'));
      expect(AppVersion.buildNumber, equals(100));
      expect(AppVersion.fullVersion, equals('1.0.0+100'));
      expect(AppVersion.displayVersion, contains('v1.0.0 (Build 100)'));
      expect(AppVersion.shortVersion, equals('v1.0.0'));
      expect(AppVersion.copyright, contains('MYBIKE Automotives Pvt Ltd'));
      expect(AppVersion.buildChannel, equals('release'));
    });

    test('2. AppConfig environment switching and preset characteristics', () {
      // Test Development preset
      AppConfig.setEnvironment(Environment.development);
      expect(AppConfig.current.isDevelopment, isTrue);
      expect(AppConfig.current.isProduction, isFalse);
      expect(AppConfig.current.minLogLevel, equals(LogLevel.debug));
      expect(AppConfig.current.enableDevOfflineFallback, isTrue);

      // Test Staging preset
      AppConfig.setEnvironment(Environment.staging);
      expect(AppConfig.current.isStaging, isTrue);
      expect(AppConfig.current.isProduction, isFalse);
      expect(AppConfig.current.minLogLevel, equals(LogLevel.info));
      expect(AppConfig.current.enableDevOfflineFallback, isFalse);

      // Test Production preset
      AppConfig.setEnvironment(Environment.production);
      expect(AppConfig.current.isProduction, isTrue);
      expect(AppConfig.current.isDevelopment, isFalse);
      expect(AppConfig.current.appName, equals('MYBIKE ERP'));
      expect(AppConfig.current.minLogLevel, equals(LogLevel.warning));
      expect(AppConfig.current.enableDevOfflineFallback, isFalse);

      // Custom URL override
      AppConfig.setEnvironment(
        Environment.production,
        customUrl: 'https://custom-erp.mybike.in',
        customAnonKey: 'custom_key_123',
      );
      expect(AppConfig.current.supabaseUrl, equals('https://custom-erp.mybike.in'));
      expect(AppConfig.current.supabaseAnonKey, equals('custom_key_123'));
      expect(SupabaseConfig.url, equals('https://custom-erp.mybike.in'));
      expect(SupabaseConfig.anonKey, equals('custom_key_123'));
      expect(SupabaseConfig.isConfigured, isTrue);

      // Reset back to development
      AppConfig.setEnvironment(Environment.development);
    });

    test('3. Environment.fromString parses variations robustly', () {
      expect(Environment.fromString('production'), equals(Environment.production));
      expect(Environment.fromString('prod'), equals(Environment.production));
      expect(Environment.fromString('PROD'), equals(Environment.production));
      expect(Environment.fromString('staging'), equals(Environment.staging));
      expect(Environment.fromString('stage'), equals(Environment.staging));
      expect(Environment.fromString('development'), equals(Environment.development));
      expect(Environment.fromString('dev'), equals(Environment.development));
      expect(Environment.fromString(null), equals(Environment.development));
      expect(Environment.fromString('unknown_env'), equals(Environment.development));
    });

    test('4. AppLogger sanitizes sensitive PII (PAN, Aadhaar, phone, tokens, passwords)', () {
      // Test PAN masking
      final panString = 'Customer PAN is ABCDE1234F for billing';
      final sanitizedPan = AppLogger.sanitize(panString);
      expect(sanitizedPan, equals('Customer PAN is ABXXXXXXXF for billing'));

      // Test Aadhaar masking
      final aadhaarString = 'KYC Aadhaar ID 1234 5678 9012 submitted';
      final sanitizedAadhaar = AppLogger.sanitize(aadhaarString);
      expect(sanitizedAadhaar, contains('XXXX-XXXX-9012'));

      // Test Phone masking
      final phoneString = 'Customer phone +91 9876543210 updated';
      final sanitizedPhone = AppLogger.sanitize(phoneString);
      expect(sanitizedPhone, contains('XXXXXX3210'));

      // Test JWT / Bearer Token masking
      final tokenString = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.do_not_leak';
      final sanitizedToken = AppLogger.sanitize(tokenString);
      expect(sanitizedToken, contains('[TOKEN_REDACTED]'));

      // Test Password key-value masking
      final passString = 'User login payload {"username": "manager", "password": "SecretPassword123!"}';
      final sanitizedPass = AppLogger.sanitize(passString);
      expect(sanitizedPass, contains('password: [REDACTED]'));
    });

    test('5. AppLogger structured logging buffer and level filtering', () {
      AppLogger.clearLogs();
      AppConfig.setEnvironment(Environment.development);

      AppLogger.debug('AUTH', 'User attempted login from IP 192.168.1.1');
      AppLogger.info('SALES', 'Created booking SO-2026-001', metadata: {'customer_phone': '9876543210'});
      AppLogger.warning('INVENTORY', 'Low stock alert for Splendor Plus');
      AppLogger.error('FINANCE', 'Payment gateway timeout', error: 'SocketException');
      AppLogger.audit('ADMIN', 'Showroom configuration updated');

      final logs = AppLogger.getRecentLogs();
      expect(logs.length, equals(5));

      final salesLog = logs.firstWhere((l) => l.tag == 'SALES');
      expect(salesLog.metadata?['customer_phone'], contains('XXXXXX3210'));

      final errorLog = logs.firstWhere((l) => l.tag == 'FINANCE');
      expect(errorLog.error, equals('SocketException'));

      final auditLog = logs.firstWhere((l) => l.tag == 'ADMIN');
      expect(auditLog.level, equals(LogLevel.audit));

      // Test level filtering in Production
      AppConfig.setEnvironment(Environment.production);
      AppLogger.clearLogs();

      // Debug and Info should be filtered out
      AppLogger.debug('AUTH', 'This debug should not be recorded');
      AppLogger.info('SALES', 'This info should not be recorded');
      AppLogger.warning('STOCK', 'This warning should be recorded');
      AppLogger.audit('SEC', 'This audit should always be recorded');

      final prodLogs = AppLogger.getRecentLogs();
      expect(prodLogs.length, equals(2));
      expect(prodLogs.any((l) => l.tag == 'STOCK'), isTrue);
      expect(prodLogs.any((l) => l.tag == 'SEC'), isTrue);
      expect(prodLogs.any((l) => l.tag == 'AUTH'), isFalse);

      // Clean up
      AppConfig.setEnvironment(Environment.development);
      AppLogger.clearLogs();
    });
  });
}
