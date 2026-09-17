import '../../../../core/services/auth_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/showroom_service.dart';

/// Authentication Repository implementation
class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService.instance;

  /// Perform login and initialize client-side security services
  Future<AuthSessionData> login({
    required String email,
    required String password,
  }) async {
    final sessionData = await _authService.signIn(
      email: email,
      password: password,
    );

    // Initialize security services
    PermissionService.instance.initialize(
      userProfile: sessionData.profile,
      roles: sessionData.roles,
    );

    await ShowroomService.instance.initialize(
      authorizedShowrooms: sessionData.showrooms,
      defaultShowroomId: sessionData.profile.defaultShowroomId,
    );

    return sessionData;
  }

  /// Check and restore existing session
  Future<AuthSessionData?> checkSession() async {
    final sessionData = await _authService.checkSession();
    if (sessionData != null) {
      PermissionService.instance.initialize(
        userProfile: sessionData.profile,
        roles: sessionData.roles,
      );

      await ShowroomService.instance.initialize(
        authorizedShowrooms: sessionData.showrooms,
        defaultShowroomId: sessionData.profile.defaultShowroomId,
      );
    }
    return sessionData;
  }

  /// Log out and clear all services
  Future<void> logout() async {
    await _authService.signOut();
    PermissionService.instance.clear();
    await ShowroomService.instance.clear();
  }
}
