import 'package:equatable/equatable.dart';
import '../../../../core/services/user_management_service.dart';

/// User Management List States
abstract class UserManagementState extends Equatable {
  const UserManagementState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class UserManagementInitial extends UserManagementState {
  const UserManagementInitial();
}

/// Loading users
class UserManagementLoading extends UserManagementState {
  const UserManagementLoading();
}

/// Users loaded successfully
class UserManagementLoaded extends UserManagementState {
  final List<ManagedUser> users;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final String? searchQuery;
  final String? roleFilter;
  final String? showroomFilter;
  final bool? activeFilter;

  const UserManagementLoaded({
    required this.users,
    required this.totalCount,
    this.currentPage = 1,
    this.pageSize = 10,
    this.searchQuery,
    this.roleFilter,
    this.showroomFilter,
    this.activeFilter,
  });

  int get totalPages => (totalCount / pageSize).ceil().clamp(1, 999);

  UserManagementLoaded copyWith({
    List<ManagedUser>? users,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    String? searchQuery,
    String? roleFilter,
    String? showroomFilter,
    bool? activeFilter,
    bool clearSearch = false,
    bool clearRoleFilter = false,
    bool clearShowroomFilter = false,
    bool clearActiveFilter = false,
  }) {
    return UserManagementLoaded(
      users: users ?? this.users,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      roleFilter: clearRoleFilter ? null : (roleFilter ?? this.roleFilter),
      showroomFilter: clearShowroomFilter ? null : (showroomFilter ?? this.showroomFilter),
      activeFilter: clearActiveFilter ? null : (activeFilter ?? this.activeFilter),
    );
  }

  @override
  List<Object?> get props => [
        users,
        totalCount,
        currentPage,
        pageSize,
        searchQuery,
        roleFilter,
        showroomFilter,
        activeFilter,
      ];
}

/// Error loading users
class UserManagementError extends UserManagementState {
  final String message;
  const UserManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
