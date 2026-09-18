import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/features/users/presentation/cubit/user_management_cubit.dart';
import 'package:mybike/features/users/presentation/cubit/user_management_state.dart';
import 'package:mybike/features/users/presentation/cubit/user_form_cubit.dart';
import 'package:mybike/features/users/presentation/cubit/user_form_state.dart';

void main() {
  group('UserManagementCubit', () {
    late UserManagementCubit cubit;

    setUp(() {
      cubit = UserManagementCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is UserManagementInitial', () {
      expect(cubit.state, isA<UserManagementInitial>());
    });

    test('loadUsers emits Loading then Loaded with dev data', () async {
      final states = <UserManagementState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.loadUsers();
      await Future<void>.delayed(Duration.zero);

      expect(states, [
        isA<UserManagementLoading>(),
        isA<UserManagementLoaded>(),
      ]);
      await sub.cancel();
    });

    test('loadUsers loads at least 1 dev user', () async {
      await cubit.loadUsers();
      final state = cubit.state as UserManagementLoaded;
      expect(state.users.isNotEmpty, true);
      expect(state.totalCount, greaterThan(0));
    });

    test('searchUsers filters results by query', () async {
      await cubit.loadUsers();
      await cubit.searchUsers('admin');
      final state = cubit.state as UserManagementLoaded;
      expect(state.users.any((u) => u.profile.email.contains('admin')), true);
      expect(state.searchQuery, 'admin');
    });

    test('filterByRole filters by role name', () async {
      await cubit.loadUsers();
      await cubit.filterByRole('super_admin');
      final state = cubit.state as UserManagementLoaded;
      expect(state.roleFilter, 'super_admin');
      for (final u in state.users) {
        expect(u.profile.roles.contains('super_admin'), true);
      }
    });

    test('toggleActiveFilter shows only active/inactive users', () async {
      await cubit.loadUsers();
      await cubit.toggleActiveFilter(false);
      final state = cubit.state as UserManagementLoaded;
      expect(state.activeFilter, false);
      for (final u in state.users) {
        expect(u.profile.isActive, false);
      }
    });

    test('clearFilters resets all filters', () async {
      await cubit.loadUsers();
      await cubit.searchUsers('admin');
      await cubit.filterByRole('super_admin');
      await cubit.clearFilters();
      final state = cubit.state as UserManagementLoaded;
      expect(state.searchQuery, isNull);
      expect(state.roleFilter, isNull);
      expect(state.activeFilter, isNull);
    });

    test('toggleUserActive changes user status', () async {
      await cubit.loadUsers();
      final state = cubit.state as UserManagementLoaded;
      final firstUser = state.users.first;
      await cubit.toggleUserActive(firstUser.profile.id, !firstUser.profile.isActive);
      expect(cubit.state, isA<UserManagementLoaded>());
    });
  });

  group('UserFormCubit', () {
    late UserFormCubit cubit;

    setUp(() {
      cubit = UserFormCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is UserFormInitial', () {
      expect(cubit.state, isA<UserFormInitial>());
    });

    test('initNewUser emits Loading then Ready with empty selections', () async {
      final states = <UserFormState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.initNewUser();
      await Future<void>.delayed(Duration.zero);

      expect(states, [
        isA<UserFormLoading>(),
        isA<UserFormReady>(),
      ]);
      final state = cubit.state as UserFormReady;
      expect(state.isEditMode, false);
      expect(state.existingUser, isNull);
      expect(state.availableRoles.isNotEmpty, true);
      expect(state.availableShowrooms.isNotEmpty, true);
      expect(state.selectedRoleIds, isEmpty);
      expect(state.selectedShowroomIds, isEmpty);
      await sub.cancel();
    });

    test('loadUserForEdit loads existing user data', () async {
      await cubit.loadUserForEdit('dev-u001');
      if (cubit.state is UserFormReady) {
        final state = cubit.state as UserFormReady;
        expect(state.isEditMode, true);
        expect(state.existingUser, isNotNull);
        expect(state.selectedRoleIds.isNotEmpty, true);
        expect(state.selectedShowroomIds.isNotEmpty, true);
      }
    });

    test('updateRoleSelection updates selected role IDs', () async {
      await cubit.initNewUser();
      cubit.updateRoleSelection(['role-admin', 'role-viewer']);
      final state = cubit.state as UserFormReady;
      expect(state.selectedRoleIds, ['role-admin', 'role-viewer']);
    });

    test('updateShowroomSelection updates selected showroom IDs', () async {
      await cubit.initNewUser();
      cubit.updateShowroomSelection(['sh-001', 'sh-002']);
      final state = cubit.state as UserFormReady;
      expect(state.selectedShowroomIds, ['sh-001', 'sh-002']);
      expect(state.defaultShowroomId, 'sh-001');
    });

    test('saveUser emits Saving then Success for new user', () async {
      await cubit.initNewUser();
      cubit.updateRoleSelection(['role-viewer']);
      cubit.updateShowroomSelection(['sh-001']);

      final states = <UserFormState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.saveUser(
        email: 'test@mybike.com',
        password: 'test123',
        fullName: 'Test User',
      );
      await Future<void>.delayed(Duration.zero);

      expect(states, [
        isA<UserFormSaving>(),
        isA<UserFormSuccess>(),
      ]);
      await sub.cancel();
    });
  });

  group('UserManagementState', () {
    test('UserManagementLoaded.totalPages calculates correctly', () {
      const state = UserManagementLoaded(
        users: [],
        totalCount: 25,
        pageSize: 10,
      );
      expect(state.totalPages, 3);
    });

    test('UserManagementLoaded.totalPages returns 1 for 0 count', () {
      const state = UserManagementLoaded(
        users: [],
        totalCount: 0,
        pageSize: 10,
      );
      expect(state.totalPages, 1);
    });

    test('UserManagementLoaded.copyWith preserves values', () {
      const state = UserManagementLoaded(
        users: [],
        totalCount: 10,
        searchQuery: 'test',
        roleFilter: 'admin',
      );
      final copied = state.copyWith(currentPage: 2);
      expect(copied.searchQuery, 'test');
      expect(copied.roleFilter, 'admin');
      expect(copied.currentPage, 2);
    });
  });
}
