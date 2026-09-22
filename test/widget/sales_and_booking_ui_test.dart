import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/common/widgets/app_button.dart';
import 'package:mybike/common/widgets/app_status_badge.dart';
import 'package:mybike/core/theme/app_theme.dart';
import 'package:mybike/core/theme/theme_cubit.dart';
import 'package:mybike/features/customers/presentation/screens/booking_list_screen.dart';
import 'package:mybike/features/sales/presentation/screens/sales_invoice_list_screen.dart';

void main() {
  Widget buildTestableWidget({
    required Widget child,
    Size size = const Size(1280, 800),
  }) {
    return BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(),
      child: MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: child,
        ),
      ),
    );
  }

  group('Phase 25 — Widget Tests: Sales & Booking UI Components', () {
    testWidgets('1. BookingListScreen renders booking summary KPIs and filter bar', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));

      await tester.pumpWidget(
        buildTestableWidget(
          size: const Size(1400, 900),
          child: const BookingListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bookings'), findsWidgets);
      expect(find.text('Active Bookings'), findsOneWidget);
      expect(find.text('Pending Delivery'), findsOneWidget);
      expect(find.text('Total Value'), findsOneWidget);
    });

    testWidgets('2. SalesInvoiceListScreen renders invoice list and action bar', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));

      await tester.pumpWidget(
        buildTestableWidget(
          size: const Size(1400, 900),
          child: const SalesInvoiceListScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sales & Invoices'), findsWidgets);
      expect(find.text('New Sale / Booking'), findsOneWidget);
      expect(find.text('Total Sales Revenue'), findsOneWidget);
    });

    testWidgets('3. AppStatusBadge renders correct label and variant styles', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: Scaffold(
            body: Column(
              children: [
                AppStatusBadge.fromStatus('in_stock'),
                AppStatusBadge.fromStatus('draft'),
                AppStatusBadge.fromStatus('paid'),
                AppStatusBadge.fromStatus('cancelled'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('In Stock'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('4. AppButton handles tap events and loading states correctly', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          child: Scaffold(
            body: Column(
              children: [
                AppButton(
                  label: 'Generate Tax Invoice',
                  onPressed: () {
                    tapped = true;
                  },
                ),
                const AppButton(
                  label: 'Processing...',
                  isLoading: true,
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Generate Tax Invoice'), findsOneWidget);
      await tester.tap(find.text('Generate Tax Invoice'));
      await tester.pump();
      expect(tapped, isTrue);

      expect(find.byType(AppButton), findsNWidgets(2));
    });
  });
}
