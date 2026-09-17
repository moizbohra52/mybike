import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/common/common.dart';

void main() {
  group('Common UI Design System Tests', () {
    testWidgets('AppButton renders label and triggers callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Submit Booking',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Submit Booking'), findsOneWidget);
      await tester.tap(find.text('Submit Booking'));
      expect(tapped, isTrue);
    });

    testWidgets('AppButton displays loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Saving...',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppStatusBadge displays correct label and status styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppStatusBadge.fromStatus('in_stock'),
                AppStatusBadge.fromStatus('reserved'),
                AppStatusBadge.fromStatus('sold'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('In Stock'), findsOneWidget);
      expect(find.text('Reserved'), findsOneWidget);
      expect(find.text('Sold'), findsOneWidget);
    });

    testWidgets('AppCurrencyText renders Indian Rupee formatted value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCurrencyText(
              amount: 150000,
              decimalDigits: 0,
            ),
          ),
        ),
      );

      expect(find.text('₹ 1,50,000'), findsOneWidget);
    });

    testWidgets('AppStatCard renders title, value and trend', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppStatCard(
              title: 'Monthly Bookings',
              value: '38 Units',
              icon: Icons.two_wheeler_rounded,
              changePercentage: '+12%',
            ),
          ),
        ),
      );

      expect(find.text('Monthly Bookings'), findsOneWidget);
      expect(find.text('38 Units'), findsOneWidget);
      expect(find.text('+12%'), findsOneWidget);
    });

    testWidgets('AppEmptyState renders title and fires action callback', (tester) async {
      bool actionFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'No Bikes Found',
              description: 'Try adjusting your search criteria',
              actionLabel: 'Add Bike',
              onActionPressed: () => actionFired = true,
            ),
          ),
        ),
      );

      expect(find.text('No Bikes Found'), findsOneWidget);
      expect(find.text('Try adjusting your search criteria'), findsOneWidget);
      expect(find.text('Add Bike'), findsOneWidget);

      await tester.tap(find.text('Add Bike'));
      expect(actionFired, isTrue);
    });

    testWidgets('AppSearchField allows typing and clearing', (tester) async {
      String query = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchField(
              hint: 'Search vehicles...',
              onChanged: (q) => query = q,
              debounceDuration: const Duration(milliseconds: 50),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Honda');
      await tester.pump(const Duration(milliseconds: 100));
      expect(query, 'Honda');

      // Clear button should be visible
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump(const Duration(milliseconds: 100));
      expect(query, '');
    });
  });
}
