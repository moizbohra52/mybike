import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/security/data_masking_service.dart';
import 'package:mybike/core/security/showroom_isolation_guard.dart';
import 'package:mybike/core/security/session_security_manager.dart';
import 'package:mybike/core/services/showroom_service.dart';
import 'package:mybike/core/services/permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mybike/features/showroom/domain/entities/showroom_entity.dart';
import 'package:mybike/features/auth/domain/entities/user_profile.dart';
import 'package:mybike/features/roles/domain/entities/role_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  final dummyShowroomA = ShowroomEntity(
    id: 'sh-mumbai',
    name: 'MYBIKE Mumbai Flagship',
    code: 'MUM',
    address: 'Andheri West',
    city: 'Mumbai',
    state: 'Maharashtra',
    pincode: '400053',
    phone: '9820011111',
    email: 'mumbai@mybike.com',
    gstin: '27AAAAA0000A1Z5',
    invoicePrefix: 'MBMUM',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final dummyShowroomB = ShowroomEntity(
    id: 'sh-pune',
    name: 'MYBIKE Pune Hub',
    code: 'PUN',
    address: 'Kothrud',
    city: 'Pune',
    state: 'Maharashtra',
    pincode: '411038',
    phone: '9820022222',
    email: 'pune@mybike.com',
    gstin: '27AAAAA0000A1Z5',
    invoicePrefix: 'MBPUN',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  group('DataMaskingService Tests', () {
    test('Masks 12-digit Aadhaar number correctly', () {
      expect(DataMaskingService.maskAadhaar('1234 5678 9012'), equals('•••• •••• 9012'));
      expect(DataMaskingService.maskAadhaar('123456789012'), equals('•••• •••• 9012'));
      expect(DataMaskingService.maskAadhaar(null), isEmpty);
      expect(DataMaskingService.maskAadhaar(''), isEmpty);
      expect(DataMaskingService.maskAadhaar('123'), equals('••••'));
    });

    test('Masks PAN number correctly', () {
      expect(DataMaskingService.maskPan('ABCDE1234F'), equals('••••• 1234F'));
      expect(DataMaskingService.maskPan('abcde1234f'), equals('••••• 1234F'));
      expect(DataMaskingService.maskPan(null), isEmpty);
      expect(DataMaskingService.maskPan(''), isEmpty);
    });

    test('Masks Bank Account Number showing last 4 digits', () {
      expect(
        DataMaskingService.maskBankAccount('12345678901234'),
        equals('••••••••••1234'),
      );
      expect(DataMaskingService.maskBankAccount('12345678'), equals('••••5678'));
      expect(DataMaskingService.maskBankAccount('9876'), equals('••••'));
      expect(DataMaskingService.maskBankAccount(null), isEmpty);
    });

    test('Masks Indian Phone Number', () {
      expect(
        DataMaskingService.maskPhone('+919820012345'),
        equals('+9198200 •••45'),
      );
      expect(DataMaskingService.maskPhone(null), isEmpty);
    });

    test('Masks Email Address preserving domain and boundaries', () {
      expect(
        DataMaskingService.maskEmail('john.doe@example.com'),
        equals('j•••e@example.com'),
      );
      expect(DataMaskingService.maskEmail('moiz@mybike.com'), equals('m•••z@mybike.com'));
      expect(DataMaskingService.maskEmail(null), isEmpty);
    });

    test('Sanitizes JSON payload by recursively stripping passwords and secrets', () {
      final sensitivePayload = {
        'username': 'dealership_manager',
        'password': 'SuperSecretPassword123!',
        'auth_token': 'jwt.ey12345.xyz',
        'nested': {
          'api_key': 'ak_live_99999',
          'pin': '4321',
          'customer_name': 'Rahul Sharma',
        },
        'list_data': [
          {'secret': 'top_secret_code', 'item': 'Helmet'},
        ],
      };

      final sanitized = DataMaskingService.sanitizePayload(sensitivePayload);

      expect(sanitized['username'], equals('dealership_manager'));
      expect(sanitized['password'], equals('[REDACTED]'));
      expect(sanitized['auth_token'], equals('[REDACTED]'));

      final nested = sanitized['nested'] as Map<String, dynamic>;
      expect(nested['customer_name'], equals('Rahul Sharma'));
      expect(nested['api_key'], equals('[REDACTED]'));
      expect(nested['pin'], equals('[REDACTED]'));

      final list = sanitized['list_data'] as List<dynamic>;
      final firstItem = list[0] as Map<String, dynamic>;
      expect(firstItem['item'], equals('Helmet'));
      expect(firstItem['secret'], equals('[REDACTED]'));
    });
  });

  group('ShowroomIsolationGuard Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      // Initialize showroom context with only Showroom A
      await ShowroomService.instance.initialize(
        authorizedShowrooms: [dummyShowroomA],
        defaultShowroomId: dummyShowroomA.id,
      );

      // Initialize standard user profile
      PermissionService.instance.initialize(
        userProfile: UserProfile(
          id: 'usr-regular',
          email: 'sales@mybike.com',
          fullName: 'Regular Sales',
          roles: ['sales_executive'],
          assignedShowroomIds: [dummyShowroomA.id],
          defaultShowroomId: dummyShowroomA.id,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
        roles: [
          RoleEntity(
            id: 'role-sales',
            name: 'sales_executive',
            displayName: 'Sales Executive',
            permissions: [
              const PermissionEntity(
                id: 'p1',
                module: 'sales',
                action: 'create',
                description: 'Create Sale',
              ),
            ],
          ),
        ],
      );
    });

    test('Allows access to authorized showroom', () {
      expect(
        () => ShowroomIsolationGuard.validateAccess(dummyShowroomA.id),
        returnsNormally,
      );
    });

    test('Rejects access and throws SecurityViolationException for foreign showroom', () {
      expect(
        () => ShowroomIsolationGuard.validateAccess(
          dummyShowroomB.id,
          operation: 'create_booking',
        ),
        throwsA(isA<SecurityViolationException>()),
      );
    });

    test('Enforces current tenant match', () {
      expect(
        () => ShowroomIsolationGuard.assertCurrentTenant(dummyShowroomA.id),
        returnsNormally,
      );

      expect(
        () => ShowroomIsolationGuard.assertCurrentTenant(dummyShowroomB.id),
        throwsA(isA<SecurityViolationException>()),
      );
    });

    test('Super admin bypasses showroom restrictions', () {
      PermissionService.instance.initialize(
        userProfile: UserProfile(
          id: 'usr-admin',
          email: 'admin@mybike.com',
          fullName: 'Super Administrator',
          roles: ['super_admin'],
          assignedShowroomIds: [],
          defaultShowroomId: null,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );

      expect(
        () => ShowroomIsolationGuard.validateAccess(dummyShowroomB.id),
        returnsNormally,
      );
      expect(
        () => ShowroomIsolationGuard.assertCurrentTenant(dummyShowroomB.id),
        returnsNormally,
      );
    });

    test('Validates storage upload quarantine path', () {
      // Valid path inside showroom folder
      expect(
        () => ShowroomIsolationGuard.validateStoragePath(
          'sh-mumbai/kyc/aadhaar_front.pdf',
          'sh-mumbai',
        ),
        returnsNormally,
      );

      // Invalid path attempting to upload to a different showroom
      expect(
        () => ShowroomIsolationGuard.validateStoragePath(
          'sh-pune/kyc/aadhaar_front.pdf',
          'sh-mumbai',
        ),
        throwsA(isA<SecurityViolationException>()),
      );

      // Path outside any folder
      expect(
        () => ShowroomIsolationGuard.validateStoragePath(
          'aadhaar_front.pdf',
          'sh-mumbai',
        ),
        throwsA(isA<SecurityViolationException>()),
      );
    });
  });

  group('SessionSecurityManager Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Tracks user activity heartbeat', () {
      final manager = SessionSecurityManager.custom();
      expect(manager.lastActivityTime, isNull);

      manager.recordActivity();
      expect(manager.lastActivityTime, isNotNull);
      expect(manager.isSessionExpired, isFalse);
    });

    test('Detects idle session expiration correctly', () async {
      final manager = SessionSecurityManager.custom(
        idleTimeout: const Duration(milliseconds: 30),
      );

      manager.recordActivity();
      expect(manager.isSessionExpired, isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(manager.isSessionExpired, isTrue);
      expect(manager.remainingSessionTime, equals(Duration.zero));
    });

    test('securePurgeSession clears session memory and contexts', () async {
      final manager = SessionSecurityManager.custom();
      manager.recordActivity();

      await manager.securePurgeSession();

      expect(manager.lastActivityTime, isNull);
      expect(PermissionService.instance.currentProfile, isNull);
      expect(ShowroomService.instance.activeShowroom, isNull);
    });
  });
}
