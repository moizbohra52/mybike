import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';

/// Navigation Route Guards for MYBIKE ERP
class RouteGuards {
  RouteGuards._();

  /// Handle authentication redirection rules
  static String? handleAuthRedirect(
    BuildContext context,
    GoRouterState state,
    AuthState authState,
  ) {
    final location = state.uri.path;
    final isSplash = location == '/splash' || location == '/';
    final isLogin = location == '/login';
    final isShowroomSelect = location == '/showroom-selection';

    // 1. App is initializing / checking session
    if (authState is AuthInitial || authState is AuthLoading) {
      return null;
    }

    // 2. Unauthenticated user
    if (authState is Unauthenticated || authState is AuthError) {
      if (isLogin) return null;
      return '/login';
    }

    // 3. User authenticated but needs to select a showroom
    if (authState is AuthShowroomSelectionRequired) {
      if (isShowroomSelect) return null;
      return '/showroom-selection';
    }

    // 4. Authenticated user
    if (authState is Authenticated) {
      if (isLogin || isSplash || isShowroomSelect) {
        return '/dashboard';
      }
      return null;
    }

    return null;
  }
}
