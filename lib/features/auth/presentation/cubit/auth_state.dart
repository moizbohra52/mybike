import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';
import '../../../showroom/domain/entities/showroom_entity.dart';

/// Authentication State Hierarchy
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state prior to session check
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading during login or session check
class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// User is not logged in
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// User logged in, but must select from multiple authorized showrooms
class AuthShowroomSelectionRequired extends AuthState {
  final UserProfile profile;
  final List<ShowroomEntity> authorizedShowrooms;

  const AuthShowroomSelectionRequired({
    required this.profile,
    required this.authorizedShowrooms,
  });

  @override
  List<Object?> get props => [profile, authorizedShowrooms];
}

/// User is authenticated and active showroom is selected
class Authenticated extends AuthState {
  final UserProfile profile;
  final ShowroomEntity activeShowroom;
  final List<ShowroomEntity> authorizedShowrooms;

  const Authenticated({
    required this.profile,
    required this.activeShowroom,
    required this.authorizedShowrooms,
  });

  @override
  List<Object?> get props => [profile, activeShowroom, authorizedShowrooms];
}

/// Error state
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
