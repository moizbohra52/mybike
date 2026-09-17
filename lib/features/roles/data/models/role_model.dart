import '../../domain/entities/role_entity.dart';

/// Permission Model with JSON serialization
class PermissionModel extends PermissionEntity {
  const PermissionModel({
    required super.id,
    required super.module,
    required super.action,
    super.description,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] as String,
      module: json['module'] as String,
      action: json['action'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module': module,
      'action': action,
      'description': description,
    };
  }
}

/// Role Model with JSON serialization
class RoleModel extends RoleEntity {
  const RoleModel({
    required super.id,
    required super.name,
    required super.displayName,
    super.description,
    super.isSystemRole = false,
    super.permissions = const [],
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    List<PermissionModel> parsedPermissions = [];
    if (json['permissions'] != null && json['permissions'] is List) {
      parsedPermissions = (json['permissions'] as List)
          .whereType<Map<String, dynamic>>()
          .map((p) => PermissionModel.fromJson(p))
          .toList();
    }

    return RoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String? ?? json['name'] as String,
      description: json['description'] as String?,
      isSystemRole: json['is_system_role'] as bool? ?? false,
      permissions: parsedPermissions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'is_system_role': isSystemRole,
    };
  }
}
