import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import 'supabase_service.dart';
import '../../features/roles/domain/entities/role_entity.dart';
import '../../features/roles/data/models/role_model.dart';

/// Grouped permissions by module
class ModulePermissions {
  final String module;
  final String displayName;
  final List<PermissionEntity> permissions;

  const ModulePermissions({
    required this.module,
    required this.displayName,
    required this.permissions,
  });
}

/// Role with full permission details and user count
class ManagedRole {
  final RoleEntity role;
  final int userCount;

  const ManagedRole({required this.role, this.userCount = 0});
}

/// Role Management Service — CRUD for roles and permission matrix
class RoleManagementService {
  RoleManagementService._();
  static final RoleManagementService instance = RoleManagementService._();

  // Module display name mapping
  static const Map<String, String> moduleDisplayNames = {
    'dashboard': 'Dashboard',
    'showrooms': 'Showrooms',
    'users': 'Users',
    'roles': 'Roles',
    'permissions': 'Permissions',
    'vehicles': 'Vehicles',
    'inventory': 'Inventory',
    'customers': 'Customers',
    'suppliers': 'Suppliers',
    'purchases': 'Purchases',
    'sales': 'Sales',
    'bookings': 'Bookings',
    'payments': 'Payments',
    'expenses': 'Expenses',
    'accounting': 'Accounting',
    'reports': 'Reports',
    'audit_logs': 'Audit Logs',
    'settings': 'Settings',
    'documents': 'Documents',
    'notifications': 'Notifications',
  };

  /// Module groups for the permission matrix UI
  static const Map<String, List<String>> moduleGroups = {
    'Core': ['dashboard', 'showrooms', 'users', 'roles', 'permissions'],
    'Operations': ['vehicles', 'inventory', 'customers', 'suppliers'],
    'Transactions': ['purchases', 'sales', 'bookings', 'payments', 'expenses'],
    'Finance & Reports': ['accounting', 'reports'],
    'System': ['audit_logs', 'settings', 'documents', 'notifications'],
  };

  static const List<String> allActions = [
    'view', 'create', 'edit', 'delete', 'approve', 'export', 'print',
  ];

  // ─── Dev Mode Data ───
  List<PermissionEntity>? _devPermissions;
  final List<ManagedRole> _devRoles = [];
  bool _devInitialized = false;

