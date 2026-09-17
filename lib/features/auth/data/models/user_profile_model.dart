import '../../domain/entities/user_profile.dart';

/// User Profile Data Model with Supabase / PostgreSQL serialization
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    super.fullName,
    super.phone,
    super.avatarUrl,
    super.isActive = true,
    super.roles = const [],
    super.assignedShowroomIds = const [],
    super.defaultShowroomId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedRoles = [];
    if (json['roles'] != null) {
      if (json['roles'] is List) {
        parsedRoles = (json['roles'] as List)
            .map((r) => r is Map ? (r['name'] ?? '').toString() : r.toString())
            .where((name) => name.isNotEmpty)
            .toList();
      }
    }

    List<String> parsedShowrooms = [];
    String? defaultShowroom;
    if (json['user_showrooms'] != null && json['user_showrooms'] is List) {
      for (final item in json['user_showrooms']) {
        if (item is Map) {
          final sId = item['showroom_id']?.toString();
          if (sId != null && sId.isNotEmpty) {
            parsedShowrooms.add(sId);
            if (item['is_default'] == true) {
              defaultShowroom = sId;
            }
          }
        }
      }
    }

    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      roles: parsedRoles,
      assignedShowroomIds: parsedShowrooms,
      defaultShowroomId: defaultShowroom,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
