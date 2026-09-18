import 'package:equatable/equatable.dart';
import '../../../../core/services/role_management_service.dart';

/// Role Management States
abstract class RoleManagementState extends Equatable {
  const RoleManagementState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class RoleManagementInitial extends RoleManagementState {
  const RoleManagementInitial();
}

/// Loading roles
class RoleManagementLoading extends RoleManagementState {
  const RoleManagementLoading();
}

/// Roles loaded
class RoleManagementLoaded extends RoleManagementState {
  final List<ManagedRole> roles;

  const RoleManagementLoaded({required this.roles});

  int get systemRoleCount => roles.where((r) => r.role.isSystemRole).length;
  int get customRoleCount => roles.where((r) => !r.role.isSystemRole).length;

  @override
  List<Object?> get props => [roles];
}

/// Error state
class RoleManagementError extends RoleManagementState {
  final String message;
  const RoleManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Role deletion success
class RoleManagementDeleteSuccess extends RoleManagementState {
  final String message;
  const RoleManagementDeleteSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
