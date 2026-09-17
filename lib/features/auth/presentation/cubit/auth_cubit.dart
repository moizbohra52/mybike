import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';
import '../../../showroom/domain/entities/showroom_entity.dart';
import '../../../../core/services/showroom_service.dart';

/// Authentication Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit({AuthRepository? repository})
      : _repository = repository ?? AuthRepository(),
        super(const AuthInitial());

  /// Check for existing user session
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading(message: 'Checking session...'));
    try {
      final session = await _repository.checkSession();
      if (session == null) {
        emit(const Unauthenticated());
        return;
      }

      _resolvePostAuth(session.profile, session.showrooms);
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  /// Sign in user
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading(message: 'Authenticating...'));
    try {
      final session = await _repository.login(
        email: email,
        password: password,
      );

      _resolvePostAuth(session.profile, session.showrooms);
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(errorMsg));
    }
  }

  /// Resolve whether user goes straight to Authenticated or needs to pick a showroom
  void _resolvePostAuth(dynamic profile, List<ShowroomEntity> showrooms) {
    if (showrooms.isEmpty) {
      // Fallback single default if none assigned
      final defaultShowroom = AuthService.devShowrooms.first;
      emit(Authenticated(
        profile: profile,
        activeShowroom: defaultShowroom,
        authorizedShowrooms: [defaultShowroom],
      ));
      return;
    }

    final activeShowroom = ShowroomService.instance.activeShowroom;

    if (showrooms.length > 1 && activeShowroom == null) {
      emit(AuthShowroomSelectionRequired(
        profile: profile,
        authorizedShowrooms: showrooms,
      ));
    } else {
      emit(Authenticated(
        profile: profile,
        activeShowroom: activeShowroom ?? showrooms.first,
        authorizedShowrooms: showrooms,
      ));
    }
  }

  /// Select a showroom from multiple authorized options
  Future<void> selectShowroom(ShowroomEntity showroom) async {
    await ShowroomService.instance.switchShowroom(showroom);

    if (state is AuthShowroomSelectionRequired) {
      final s = state as AuthShowroomSelectionRequired;
      emit(Authenticated(
        profile: s.profile,
        activeShowroom: showroom,
        authorizedShowrooms: s.authorizedShowrooms,
      ));
    } else if (state is Authenticated) {
      final s = state as Authenticated;
      emit(Authenticated(
        profile: s.profile,
        activeShowroom: showroom,
        authorizedShowrooms: s.authorizedShowrooms,
      ));
    }
  }

  /// Log out
  Future<void> logout() async {
    emit(const AuthLoading(message: 'Signing out...'));
    try {
      await _repository.logout();
    } catch (_) {}
    emit(const Unauthenticated());
  }
}
