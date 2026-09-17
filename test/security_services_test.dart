import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mybike/core/services/permission_service.dart';
import 'package:mybike/core/services/showroom_service.dart';
import 'package:mybike/features/auth/domain/entities/user_profile.dart';
import 'package:mybike/features/roles/domain/entities/role_entity.dart';
import 'package:mybike/features/showroom/domain/entities/showroom_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PermissionService.instance.clear();
  });

  group('Phase 4 — Security Services Tests', () {
    test('PermissionService grants full access to Super Admin', () {
      final superAdminProfile = UserProfile(
        id: 'sa-01',
        email: 'superadmin@mybike.com',
        roles: const ['super_admin'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      PermissionService.instance.initialize(userProfile: superAdminProfile);

      expect(PermissionService.instance.isSuperAdmin, isTrue);
      expect(PermissionService.instance.isAdmin, isTrue);
      expect(PermissionService.instance.canView('accounting'), isTrue);
      expect(PermissionService.instance.canDelete('vehicles'), isTrue);
      expect(PermissionService.instance.canApprove('expenses'), isTrue);
    });

    test('PermissionService checks specific role and permissions for operational staff', () {
      final salesProfile = UserProfile(
        id: 'se-01',
        email: 'sales@mybike.com',
        roles: const ['sales_executive'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      const salesRole = RoleEntity(
        id: 'r-se',
        name: 'sales_executive',
        displayName: 'Sales Executive',
        permissions: [
          PermissionEntity(id: 'p-1', module: 'sales', action: 'view'),
          PermissionEntity(id: 'p-2', module: 'sales', action: 'create'),
          PermissionEntity(id: 'p-3', module: 'customers', action: 'view'),
        ],
      );

      PermissionService.instance.initialize(
        userProfile: salesProfile,
        roles: [salesRole],
      );

      expect(PermissionService.instance.isSuperAdmin, isFalse);
      expect(PermissionService.instance.hasRole('sales_executive'), isTrue);
      expect(PermissionService.instance.hasRole('accountant'), isFalse);

      // Allowed
      expect(PermissionService.instance.canView('sales'), isTrue);
      expect(PermissionService.instance.canCreate('sales'), isTrue);
      expect(PermissionService.instance.canView('customers'), isTrue);

      // Denied
      expect(PermissionService.instance.canDelete('sales'), isFalse);
      expect(PermissionService.instance.canView('accounting'), isFalse);
    });

    test('ShowroomService initializes default showroom and handles switching', () async {
      final showroomA = ShowroomEntity(
        id: 'sh-a',
        name: 'Showroom A',
        code: 'SHA',
        address: 'Addr A',
        city: 'City A',
        state: 'State A',
        pincode: '400001',
        phone: '123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final showroomB = ShowroomEntity(
        id: 'sh-b',
        name: 'Showroom B',
        code: 'SHB',
        address: 'Addr B',
        city: 'City B',
        state: 'State B',
        pincode: '400002',
        phone: '456',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ShowroomService.instance.initialize(
        authorizedShowrooms: [showroomA, showroomB],
        defaultShowroomId: 'sh-b',
      );

      expect(ShowroomService.instance.activeShowroom?.id, 'sh-b');
      expect(ShowroomService.instance.hasMultipleShowrooms, isTrue);

      // Switch to Showroom A
      await ShowroomService.instance.switchShowroom(showroomA);
      expect(ShowroomService.instance.activeShowroom?.id, 'sh-a');
      expect(ShowroomService.instance.activeShowroomNotifier.value?.name, 'Showroom A');

      // Clear
      await ShowroomService.instance.clear();
      expect(ShowroomService.instance.activeShowroom, isNull);
    });
  });
}
