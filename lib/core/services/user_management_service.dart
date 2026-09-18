import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'supabase_service.dart';
import '../../features/auth/domain/entities/user_profile.dart';
import '../../features/auth/data/models/user_profile_model.dart';
import '../../features/roles/domain/entities/role_entity.dart';
import '../../features/roles/data/models/role_model.dart';
import '../../features/showroom/domain/entities/showroom_entity.dart';
import '../../features/showroom/data/models/showroom_model.dart';
import 'auth_service.dart';

/// Managed user with hydrated roles and showroom assignments
class ManagedUser {
  final UserProfile profile;
  final List<RoleEntity> roles;
  final List<ShowroomEntity> showrooms;
  final String? defaultShowroomId;

  const ManagedUser({
    required this.profile,
    this.roles = const [],
    this.showrooms = const [],
    this.defaultShowroomId,
  });
}

/// Paginated user list result
class PaginatedUsers {
  final List<ManagedUser> users;
  final int totalCount;

  const PaginatedUsers({required this.users, required this.totalCount});
}

/// User Management Service — CRUD for user profiles, roles & showroom assignments
class UserManagementService {
  UserManagementService._();
  static final UserManagementService instance = UserManagementService._();

  // ─── Dev Mode In-Memory Store ───
  final List<ManagedUser> _devUsers = [];
  bool _devInitialized = false;

  void _ensureDevData() {
    if (_devInitialized) return;
    _devInitialized = true;

    final showrooms = AuthService.devShowrooms;

    _devUsers.addAll([
      ManagedUser(
        profile: UserProfile(
          id: 'dev-u001',
          email: 'admin@mybike.com',
          fullName: 'Rajesh Kumar',
          phone: '+91 98200 11111',
          isActive: true,
          roles: ['super_admin'],
          assignedShowroomIds: showrooms.map((s) => s.id).toList(),
          defaultShowroomId: showrooms.first.id,
          createdAt: DateTime(2026, 4, 1),
          updatedAt: DateTime.now(),
        ),
        roles: [
          const RoleEntity(id: 'role-super_admin', name: 'super_admin', displayName: 'Super Admin', isSystemRole: true),
        ],
        showrooms: showrooms,
        defaultShowroomId: showrooms.first.id,
      ),
      ManagedUser(
        profile: UserProfile(
          id: 'dev-u002',
          email: 'manager@mybike.com',
          fullName: 'Priya Sharma',
          phone: '+91 98200 22222',
          isActive: true,
          roles: ['showroom_manager'],
          assignedShowroomIds: [showrooms[0].id, showrooms[1].id],
          defaultShowroomId: showrooms.first.id,
          createdAt: DateTime(2026, 4, 15),
          updatedAt: DateTime.now(),
        ),
        roles: [
          const RoleEntity(id: 'role-showroom_manager', name: 'showroom_manager', displayName: 'Showroom Manager', isSystemRole: true),
        ],
        showrooms: [showrooms[0], showrooms[1]],
        defaultShowroomId: showrooms.first.id,
      ),
      ManagedUser(
        profile: UserProfile(
          id: 'dev-u003',
          email: 'sales@mybike.com',
          fullName: 'Amit Patel',
          phone: '+91 98200 33333',
          isActive: true,
          roles: ['sales_executive'],
          assignedShowroomIds: [showrooms[0].id],
          defaultShowroomId: showrooms.first.id,
          createdAt: DateTime(2026, 5, 1),
          updatedAt: DateTime.now(),
        ),
        roles: [
          const RoleEntity(id: 'role-sales_executive', name: 'sales_executive', displayName: 'Sales Executive'),
        ],
        showrooms: [showrooms[0]],
        defaultShowroomId: showrooms.first.id,
      ),
      ManagedUser(
        profile: UserProfile(
          id: 'dev-u004',
          email: 'accountant@mybike.com',
          fullName: 'Sneha Desai',
          phone: '+91 98200 44444',
          isActive: true,
          roles: ['accountant'],
          assignedShowroomIds: [showrooms[0].id],
          defaultShowroomId: showrooms.first.id,
          createdAt: DateTime(2026, 5, 10),
          updatedAt: DateTime.now(),
        ),
        roles: [
          const RoleEntity(id: 'role-accountant', name: 'accountant', displayName: 'Accountant'),
        ],
        showrooms: [showrooms[0]],
        defaultShowroomId: showrooms.first.id,
      ),
      ManagedUser(
        profile: UserProfile(
          id: 'dev-u005',
          email: 'inventory@mybike.com',
          fullName: 'Ravi Kulkarni',
          phone: '+91 98200 55555',
          isActive: true,
          roles: ['inventory_manager'],
          assignedShowroomIds: [showrooms[0].id, showrooms[2].id],
          defaultShowroomId: showrooms.first.id,
          createdAt: DateTime(2026, 5, 15),
          updatedAt: DateTime.now(),
        ),
        roles: [
          const RoleEntity(id: 'role-inventory_manager', name: 'inventory_manager', displayName: 'Inventory Manager'),
        ],
        showrooms: [showrooms[0], showrooms[2]],
        defaultShowroomId: showrooms.first.id,
      ),
      ManagedUser(
        profile: UserProfile(
          id: 'dev-u006',
          email: 'viewer@mybike.com',
          fullName: 'Meera Joshi',
          phone: '+91 98200 66666',
          isActive: false,
          roles: ['viewer'],
          assignedShowroomIds: [showrooms[0].id],
          defaultShowroomId: showrooms.first.id,
          createdAt: DateTime(2026, 6, 1),
          updatedAt: DateTime.now(),
        ),
        roles: [
          const RoleEntity(id: 'role-viewer', name: 'viewer', displayName: 'Viewer'),
        ],
        showrooms: [showrooms[0]],
        defaultShowroomId: showrooms.first.id,
      ),
    ]);
  }

