import '../../features/auth/domain/entities/user_profile.dart';
import '../../features/roles/domain/entities/role_entity.dart';

/// Client-Side Permission & Role Access Control Service
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  UserProfile? _currentProfile;
  List<RoleEntity> _userRoles = [];
  final Set<String> _permissionCache = {};

  /// Set the authenticated user profile and roles
  void initialize({
    required UserProfile userProfile,
    List<RoleEntity> roles = const [],
  }) {
    _currentProfile = userProfile;
    _userRoles = roles;
    _rebuildPermissionCache();
  }

  /// Current user profile
  UserProfile? get currentProfile => _currentProfile;

  /// Active roles list
  List<RoleEntity> get userRoles => _userRoles;

  /// Check if user has Super Admin privileges
  bool get isSuperAdmin => _currentProfile?.isSuperAdmin ?? false;

  /// Check if user has Admin or Super Admin privileges
  bool get isAdmin => _currentProfile?.isAdmin ?? false;

  /// Check if user has a specific role
  bool hasRole(String roleName) {
    if (isSuperAdmin) return true;
    return _currentProfile?.hasRole(roleName) ?? false;
  }

  /// Check if user has permission to perform [action] on [module]
  bool hasPermission(String module, String action) {
    if (isSuperAdmin) return true;

    final key = '$module.$action';
    if (_permissionCache.contains(key)) return true;
    if (_permissionCache.contains('$module.*')) return true;

    return false;
  }

  // ─── Shortcut Helpers ───
  bool canView(String module) => hasPermission(module, 'view');
  bool canCreate(String module) => hasPermission(module, 'create');
  bool canEdit(String module) => hasPermission(module, 'edit');
  bool canDelete(String module) => hasPermission(module, 'delete');
  bool canApprove(String module) => hasPermission(module, 'approve');
  bool canExport(String module) => hasPermission(module, 'export');
  bool canPrint(String module) => hasPermission(module, 'print');

  /// Clear state on logout
  void clear() {
    _currentProfile = null;
    _userRoles = [];
    _permissionCache.clear();
  }

  void _rebuildPermissionCache() {
    _permissionCache.clear();
    for (final role in _userRoles) {
      for (final permission in role.permissions) {
        _permissionCache.add('${permission.module}.${permission.action}');
      }
    }
  }
}
