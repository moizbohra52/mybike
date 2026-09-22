import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/security/data_masking_service.dart';
import 'package:mybike/core/security/session_security_manager.dart';

void main() {
  group('Security Audit - Data Masking Service', () {
    test('Aadhaar masking', () {
      expect(DataMaskingService.maskAadhaar('123456789012'), '•••• •••• 9012');
      expect(DataMaskingService.maskAadhaar('1234 5678 9012'), '•••• •••• 9012');
      expect(DataMaskingService.maskAadhaar('1234'), '1234'); // Invalid length returned as is
      expect(DataMaskingService.maskAadhaar(null), '');
    });

    test('PAN masking', () {
      expect(DataMaskingService.maskPan('ABCDE1234F'), '••••• 1234F');
      expect(DataMaskingService.maskPan('abcde1234f'), '••••• 1234F');
      expect(DataMaskingService.maskPan('ABCD'), 'ABCD'); // Invalid length returned as is
      expect(DataMaskingService.maskPan(null), '');
    });

    test('Bank Account masking', () {
      expect(DataMaskingService.maskBankAccount('1234567890'), '••••••7890');
      expect(DataMaskingService.maskBankAccount('123'), '123'); // Too short
      expect(DataMaskingService.maskBankAccount(null), '');
    });

    test('Phone masking', () {
      expect(DataMaskingService.maskPhone('9876543210'), '••••• •3210');
      expect(DataMaskingService.maskPhone('919876543210'), '+91 ••••• •3210');
      expect(DataMaskingService.maskPhone('+91 9876543210'), '+91 ••••• •3210');
      expect(DataMaskingService.maskPhone('123'), '123'); // Too short
      expect(DataMaskingService.maskPhone(null), '');
    });

    test('Email masking', () {
      expect(DataMaskingService.maskEmail('john.doe@example.com'), 'j••••••e@example.com');
      expect(DataMaskingService.maskEmail('ab@example.com'), 'a•••@example.com');
      expect(DataMaskingService.maskEmail('invalid-email'), 'invalid-email');
      expect(DataMaskingService.maskEmail(null), '');
    });

    test('Payload sanitization', () {
      final payload = {
        'user_name': 'john',
        'password': 'supersecretpassword',
        'access_token': 'ey12345...',
        'profile': {
          'email': 'john@example.com',
          'pin': '1234',
        },
        'roles': [
          {'name': 'admin', 'authorization': 'Bearer xyz'}
        ]
      };

      final sanitized = DataMaskingService.sanitizePayload(payload);
      
      expect(sanitized['user_name'], 'john');
      expect(sanitized['password'], '********');
      expect(sanitized['access_token'], '********');
      expect(sanitized['profile']['email'], 'john@example.com');
      expect(sanitized['profile']['pin'], '********');
      expect(sanitized['roles'][0]['authorization'], '********');
    });
  });

  group('Security Audit - Session Security Manager', () {
    test('Session timeout detection', () async {
      final manager = SessionSecurityManager.instance;
      // Initialize with a very short timeout
      manager.initialize(timeoutDuration: const Duration(milliseconds: 100));
      
      expect(manager.isSessionExpired, isFalse);
      
      // Wait for timeout
      await Future.delayed(const Duration(milliseconds: 150));
      
      expect(manager.isSessionExpired, isTrue);
      
      // Record activity to reset
      manager.recordActivity();
      expect(manager.isSessionExpired, isFalse);
      
      manager.dispose();
    });
  });
}
