import 'package:equatable/equatable.dart';
import '../../../../core/services/user_management_service.dart';
import '../../../roles/domain/entities/role_entity.dart';
import '../../../showroom/domain/entities/showroom_entity.dart';

/// User Form (Create/Edit) States
abstract class UserFormState extends Equatable {
  const UserFormState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class UserFormInitial extends UserFormState {
  const UserFormInitial();
}

/// Loading user data or available options
class UserFormLoading extends UserFormState {
  const UserFormLoading();
}

/// Form ready with user data (edit) or empty (create)
class UserFormReady extends UserFormState {
  final ManagedUser? existingUser; // null = create mode
  final List<RoleEntity> availableRoles;
  final List<ShowroomEntity> availableShowrooms;
  final List<String> selectedRoleIds;
  final List<String> selectedShowroomIds;
  final String? defaultShowroomId;

  const UserFormReady({
    this.existingUser,
    required this.availableRoles,
    required this.availableShowrooms,
    this.selectedRoleIds = const [],
    this.selectedShowroomIds = const [],
    this.defaultShowroomId,
  });

  bool get isEditMode => existingUser != null;

  UserFormReady copyWith({
    ManagedUser? existingUser,
    List<RoleEntity>? availableRoles,
    List<ShowroomEntity>? availableShowrooms,
    List<String>? selectedRoleIds,
    List<String>? selectedShowroomIds,
    String? defaultShowroomId,
    bool clearDefault = false,
  }) {
    return UserFormReady(
      existingUser: existingUser ?? this.existingUser,
      availableRoles: availableRoles ?? this.availableRoles,
      availableShowrooms: availableShowrooms ?? this.availableShowrooms,
      selectedRoleIds: selectedRoleIds ?? this.selectedRoleIds,
      selectedShowroomIds: selectedShowroomIds ?? this.selectedShowroomIds,
      defaultShowroomId: clearDefault ? null : (defaultShowroomId ?? this.defaultShowroomId),
    );
  }

  @override
  List<Object?> get props => [
        existingUser,
        availableRoles,
        availableShowrooms,
        selectedRoleIds,
        selectedShowroomIds,
        defaultShowroomId,
      ];
}

/// Saving user data
class UserFormSaving extends UserFormState {
  const UserFormSaving();
}

/// User saved successfully
class UserFormSuccess extends UserFormState {
  final String message;
  const UserFormSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error in form operation
class UserFormError extends UserFormState {
  final String message;
  const UserFormError(this.message);

  @override
  List<Object?> get props => [message];
}
