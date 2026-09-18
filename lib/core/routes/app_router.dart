import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/showroom_selection_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/showroom/presentation/screens/showroom_list_screen.dart';
import '../../features/showroom/presentation/screens/showroom_form_screen.dart';
import '../../features/showroom/presentation/screens/showroom_detail_screen.dart';
import '../../features/users/presentation/screens/user_list_screen.dart';
import '../../features/users/presentation/screens/user_form_screen.dart';
import '../../features/users/presentation/screens/user_detail_screen.dart';
import '../../features/users/presentation/screens/role_list_screen.dart';
import '../../features/users/presentation/screens/role_form_screen.dart';
import '../../common/components/app_error_state.dart';

/// MYBIKE Router Configuration
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: _routes,
    errorBuilder: (context, state) => Scaffold(
      body: AppErrorState(
        title: 'Page Not Found',
        message: 'The requested route "${state.uri.path}" could not be found.',
        onBack: () => context.goNamed(RouteNames.dashboard),
        retryLabel: 'Go to Dashboard',
        onRetry: () => context.goNamed(RouteNames.dashboard),
      ),
    ),
  );

  static final List<RouteBase> _routes = [
    // ─── Splash ───
    GoRoute(
      path: '/',
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // ─── Login ───
    GoRoute(
      path: '/login',
      name: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),

    // ─── Showroom Selection (Multi-showroom authorized staff) ───
    GoRoute(
      path: '/showroom-selection',
      name: RouteNames.showroomSelection,
      builder: (context, state) => const ShowroomSelectionScreen(),
    ),

    // ─── Dashboard ───
    GoRoute(
      path: '/dashboard',
      name: RouteNames.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),

    // ─── Showroom Management ───
    GoRoute(
      path: '/showrooms',
      name: RouteNames.showrooms,
      builder: (context, state) => const ShowroomListScreen(),
    ),
    GoRoute(
      path: '/showrooms/create',
      name: RouteNames.showroomCreate,
      builder: (context, state) {
        final editId = state.uri.queryParameters['editId'];
        return ShowroomFormScreen(editShowroomId: editId);
      },
    ),
    GoRoute(
      path: '/showrooms/:showroomId',
      name: RouteNames.showroomDetail,
      builder: (context, state) {
        final showroomId = state.pathParameters['showroomId']!;
        return ShowroomDetailScreen(showroomId: showroomId);
      },
    ),

    // ─── User Management ───
    GoRoute(
      path: '/users',
      name: RouteNames.users,
      builder: (context, state) => const UserListScreen(),
    ),
    GoRoute(
      path: '/users/create',
      name: RouteNames.userCreate,
      builder: (context, state) {
        final editId = state.uri.queryParameters['editId'];
        return UserFormScreen(editUserId: editId);
      },
    ),
    GoRoute(
      path: '/users/:userId',
      name: RouteNames.userDetail,
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return UserDetailScreen(userId: userId);
      },
    ),

    // ─── Role Management ───
    GoRoute(
      path: '/roles',
      name: RouteNames.roles,
      builder: (context, state) {
        final action = state.uri.queryParameters['action'];
        final roleId = state.uri.queryParameters['roleId'];

        if (action == 'create') {
          return const RoleFormScreen();
        }
        if (action == 'edit' && roleId != null) {
          return RoleFormScreen(editRoleId: roleId);
        }

        return const RoleListScreen();
      },
    ),
  ];
}
