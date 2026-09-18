import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/user_management_service.dart';
import 'user_management_state.dart';

/// User Management List Cubit
class UserManagementCubit extends Cubit<UserManagementState> {
  final UserManagementService _service;

  UserManagementCubit({UserManagementService? service})
      : _service = service ?? UserManagementService.instance,
        super(const UserManagementInitial());

  // Current filters (retained across reloads)
  String? _searchQuery;
  String? _roleFilter;
  String? _showroomFilter;
  bool? _activeFilter;
  int _currentPage = 1;
  int _pageSize = 10;

  /// Load users with current filters
  Future<void> loadUsers() async {
    emit(const UserManagementLoading());
    try {
      final result = await _service.fetchUsers(
        search: _searchQuery,
        roleFilter: _roleFilter,
        showroomFilter: _showroomFilter,
        isActive: _activeFilter,
        page: _currentPage,
        pageSize: _pageSize,
      );

      emit(UserManagementLoaded(
        users: result.users,
        totalCount: result.totalCount,
        currentPage: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchQuery,
        roleFilter: _roleFilter,
        showroomFilter: _showroomFilter,
        activeFilter: _activeFilter,
      ));
    } catch (e) {
      emit(UserManagementError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Search users by name or email
  Future<void> searchUsers(String query) async {
    _searchQuery = query.isEmpty ? null : query;
    _currentPage = 1;
    await loadUsers();
  }

  /// Filter by role name
  Future<void> filterByRole(String? roleName) async {
    _roleFilter = roleName;
    _currentPage = 1;
    await loadUsers();
  }

  /// Filter by showroom ID
  Future<void> filterByShowroom(String? showroomId) async {
    _showroomFilter = showroomId;
    _currentPage = 1;
    await loadUsers();
  }

  /// Toggle active/inactive filter
  Future<void> toggleActiveFilter(bool? isActive) async {
    _activeFilter = isActive;
    _currentPage = 1;
    await loadUsers();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _searchQuery = null;
    _roleFilter = null;
    _showroomFilter = null;
    _activeFilter = null;
    _currentPage = 1;
    await loadUsers();
  }

  /// Change page
  Future<void> changePage(int page) async {
    _currentPage = page;
    await loadUsers();
  }

  /// Change page size
  Future<void> changePageSize(int size) async {
    _pageSize = size;
    _currentPage = 1;
    await loadUsers();
  }

  /// Toggle user active status
  Future<void> toggleUserActive(String userId, bool isActive) async {
    try {
      await _service.toggleUserActive(userId, isActive);
      await loadUsers();
    } catch (e) {
      emit(UserManagementError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