  void _ensureDevData() {
    if (_devInitialized) return;
    _devInitialized = true;

    // Generate all permissions
    final permissions = <PermissionEntity>[];
    int idx = 0;
    for (final module in moduleDisplayNames.keys) {
      for (final action in allActions) {
        permissions.add(PermissionEntity(
          id: 'perm-${idx++}',
          module: module,
          action: action,
          description: 'Permission to $action in $module module',
        ));
      }
    }
    _devPermissions = permissions;

    // Generate dev roles with assigned permissions
    _devRoles.addAll([
      ManagedRole(
        role: RoleEntity(
          id: 'role-super_admin',
          name: 'super_admin',
          displayName: 'Super Admin',
          description: 'Full system control across all showrooms',
          isSystemRole: true,
          permissions: List.from(permissions), // All permissions
        ),
        userCount: 1,
      ),
      ManagedRole(
        role: RoleEntity(
          id: 'role-admin',
          name: 'admin',
          displayName: 'Admin',
          description: 'Business administration and reports across showrooms',
          isSystemRole: true,
          permissions: List.from(permissions), // All permissions
        ),
        userCount: 0,
      ),
      ManagedRole(
        role: RoleEntity(
          id: 'role-showroom_manager',
          name: 'showroom_manager',
          displayName: 'Showroom Manager',
          description: 'Operational control of assigned showrooms',
          isSystemRole: true,
          permissions: permissions.where((p) {
            final opModules = ['dashboard', 'showrooms', 'vehicles', 'inventory', 'customers', 'suppliers', 'purchases', 'sales', 'bookings', 'payments', 'expenses', 'reports'];
            final opActions = ['view', 'create', 'edit', 'approve', 'export', 'print'];
            return opModules.contains(p.module) && opActions.contains(p.action);
          }).toList(),
        ),
        userCount: 1,
      ),
      ManagedRole(
        role: RoleEntity(
          id: 'role-sales_manager',
          name: 'sales_manager',
          displayName: 'Sales Manager',
          description: 'Sales team management and approvals',
          permissions: permissions.where((p) {
            final modules = ['dashboard', 'vehicles', 'customers', 'sales', 'bookings', 'reports'];
            return modules.contains(p.module) && ['view', 'create', 'edit', 'approve', 'export', 'print'].contains(p.action);
          }).toList(),
        ),
        userCount: 0,
      ),
      ManagedRole(
        role: RoleEntity(
          id: 'role-sales_executive',
          name: 'sales_executive',
          displayName: 'Sales Executive',
          description: 'Customer handling, quotations, and bookings',
          permissions: permissions.where((p) {
            final modules = ['dashboard', 'vehicles', 'customers', 'bookings', 'sales'];
            return modules.contains(p.module) && ['view', 'create', 'edit', 'print'].contains(p.action);
          }).toList(),
        ),
        userCount: 1,
      ),
      ManagedRole(
        role: RoleEntity(
          id: 'role-purchase_manager',
          name: 'purchase_manager',
          displayName: 'Purchase Manager',
          description: 'Supplier management and purchase orders',
          permissions: permissions.where((p) {
            final modules = ['dashboard', 'suppliers', 'purchases', 'inventory', 'reports'];
            return modules.contains(p.module) && ['view', 'create', 'edit', 'approve', 'export', 'print'].contains(p.action);
          }).toList(),
        ),
        userCount: 0,
      ),
      ManagedRole(
        role: RoleEntity(
          id: 'role-inventory_manager',
          name: 'inventory_manager',
          displayName: 'Inventory Manager',
          description: 'Stock management, receiving, and transfers',
          permissions: permissions.where((p) {
            final modules = ['dashboard', 'inventory', 'vehicles', 'suppliers'];
            return modules.contains(p.module) && ['view', 'create', 'edit', 'export', 'print'].contains(p.action);
          }).toList(),
        ),
        userCount: 1,
      ),
      ManagedRole(
        role: RoleEntity(
          id: 'role-accountant',
          name: 'accountant',
          displayName: 'Accountant',
          description: 'General ledger, journal entries, and financial statements',
          permissions: permissions.where((p) {
            final modules = ['dashboard', 'accounting', 'expenses', 'payments', 'reports'];
            return modules.contains(p.module);
          }).toList(),
        ),
        userCount: 1,
      ),
      ManagedRole(
        role: RoleEntity(
          id: 'role-cashier',
          name: 'cashier',
          displayName: 'Cashier',
          description: 'Receipts, cash collections, and counter payments',
          permissions: permissions.where((p) {
            final modules = ['dashboard', 'payments'];
            return modules.contains(p.module) && ['view', 'create', 'edit', 'print'].contains(p.action);
          }).toList(),
        ),
        userCount: 0,
      ),
      ManagedRole(
        role: RoleEntity(
          id: 'role-service_manager',
          name: 'service_manager',
          displayName: 'Service Manager',
          description: 'Service operations and warranty processing',
          permissions: permissions.where((p) {
            final modules = ['dashboard', 'vehicles', 'customers', 'inventory'];
            return modules.contains(p.module) && ['view', 'create', 'edit', 'print'].contains(p.action);
          }).toList(),
        ),
        userCount: 0,
      ),
      ManagedRole(
        role: RoleEntity(
          id: 'role-viewer',
          name: 'viewer',
          displayName: 'Viewer',
          description: 'Read-only access to authorized modules',
          permissions: permissions.where((p) => p.action == 'view').toList(),
        ),
        userCount: 1,
      ),
    ]);
  }

  /// Fetch all roles with user counts
  Future<List<ManagedRole>> fetchRoles() async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;

        final rolesData = await client
            .from('roles')
            .select('*, role_permissions(permission_id, permissions(id, module, action, description))')
            .order('is_system_role', ascending: false)
            .order('name', ascending: true);

        // Get user counts per role
        final userCountsData = await client
            .from('user_roles')
            .select('role_id')
            .eq('is_active', true);

