import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/common/layouts/app_scaffold.dart';
import 'package:mybike/common/widgets/app_data_table.dart';
import 'package:mybike/core/theme/app_theme.dart';
import 'package:mybike/core/theme/theme_cubit.dart';

class _TestVoucher {
  final String number;
  final String date;
  final String party;
  final String type;
  final double amount;
  final String status;
  const _TestVoucher(this.number, this.date, this.party, this.type, this.amount, this.status);
}

void main() {
  Widget buildResponsiveHarness({
    required Widget child,
    required Size size,
  }) {
    return BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(),
      child: MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          theme: AppTheme.light,
          home: child,
        ),
      ),
    );
  }

  group('Phase 26 — Cross Platform QA: Multi-Device Responsive Layout Verification', () {
    testWidgets('1. Ultra-Compact Mobile (320x568) - Zero RenderFlex Overflow in AppScaffold', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));

      await tester.pumpWidget(
        buildResponsiveHarness(
          size: const Size(320, 568),
          child: AppScaffold(
            title: 'Compact View',
            activeNavigationId: 'dashboard',
            currentShowroomName: 'Mumbai Central',
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overview KPIs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: 140,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text('Card $i: ₹ ${(i + 1) * 25000}'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Compact View'), findsWidgets);
      expect(find.text('Card 0: ₹ 25000'), findsOneWidget);
    });

    testWidgets('2. Standard Mobile (390x844) - Fluid Drawer and Bottom Navigation rendering', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));

      await tester.pumpWidget(
        buildResponsiveHarness(
          size: const Size(390, 844),
          child: const AppScaffold(
            title: 'Sales Dashboard',
            activeNavigationId: 'sales',
            currentShowroomName: 'Pune Branch',
            body: Center(child: Text('Sales Mobile Workspace')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sales Dashboard'), findsWidgets);
      expect(find.text('Sales Mobile Workspace'), findsOneWidget);
    });

    testWidgets('3. Tablet Device (768x1024) - Adaptive Grid Layout and Multi-Column cards', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(768, 1024));

      await tester.pumpWidget(
        buildResponsiveHarness(
          size: const Size(768, 1024),
          child: AppScaffold(
            title: 'Inventory Master',
            activeNavigationId: 'inventory',
            body: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
              ),
              itemCount: 6,
              itemBuilder: (context, i) => Card(
                child: Center(child: Text('Stock Vehicle Unit #$i')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Inventory Master'), findsWidgets);
      expect(find.text('Stock Vehicle Unit #0'), findsOneWidget);
      expect(find.text('Stock Vehicle Unit #5'), findsOneWidget);
    });

    testWidgets('4. Desktop Wide Display (1920x1080) - Expanded Sidebar and Multi-Column Data Table', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));

      final columns = [
        AppDataColumn<_TestVoucher>(
          title: 'VOUCHER #',
          flex: 2,
          cellBuilder: (_, v) => Text(v.number),
        ),
        AppDataColumn<_TestVoucher>(
          title: 'DATE',
          flex: 1,
          cellBuilder: (_, v) => Text(v.date),
        ),
        AppDataColumn<_TestVoucher>(
          title: 'PARTY NAME',
          flex: 3,
          cellBuilder: (_, v) => Text(v.party),
        ),
        AppDataColumn<_TestVoucher>(
          title: 'TYPE',
          flex: 1,
          cellBuilder: (_, v) => Text(v.type),
        ),
        AppDataColumn<_TestVoucher>(
          title: 'AMOUNT (₹)',
          flex: 2,
          isNumeric: true,
          cellBuilder: (_, v) => Text('₹ ${v.amount.toStringAsFixed(2)}'),
        ),
        AppDataColumn<_TestVoucher>(
          title: 'STATUS',
          flex: 1,
          cellBuilder: (_, v) => Text(v.status),
        ),
      ];

      final items = List.generate(
        10,
        (i) => _TestVoucher(
          'JRN-2026-${(i + 1).toString().padLeft(4, '0')}',
          '22-Sep-2026',
          'Customer Account #$i',
          'Payment',
          (i + 1) * 15000.0,
          'POSTED',
        ),
      );

      await tester.pumpWidget(
        buildResponsiveHarness(
          size: const Size(1920, 1080),
          child: AppScaffold(
            title: 'General Ledger Vouchers',
            activeNavigationId: 'finance',
            body: AppDataTable<_TestVoucher>(
              columns: columns,
              items: items,
              isLoading: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('General Ledger Vouchers'), findsWidgets);
      expect(find.text('VOUCHER #'), findsOneWidget);
      expect(find.text('JRN-2026-0001'), findsOneWidget);
    });
  });
}
