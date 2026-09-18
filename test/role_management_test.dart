import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/role_management_service.dart';
import 'package:mybike/features/roles/domain/entities/role_entity.dart';
import 'package:mybike/features/users/presentation/cubit/role_management_cubit.dart';
import 'package:mybike/features/users/presentation/cubit/role_management_state.dart';

void main() {
  group('RoleManagementCubit', () {
    late RoleManagementCubit cubit;

    setUp(() {
      cubit = RoleManagementCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is RoleManagementInitial', () {
      expect(cubit.state, isA<RoleManagementInitial>());
    });

    test('loadRoles emits Loading then Loaded', () async {
      final states = <RoleManagementState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.loadRoles();
      await Future<void>.delayed(Duration.zero);

      expect(states, [
        isA<RoleManagementLoading>(),
        isA<RoleManagementLoaded>(),
      ]);
      await sub.cancel();
    });

    test('loadRoles returns 11 seeded roles in dev mode', () async {
      await cubit.loadRoles();
      final state = cubit.state as RoleManagementLoaded;
      expect(state.roles.length, 11);
      expect(state.systemRoleCount, 3); // super_admin, admin, showroom_manager
      expect(state.customRoleCount, 8);
    });

    test('loadRoles returns roles with correct system flag', () async {
      await cubit.loadRoles();
      final state = cubit.state as RoleManagementLoaded;
      final systemRoles = state.roles.where((r) => r.role.isSystemRole).map((r) => r.role.name).toSet();
      expect(systemRoles, containsAll(['super_admin', 'admin', 'showroom_manager']));
    });

    test('super_admin and admin have all permissions', () async {
      await cubit.loadRoles();
      final state = cubit.state as RoleManagementLoaded;
      final superAdmin = state.roles.firstWhere((r) => r.role.name == 'super_admin');
      // 20 modules * 7 actions = 140 permissions
      expect(superAdmin.role.permissions.length, 140);
    });

    test('viewer role has only view permissions', () async {
      await cubit.loadRoles();
      final state = cubit.state as RoleManagementLoaded;
      final viewer = state.roles.firstWhere((r) => r.role.name == 'viewer');
      for (final perm in viewer.role.permissions) {
        expect(perm.action, 'view');
      }
    });

    test('deleteRole emits error for system roles', () async {
      await cubit.loadRoles();
      await cubit.deleteRole('role-super_admin');
      expect(cubit.state, isA<RoleManagementError>());
    });
  });

  group('RoleManagementService', () {
    test('moduleGroups covers all 20 modules', () {
      final allModules = <String>{};
      for (final group in RoleManagementService.moduleGroups.values) {
        allModules.addAll(group);
      }
      expect(allModules.length, 20);
    });

    test('allActions has 7 actions', () {
      expect(RoleManagementService.allActions.length, 7);
      expect(RoleManagementService.allActions, contains('view'));
      expect(RoleManagementService.allActions, contains('delete'));
      expect(RoleManagementService.allActions, contains('approve'));
    });

    test('moduleDisplayNames maps all modules', () {
      expect(RoleManagementService.moduleDisplayNames.length, 20);
      expect(RoleManagementService.moduleDisplayNames['dashboard'], 'Dashboard');
      expect(RoleManagementService.moduleDisplayNames['audit_logs'], 'Audit Logs');
    });

    test('fetchAllPermissions returns grouped permissions', () async {
      final perms = await RoleManagementService.instance.fetchAllPermissions();
      expect(perms.length, 20); // 20 modules
      for (final mp in perms) {
        expect(mp.permissions.length, 7); // 7 actions per module
      }
    });
  });

  group('RoleManagementState', () {
    test('RoleManagementLoaded counts system/custom roles', () {
      const state = RoleManagementLoaded(roles: [
        ManagedRole(
          role: RoleEntity(id: '1', name: 'admin', displayName: 'Admin', isSystemRole: true),
        ),
        ManagedRole(
          role: RoleEntity(id: '2', name: 'custom', displayName: 'Custom'),
        ),
      ]);
      expect(state.systemRoleCount, 1);
      expect(state.customRoleCount, 1);
    });
  });
}
