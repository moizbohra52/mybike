import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/role_management_service.dart';
import 'role_management_state.dart';

/// Role Management Cubit
class RoleManagementCubit extends Cubit<RoleManagementState> {
  final RoleManagementService _service;

  RoleManagementCubit({RoleManagementService? service})
      : _service = service ?? RoleManagementService.instance,
        super(const RoleManagementInitial());

  /// Load all roles with user counts
  Future<void> loadRoles() async {
    emit(const RoleManagementLoading());
    try {
      final roles = await _service.fetchRoles();
      emit(RoleManagementLoaded(roles: roles));
    } catch (e) {
      emit(RoleManagementError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Create a new custom role
  Future<void> createRole({
    required String name,
    required String displayName,
    String? description,
    List<String> permissionIds = const [],
  }) async {
    try {
      await _service.createRole(
        name: name,
        displayName: displayName,
        description: description,
        permissionIds: permissionIds,
      );
      await loadRoles();
    } catch (e) {
      emit(RoleManagementError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Update role metadata
  Future<void> updateRole(
    String roleId, {
    String? displayName,
    String? description,
  }) async {
    try {
      await _service.updateRole(
        roleId,
        displayName: displayName,
        description: description,
      );
      await loadRoles();
    } catch (e) {
      emit(RoleManagementError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Update role permissions
  Future<void> updatePermissions(String roleId, List<String> permissionIds) async {
    try {
      await _service.updateRolePermissions(roleId, permissionIds);
      await loadRoles();
    } catch (e) {
      emit(RoleManagementError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Delete a non-system role
  Future<void> deleteRole(String roleId) async {
    try {
      await _service.deleteRole(roleId);
      emit(const RoleManagementDeleteSuccess('Role deleted successfully'));
      await loadRoles();
    } catch (e) {
      emit(RoleManagementError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
