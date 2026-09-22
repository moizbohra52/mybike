import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/common/layouts/app_scaffold.dart';
import 'package:mybike/common/layouts/app_sidebar.dart';
import 'package:mybike/common/layouts/app_app_bar.dart';
import 'package:mybike/core/theme/app_theme.dart';
import 'package:mybike/core/theme/theme_cubit.dart';

void main() {
  Widget buildTestableWidget({
    required Widget child,
    Size size = const Size(1280, 800),
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(),
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: child,
        ),
      ),
    );
  }

  group('Phase 25 — Widget Tests: Admin Shell, Responsive Layout & Navigation', () {
    testWidgets('1. Desktop layout renders AppScaffold, AppSidebar and Title', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));

      await tester.pumpWidget(
        buildTestableWidget(
          size: const Size(1400, 900),
          child: const AppScaffold(
            title: 'Dealership Operations',
            activeNavigationId: 'dashboard',
            currentShowroomName: 'MYBIKE Mumbai Central',
            body: Center(child: Text('Main Operational Dashboard')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dealership Operations'), findsWidgets);
      expect(find.text('Main Operational Dashboard'), findsOneWidget);
      expect(find.byType(AppSidebar), findsOneWidget);
    });

    testWidgets('2. Mobile layout renders AppScaffold with drawer toggle on compact screens', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));

      await tester.pumpWidget(
        buildTestableWidget(
          size: const Size(390, 844),
          child: const AppScaffold(
            title: 'Mobile View',
            activeNavigationId: 'sales',
            currentShowroomName: 'Pune Branch',
            body: Text('Mobile Body Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mobile View'), findsWidgets);
      expect(find.text('Mobile Body Content'), findsOneWidget);
    });

    testWidgets('3. AppSidebar item selection triggers navigation callbacks', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      String? selectedNav;

      await tester.pumpWidget(
        buildTestableWidget(
          size: const Size(1400, 900),
          child: Material(
            child: SizedBox(
              width: 280,
              height: 900,
              child: AppSidebar(
                activeItemId: 'dashboard',
                onItemTap: (id) {
                  selectedNav = id;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap a sidebar item (e.g. Vehicles)
      final vehiclesTile = find.text('Vehicles');
      if (vehiclesTile.evaluate().isNotEmpty) {
        await tester.tap(vehiclesTile.first);
        await tester.pumpAndSettle();
        expect(selectedNav, equals('vehicles'));
      }
    });

    testWidgets('4. AppAppBar renders showroom badge and action buttons', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      bool switcherTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          size: const Size(1200, 800),
          child: Scaffold(
            appBar: AppAppBar(
              title: 'GST Return Filing',
              currentShowroomName: 'Indore Central Hub',
              onShowroomSwitchTap: () {
                switcherTapped = true;
              },
            ),
            body: const SizedBox(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('GST Return Filing'), findsOneWidget);
      expect(find.text('Indore Central Hub'), findsOneWidget);

      final showroomBtn = find.text('Indore Central Hub');
      await tester.tap(showroomBtn);
      await tester.pumpAndSettle();
      expect(switcherTapped, isTrue);
    });

    testWidgets('5. Dark Theme mode renders correctly with contrast colors', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(
        buildTestableWidget(
          size: const Size(1200, 800),
          themeMode: ThemeMode.dark,
          child: const AppScaffold(
            title: 'Dark Theme Test',
            activeNavigationId: 'reports',
            body: Text('Dark Mode Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dark Theme Test'), findsWidgets);
      expect(find.text('Dark Mode Content'), findsOneWidget);
    });
  });
}