  /// Fetch paginated user list with filters
  Future<PaginatedUsers> fetchUsers({
    String? search,
    String? roleFilter,
    String? showroomFilter,
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) async {
    // ─── Live Supabase ───
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;

        // Count query
        var countQuery = client.from('profiles').count(CountOption.exact);
        if (search != null && search.isNotEmpty) {
          countQuery = countQuery.or('full_name.ilike.%$search%,email.ilike.%$search%');
        }
        if (isActive != null) {
          countQuery = countQuery.eq('is_active', isActive);
        }
        final totalCount = await countQuery;

        // Data query
        var query = client
            .from('profiles')
            .select('*, user_roles(role_id, is_active, roles(id, name, display_name, is_system_role)), user_showrooms(showroom_id, is_default, is_active, showrooms(*))');

        if (search != null && search.isNotEmpty) {
          query = query.or('full_name.ilike.%$search%,email.ilike.%$search%');
        }
        if (isActive != null) {
          query = query.eq('is_active', isActive);
        }

        final offset = (page - 1) * pageSize;
        final data = await query
            .order('created_at', ascending: false)
            .range(offset, offset + pageSize - 1);

        final users = (data as List).map((row) {
          final profile = UserProfileModel.fromJson(row);

          List<RoleEntity> roles = [];
          if (row['user_roles'] != null) {
            for (final ur in row['user_roles']) {
              if (ur['roles'] != null && ur['is_active'] == true) {
                roles.add(RoleModel.fromJson(ur['roles']));
              }
            }
          }

          List<ShowroomEntity> showrooms = [];
          String? defaultShowroomId;
          if (row['user_showrooms'] != null) {
            for (final us in row['user_showrooms']) {
              if (us['showrooms'] != null && us['is_active'] == true) {
                showrooms.add(ShowroomModel.fromJson(us['showrooms']));
                if (us['is_default'] == true) {
                  defaultShowroomId = us['showroom_id'];
                }
              }
            }
          }

          return ManagedUser(
            profile: profile,
            roles: roles,
            showrooms: showrooms,
            defaultShowroomId: defaultShowroomId,
          );
        }).toList();

        // Client-side role/showroom filters for simplicity
        var filtered = users;
        if (roleFilter != null && roleFilter.isNotEmpty) {
          filtered = filtered.where((u) => u.roles.any((r) => r.name == roleFilter)).toList();
        }
        if (showroomFilter != null && showroomFilter.isNotEmpty) {
          filtered = filtered.where((u) => u.showrooms.any((s) => s.id == showroomFilter)).toList();
        }

        return PaginatedUsers(users: filtered, totalCount: totalCount);
      } catch (e) {
        debugPrint('UserManagementService.fetchUsers error: $e');
        rethrow;
      }
    }

    // ─── Dev Mode ───
    _ensureDevData();
    await Future.delayed(const Duration(milliseconds: 400));

