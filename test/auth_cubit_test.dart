import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mybike/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mybike/features/auth/presentation/cubit/auth_state.dart';
import 'package:mybike/core/routes/route_guards.dart';
import 'package:mybike/features/auth/domain/entities/user_profile.dart';
import 'package:mybike/features/showroom/domain/entities/showroom_entity.dart';
import 'package:go_router/go_router.dart';

class TestAuthCubit extends AuthCubit {
  void emitState(AuthState newState) => emit(newState);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 5 — Authentication & Session Management Tests', () {
    test('AuthCubit starts in AuthInitial state', () {
      final cubit = AuthCubit();
      expect(cubit.state, isA<AuthInitial>());
      cubit.close();
    });

    test('AuthCubit login with sales staff emits Authenticated with default showroom', () async {
      final cubit = AuthCubit();

      await cubit.login(email: 'sales@mybike.com', password: 'password123');

      expect(cubit.state, isA<Authenticated>());
      final authState = cubit.state as Authenticated;
      expect(authState.profile.email, 'sales@mybike.com');
      expect(authState.activeShowroom.code, 'IND-MAIN');

      await cubit.close();
    });

    test('AuthCubit login with multi-showroom admin resolves showrooms and allows selection', () async {
      final cubit = AuthCubit();

      await cubit.login(email: 'admin@mybike.com', password: 'admin123');

      expect(
        cubit.state is Authenticated || cubit.state is AuthShowroomSelectionRequired,
        isTrue,
      );

      final showroomToSelect = ShowroomEntity(
        id: 'sh-002',
        name: 'MYBIKE West Hub',
        code: 'IND-WEST',
        address: 'Addr',
        city: 'Pune',
        state: 'Maharashtra',
        pincode: '411057',
        phone: '123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await cubit.selectShowroom(showroomToSelect);

      expect(cubit.state, isA<Authenticated>());
      final authState = cubit.state as Authenticated;
      expect(authState.activeShowroom.code, 'IND-WEST');

      await cubit.close();
    });

    test('AuthCubit logout transitions to Unauthenticated', () async {
      final cubit = AuthCubit();

      await cubit.login(email: 'sales@mybike.com', password: 'password123');
      expect(cubit.state, isA<Authenticated>());

      await cubit.logout();
      expect(cubit.state, isA<Unauthenticated>());

      await cubit.close();
    });

    testWidgets('RouteGuards and GoRouter route authenticated and unauthenticated states', (tester) async {
      final authCubit = TestAuthCubit();

      final testRouter = GoRouter(
        initialLocation: '/dashboard',
        redirect: (context, state) => RouteGuards.handleAuthRedirect(
          context,
          state,
          authCubit.state,
        ),
        routes: [
          GoRoute(
            path: '/login',
            builder: (_, _) => const Scaffold(body: Text('Login Page')),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (_, _) => const Scaffold(body: Text('Dashboard Page')),
          ),
          GoRoute(
            path: '/showroom-selection',
            builder: (_, _) => const Scaffold(body: Text('Select Showroom Page')),
          ),
        ],
      );

      // 1. Initially unauthenticated, navigating to /dashboard redirects to /login
      authCubit.emitState(const Unauthenticated());
      await tester.pumpWidget(MaterialApp.router(routerConfig: testRouter));
      await tester.pumpAndSettle();
      expect(find.text('Login Page'), findsOneWidget);

      // 2. User needs to pick a showroom
      authCubit.emitState(AuthShowroomSelectionRequired(
        profile: UserProfile(
          id: 'u1',
          email: 'admin@mybike.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        authorizedShowrooms: const [],
      ));
      testRouter.refresh();
      await tester.pumpAndSettle();
      expect(find.text('Select Showroom Page'), findsOneWidget);

      // 3. Authenticated -> routes to dashboard
      authCubit.emitState(Authenticated(
        profile: UserProfile(
          id: 'u1',
          email: 'admin@mybike.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        activeShowroom: ShowroomEntity(
          id: 'sh-1',
          name: 'Main',
          code: 'MAIN',
          address: 'Addr',
          city: 'City',
          state: 'State',
          pincode: '400001',
          phone: '123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        authorizedShowrooms: const [],
      ));
      testRouter.refresh();
      await tester.pumpAndSettle();
      expect(find.text('Dashboard Page'), findsOneWidget);

      await authCubit.close();
    });
  });
}