        final countMap = <String, int>{};
        for (final row in userCountsData) {
          final roleId = row['role_id'] as String;
          countMap[roleId] = (countMap[roleId] ?? 0) + 1;
        }

        return (rolesData as List).map((row) {
          List<PermissionEntity> perms = [];
          if (row['role_permissions'] != null) {
            for (final rp in row['role_permissions']) {
              if (rp['permissions'] != null) {
                perms.add(PermissionModel.fromJson(rp['permissions']));
              }
            }
          }

          final role = RoleEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            displayName: row['display_name'] as String? ?? row['name'] as String,
            description: row['description'] as String?,
            isSystemRole: row['is_system_role'] as bool? ?? false,
            permissions: perms,
          );

          return ManagedRole(
            role: role,
            userCount: countMap[role.id] ?? 0,
          );
        }).toList();
      } catch (e) {
        debugPrint('RoleManagementService.fetchRoles error: $e');
        rethrow;
      }
    }

    // Dev mode
    _ensureDevData();
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_devRoles);
  }

  /// Fetch single role with full permission details
  Future<ManagedRole?> fetchRoleWithPermissions(String roleId) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;

        final data = await client
            .from('roles')
            .select('*, role_permissions(permission_id, permissions(id, module, action, description))')
            .eq('id', roleId)
            .maybeSingle();

        if (data == null) return null;

        List<PermissionEntity> perms = [];
        if (data['role_permissions'] != null) {
          for (final rp in data['role_permissions']) {
            if (rp['permissions'] != null) {
              perms.add(PermissionModel.fromJson(rp['permissions']));
            }
          }
        }

        final role = RoleEntity(
          id: data['id'] as String,
          name: data['name'] as String,
          displayName: data['display_name'] as String? ?? data['name'] as String,
          description: data['description'] as String?,
          isSystemRole: data['is_system_role'] as bool? ?? false,
          permissions: perms,
        );

        // Get user count
        final countData = await client
            .from('user_roles')
            .select('id')
            .eq('role_id', roleId)
            .eq('is_active', true);

        return ManagedRole(role: role, userCount: (countData as List).length);
      } catch (e) {
        debugPrint('RoleManagementService.fetchRoleWithPermissions error: $e');
        rethrow;
      }
    }

    // Dev mode
    _ensureDevData();
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _devRoles.firstWhere((r) => r.role.id == roleId);
    } catch (_) {
      return null;
    }
  }

  /// Fetch all permissions grouped by module
  Future<List<ModulePermissions>> fetchAllPermissions() async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;
        final data = await client
            .from('permissions')
            .select()
            .order('module', ascending: true)
            .order('action', ascending: true);

        final perms = (data as List).map((p) => PermissionModel.fromJson(p)).toList();
        return _groupPermissions(perms);
      } catch (e) {
        debugPrint('RoleManagementService.fetchAllPermissions error: $e');
        rethrow;
      }
    }

    // Dev mode
    _ensureDevData();
    await Future.delayed(const Duration(milliseconds: 200));
    return _groupPermissions(_devPermissions!);
  }

  List<ModulePermissions> _groupPermissions(List<PermissionEntity> perms) {
    final grouped = <String, List<PermissionEntity>>{};
    for (final p in perms) {
      grouped.putIfAbsent(p.module, () => []).add(p);
    }

    return grouped.entries.map((e) => ModulePermissions(
          module: e.key,
          displayName: moduleDisplayNames[e.key] ?? e.key,
          permissions: e.value,
        )).toList();
  }

  /// Create a new custom role
  Future<RoleEntity> createRole({
    required String name,
    required String displayName,
    String? description,
    List<String> permissionIds = const [],
  }) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;

        final roleData = await client
            .from('roles')
            .insert({
              'name': name,
              'display_name': displayName,
              'description': description,
              'is_system_role': false,
            })
            .select()
            .single();

        final roleId = roleData['id'] as String;

        // Map permissions
        if (permissionIds.isNotEmpty) {
          final rpInserts = permissionIds.map((pid) => {
                'role_id': roleId,
                'permission_id': pid,
              }).toList();
          await client.from('role_permissions').insert(rpInserts);
        }

        final result = await fetchRoleWithPermissions(roleId);
        return result!.role;
      } catch (e) {
        debugPrint('RoleManagementService.createRole error: $e');
        rethrow;
      }
    }

    // Dev mode
    _ensureDevData();
    await Future.delayed(const Duration(milliseconds: 400));

    final assignedPerms = _devPermissions!.where((p) => permissionIds.contains(p.id)).toList();
    final newRole = RoleEntity(
      id: 'role-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      displayName: displayName,
      description: description,
      isSystemRole: false,
      permissions: assignedPerms,
    );

    _devRoles.add(ManagedRole(role: newRole, userCount: 0));
    return newRole;
  }

  /// Update role metadata (non-system roles only, or display_name/description for system)
  Future<void> updateRole(
    String roleId, {
    String? displayName,
    String? description,
  }) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final updates = <String, dynamic>{};
        if (displayName != null) updates['display_name'] = displayName;
        if (description != null) updates['description'] = description;

        if (updates.isNotEmpty) {
          await SupabaseService.client!
              .from('roles')
              .update(updates)
              .eq('id', roleId);
        }
      } catch (e) {
        debugPrint('RoleManagementService.updateRole error: $e');
        rethrow;
      }
      return;
    }

    // Dev mode
    _ensureDevData();
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _devRoles.indexWhere((r) => r.role.id == roleId);
    if (index == -1) throw Exception('Role not found');

    final existing = _devRoles[index];
    _devRoles[index] = ManagedRole(
      role: RoleEntity(
        id: existing.role.id,
        name: existing.role.name,
        displayName: displayName ?? existing.role.displayName,
        description: description ?? existing.role.description,
        isSystemRole: existing.role.isSystemRole,
        permissions: existing.role.permissions,
      ),
      userCount: existing.userCount,
    );
  }

  /// Update role permissions (replace all permission mappings)
  Future<void> updateRolePermissions(String roleId, List<String> permissionIds) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;

        // Delete existing permissions
        await client.from('role_permissions').delete().eq('role_id', roleId);

        // Insert new permissions
        if (permissionIds.isNotEmpty) {
          final inserts = permissionIds.map((pid) => {
                'role_id': roleId,
                'permission_id': pid,
              }).toList();
          await client.from('role_permissions').insert(inserts);
        }
      } catch (e) {
        debugPrint('RoleManagementService.updateRolePermissions error: $e');
        rethrow;
      }
      return;
    }

    // Dev mode
    _ensureDevData();
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _devRoles.indexWhere((r) => r.role.id == roleId);
    if (index == -1) throw Exception('Role not found');

    final existing = _devRoles[index];
    final assignedPerms = _devPermissions!.where((p) => permissionIds.contains(p.id)).toList();

    _devRoles[index] = ManagedRole(
      role: RoleEntity(
        id: existing.role.id,
        name: existing.role.name,
        displayName: existing.role.displayName,
        description: existing.role.description,
        isSystemRole: existing.role.isSystemRole,
        permissions: assignedPerms,
      ),
      userCount: existing.userCount,
    );
  }

  /// Delete a non-system role
  Future<void> deleteRole(String roleId) async {
    // Find and validate
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;

        // Check not system role
        final roleData = await client
            .from('roles')
            .select('is_system_role')
            .eq('id', roleId)
            .maybeSingle();

        if (roleData != null && roleData['is_system_role'] == true) {
          throw Exception('System roles cannot be deleted');
        }

        await client.from('roles').delete().eq('id', roleId);
      } catch (e) {
        debugPrint('RoleManagementService.deleteRole error: $e');
        rethrow;
      }
      return;
    }

    // Dev mode
    _ensureDevData();
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _devRoles.indexWhere((r) => r.role.id == roleId);
    if (index == -1) throw Exception('Role not found');
    if (_devRoles[index].role.isSystemRole) throw Exception('System roles cannot be deleted');

    _devRoles.removeAt(index);
  }

  /// Clear dev data on logout
  void clear() {
    _devRoles.clear();
    _devPermissions = null;
    _devInitialized = false;
  }
}
