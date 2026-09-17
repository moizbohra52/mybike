import 'package:equatable/equatable.dart';

/// Permission Domain Entity
class PermissionEntity extends Equatable {
  final String id;
  final String module;
  final String action;
  final String? description;

  const PermissionEntity({
    required this.id,
    required this.module,
    required this.action,
    this.description,
  });

  String get code => '$module.$action';

  @override
  List<Object?> get props => [id, module, action, description];
}

/// Role Domain Entity
class RoleEntity extends Equatable {
  final String id;
  final String name;
  final String displayName;
  final String? description;
  final bool isSystemRole;
  final List<PermissionEntity> permissions;

  const RoleEntity({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    this.isSystemRole = false,
    this.permissions = const [],
  });

  /// Check if role grants a module-action permission
  bool hasPermission(String module, String action) {
    return permissions.any(
      (p) => p.module == module && (p.action == action || p.action == '*'),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        displayName,
        description,
        isSystemRole,
        permissions,
      ];
}