    var result = List<ManagedUser>.from(_devUsers);

    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      result = result.where((u) {
        return (u.profile.fullName?.toLowerCase().contains(q) ?? false) ||
            u.profile.email.toLowerCase().contains(q);
      }).toList();
    }

    if (roleFilter != null && roleFilter.isNotEmpty) {
      result = result.where((u) => u.profile.roles.contains(roleFilter)).toList();
    }

    if (showroomFilter != null && showroomFilter.isNotEmpty) {
      result = result.where((u) => u.showrooms.any((s) => s.id == showroomFilter)).toList();
    }

    if (isActive != null) {
      result = result.where((u) => u.profile.isActive == isActive).toList();
    }

    final totalCount = result.length;
    final startIndex = (page - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, result.length);
    final paginated = startIndex < result.length ? result.sublist(startIndex, endIndex) : <ManagedUser>[];

    return PaginatedUsers(users: paginated, totalCount: totalCount);
  }

  /// Fetch single user by ID with full details
  Future<ManagedUser?> fetchUserById(String userId) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;
        final data = await client
            .from('profiles')
            .select('*, user_roles(role_id, is_active, roles(id, name, display_name, description, is_system_role)), user_showrooms(showroom_id, is_default, is_active, showrooms(*))')
            .eq('id', userId)
            .maybeSingle();

        if (data == null) return null;

        final profile = UserProfileModel.fromJson(data);
        List<RoleEntity> roles = [];
        if (data['user_roles'] != null) {
          for (final ur in data['user_roles']) {
            if (ur['roles'] != null && ur['is_active'] == true) {
              roles.add(RoleModel.fromJson(ur['roles']));
            }
          }
        }

        List<ShowroomEntity> showrooms = [];
        String? defaultShowroomId;
        if (data['user_showrooms'] != null) {
          for (final us in data['user_showrooms']) {
            if (us['showrooms'] != null && us['is_active'] == true) {
              showrooms.add(ShowroomModel.fromJson(us['showrooms']));
              if (us['is_default'] == true) {
                defaultShowroomId = us['showroom_id'];
              }
            }
          }
        }

        return ManagedUser(profile: profile, roles: roles, showrooms: showrooms, defaultShowroomId: defaultShowroomId);
      } catch (e) {
        debugPrint('UserManagementService.fetchUserById error: $e');
        rethrow;
      }
    }

    // Dev mode
    _ensureDevData();
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _devUsers.firstWhere((u) => u.profile.id == userId);
    } catch (_) {
      return null;
    }
  }

  /// Create a new user (calls Edge Function in live mode)
  Future<ManagedUser> createUser({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required List<String> roleIds,
    required List<String> showroomIds,
    String? defaultShowroomId,
  }) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final res = await SupabaseService.client!.functions.invoke(
          'create-user',
          body: {
            'email': email,
            'password': password,
            'full_name': fullName,
            'phone': phone,
            'role_ids': roleIds,
            'showroom_ids': showroomIds,
            'default_showroom_id': defaultShowroomId,
          },
        );

        if (res.status != 201) {
          final error = res.data is Map ? res.data['error'] : 'Unknown error';
          throw Exception(error);
        }

        final userId = res.data['user']['id'] as String;
        final user = await fetchUserById(userId);
        if (user == null) throw Exception('Failed to load created user');
        return user;
      } catch (e) {
        debugPrint('UserManagementService.createUser error: $e');
        rethrow;
      }
    }

    // Dev mode
    _ensureDevData();
    await Future.delayed(const Duration(milliseconds: 500));

    final allShowrooms = AuthService.devShowrooms;
    final userShowrooms = allShowrooms.where((s) => showroomIds.contains(s.id)).toList();
    final userRoles = roleIds.map((rid) {
      return RoleEntity(
        id: rid,
        name: rid.replaceFirst('role-', ''),
        displayName: rid.replaceFirst('role-', '').replaceAll('_', ' '),
      );
    }).toList();

    final newUser = ManagedUser(
      profile: UserProfile(
        id: 'dev-u${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        fullName: fullName,
        phone: phone,
        isActive: true,
        roles: userRoles.map((r) => r.name).toList(),
        assignedShowroomIds: showroomIds,
        defaultShowroomId: defaultShowroomId ?? (showroomIds.isNotEmpty ? showroomIds.first : null),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      roles: userRoles,
      showrooms: userShowrooms,
      defaultShowroomId: defaultShowroomId,
    );

    _devUsers.insert(0, newUser);
    return newUser;
  }

  /// Update user profile
  Future<void> updateUserProfile(
    String userId, {
    String? fullName,
    String? phone,
    bool? isActive,
  }) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final updates = <String, dynamic>{};
        if (fullName != null) updates['full_name'] = fullName;
        if (phone != null) updates['phone'] = phone;
        if (isActive != null) updates['is_active'] = isActive;

        if (updates.isNotEmpty) {
          await SupabaseService.client!
              .from('profiles')
              .update(updates)
              .eq('id', userId);
        }
      } catch (e) {
        debugPrint('UserManagementService.updateUserProfile error: $e');
        rethrow;
      }
      return;
    }

    // Dev mode
    _ensureDevData();
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _devUsers.indexWhere((u) => u.profile.id == userId);
    if (index == -1) throw Exception('User not found');

    final existing = _devUsers[index];
    _devUsers[index] = ManagedUser(
      profile: existing.profile.copyWith(
        fullName: fullName ?? existing.profile.fullName,
        phone: phone ?? existing.profile.phone,
        isActive: isActive ?? existing.profile.isActive,
        updatedAt: DateTime.now(),
      ),
      roles: existing.roles,
      showrooms: existing.showrooms,
      defaultShowroomId: existing.defaultShowroomId,
    );
  }

  /// Assign roles to a user (replaces existing assignments)
  Future<void> assignRoles(String userId, List<String> roleIds) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;

        // Deactivate all current roles
        await client
            .from('user_roles')
            .update({'is_active': false})
            .eq('user_id', userId);

        // Upsert new role assignments
        if (roleIds.isNotEmpty) {
          final inserts = roleIds.map((rid) => {
                'user_id': userId,
                'role_id': rid,
                'is_active': true,
              }).toList();

          await client
              .from('user_roles')
              .upsert(inserts, onConflict: 'user_id,role_id');
        }
      } catch (e) {
        debugPrint('UserManagementService.assignRoles error: $e');
        rethrow;
      }
      return;
    }

    // Dev mode
    _ensureDevData();
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _devUsers.indexWhere((u) => u.profile.id == userId);
    if (index == -1) throw Exception('User not found');

    final existing = _devUsers[index];
    final newRoles = roleIds.map((rid) {
      return RoleEntity(
        id: rid,
        name: rid.replaceFirst('role-', ''),
        displayName: rid.replaceFirst('role-', '').replaceAll('_', ' '),
      );
    }).toList();

    _devUsers[index] = ManagedUser(
      profile: existing.profile.copyWith(
        roles: newRoles.map((r) => r.name).toList(),
        updatedAt: DateTime.now(),
      ),
      roles: newRoles,
      showrooms: existing.showrooms,
      defaultShowroomId: existing.defaultShowroomId,
    );
  }

  /// Assign showrooms to a user (replaces existing assignments)
  Future<void> assignShowrooms(
    String userId,
    List<String> showroomIds, {
    String? defaultShowroomId,
  }) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final client = SupabaseService.client!;

        // Deactivate all current showroom assignments
        await client
            .from('user_showrooms')
            .update({'is_active': false})
            .eq('user_id', userId);

        // Upsert new showroom assignments
        if (showroomIds.isNotEmpty) {
          final inserts = showroomIds.map((sid) => {
                'user_id': userId,
                'showroom_id': sid,
                'is_default': sid == defaultShowroomId,
                'is_active': true,
              }).toList();

          await client
              .from('user_showrooms')
              .upsert(inserts, onConflict: 'user_id,showroom_id');
        }
      } catch (e) {
        debugPrint('UserManagementService.assignShowrooms error: $e');
        rethrow;
      }
      return;
    }

    // Dev mode
    _ensureDevData();
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _devUsers.indexWhere((u) => u.profile.id == userId);
    if (index == -1) throw Exception('User not found');

    final existing = _devUsers[index];
    final allShowrooms = AuthService.devShowrooms;
    final userShowrooms = allShowrooms.where((s) => showroomIds.contains(s.id)).toList();

    _devUsers[index] = ManagedUser(
      profile: existing.profile.copyWith(
        assignedShowroomIds: showroomIds,
        defaultShowroomId: defaultShowroomId ?? (showroomIds.isNotEmpty ? showroomIds.first : null),
        updatedAt: DateTime.now(),
      ),
      roles: existing.roles,
      showrooms: userShowrooms,
      defaultShowroomId: defaultShowroomId,
    );
  }

  /// Toggle user active status
  Future<void> toggleUserActive(String userId, bool isActive) async {
    await updateUserProfile(userId, isActive: isActive);
  }

  /// Clear dev data on logout
  void clear() {
    _devUsers.clear();
    _devInitialized = false;
  }
}
