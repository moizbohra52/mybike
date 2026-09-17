import 'package:equatable/equatable.dart';

/// User Profile Domain Entity
class UserProfile extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final bool isActive;
  final List<String> roles;
  final List<String> assignedShowroomIds;
  final String? defaultShowroomId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.isActive = true,
    this.roles = const [],
    this.assignedShowroomIds = const [],
    this.defaultShowroomId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role);

  /// Check if user is Super Admin
  bool get isSuperAdmin => hasRole('super_admin');

  /// Check if user is Admin
  bool get isAdmin => isSuperAdmin || hasRole('admin');

  /// Check if user has access to a showroom
  bool hasShowroomAccess(String showroomId) {
    if (isSuperAdmin || isAdmin) return true;
    return assignedShowroomIds.contains(showroomId);
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatarUrl,
    bool? isActive,
    List<String>? roles,
    List<String>? assignedShowroomIds,
    String? defaultShowroomId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      roles: roles ?? this.roles,
      assignedShowroomIds: assignedShowroomIds ?? this.assignedShowroomIds,
      defaultShowroomId: defaultShowroomId ?? this.defaultShowroomId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phone,
        avatarUrl,
        isActive,
        roles,
        assignedShowroomIds,
        defaultShowroomId,
        createdAt,
        updatedAt,
      ];
}
