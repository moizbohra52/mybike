import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/accounting_management_service.dart';
import 'package:mybike/core/services/finance_management_service.dart';
import 'package:mybike/core/services/reporting_management_service.dart';
import 'package:mybike/core/services/sales_management_service.dart';
import 'package:mybike/features/reports/domain/entities/report_filter_criteria.dart';
import 'package:mybike/features/reports/presentation/cubit/report_viewer_cubit.dart';
import 'package:mybike/features/reports/presentation/cubit/report_viewer_state.dart';
import 'package:mybike/features/reports/presentation/cubit/reports_hub_cubit.dart';
import 'package:mybike/features/reports/presentation/cubit/reports_hub_state.dart';

void main() {
  setUp(() {
    SalesManagementService.instance.resetDevData();
    FinanceManagementService.instance.resetDevData();
    AccountingManagementService.instance.resetDevData();
  });

  group('Phase 16 — ReportingManagementService (All 14 Statutory & Operational Reports)', () {
    late ReportingManagementService service;
    late ReportFilterCriteria monthCriteria;
    late ReportFilterCriteria yearCriteria;

    setUp(() {
      service = ReportingManagementService.instance;
      monthCriteria = ReportFilterCriteria.currentMonth();
      yearCriteria = ReportFilterCriteria.currentFinancialYear();
    });

    test('1. generateSalesReport generates tax invoices register with correct GST arithmetic', () async {
      final report = await service.generateSalesReport(monthCriteria);
      expect(report.rows.isNotEmpty, isTrue);
      expect(report.totalInvoicesCount, equals(report.rows.length));
      expect(report.totalTaxable, greaterThan(0));
      expect(report.totalGst, greaterThan(0));
      expect(report.grandTotal, greaterThan(report.totalTaxable));

      // Filter by showroom
      final mumbaiCriteria = monthCriteria.copyWith(
        showroomId: 'showroom-mumbai-main',
        showroomName: 'Mumbai Flagship',
      );
      final mumbaiReport = await service.generateSalesReport(mumbaiCriteria);
      expect(mumbaiReport.showroomName, equals('Mumbai Flagship'));
      expect(mumbaiReport.grandTotal, lessThanOrEqualTo(report.grandTotal));
    });

    test('2. generatePurchaseReport generates OEM consignment spend & unit counts', () async {
      final report = await service.generatePurchaseReport(monthCriteria);
      expect(report.rows.isNotEmpty, isTrue);
      expect(report.totalSpend, greaterThan(0));
      expect(report.totalUnits, greaterThan(0));

      // Showroom specific filter
      final puneCriteria = monthCriteria.copyWith(
        showroomId: 'showroom-pune-west',
        showroomName: 'Pune West Hub',
      );
      final puneReport = await service.generatePurchaseReport(puneCriteria);
      expect(puneReport.totalSpend, lessThan(report.totalSpend));
    });

    test('3. generateStockReport generates inventory valuation and aging stock >60d', () async {
      final report = await service.generateStockReport(monthCriteria);
      expect(report.rows.isNotEmpty, isTrue);
      expect(report.totalUnits, greaterThan(0));
      expect(report.totalStockValuation, greaterThan(0));
      expect(report.totalAgingUnits, greaterThanOrEqualTo(0));
    });

    test('4. generateAccountLedgerReport computes running balance for cash/bank account', () async {
      final report = await service.generateAccountLedgerReport('acc-1010', monthCriteria);
      expect(report.accountCode, isNotEmpty);
      expect(report.accountName, isNotEmpty);
      expect(report.entries.isNotEmpty, isTrue);
      expect(report.closingBalance, equals(report.entries.last.runningBalance));
    });

    test('5. generateCashBook tracks daily cash receipts, payments, and opening/closing cash', () async {
      final report = await service.generateCashBook(monthCriteria);
      expect(report.openingBalance, greaterThan(0));
      expect(report.entries.isNotEmpty, isTrue);
      expect(report.totalDebitInflows, greaterThanOrEqualTo(0));
      expect(report.totalCreditOutflows, greaterThan(0));
      expect(report.closingBalance, equals(report.openingBalance + report.totalDebitInflows - report.totalCreditOutflows));
    });

    test('6. generateBankBook tracks bank deposits, NEFT/RTGS payments, and bank balance', () async {
      final report = await service.generateBankBook(monthCriteria);
      expect(report.openingBalance, greaterThan(0));
      expect(report.bankAccountName, contains('HDFC'));
      expect(report.entries.isNotEmpty, isTrue);
      expect(report.closingBalance, equals(report.openingBalance + report.totalDebitDeposits - report.totalCreditWithdrawals));
    });

    test('7. generateTrialBalance enforces double-entry reconciliation (totalDebit == totalCredit)', () async {
      final report = await service.generateTrialBalance(yearCriteria);
      expect(report.items.isNotEmpty, isTrue);
      expect(report.totalDebit, greaterThan(0));
      expect(report.totalCredit, greaterThan(0));
      expect(report.totalDebit, closeTo(report.totalCredit, 0.01));
      expect(report.isBalanced, isTrue);
    });

    test('8. generateProfitAndLoss calculates Gross Margin, EBITDA, and Net Profit before tax', () async {
      final report = await service.generateProfitAndLoss(monthCriteria);
      expect(report.grossSalesRevenue, greaterThan(0));
      expect(report.netSalesRevenue, equals(report.grossSalesRevenue - report.salesReturnsAndDiscounts));
      expect(report.costOfGoodsSold, greaterThan(0));
      expect(report.grossProfit, equals(report.netSalesRevenue - report.costOfGoodsSold));
      expect(report.grossMarginPercent, greaterThan(0));
      expect(report.operatingExpenses.isNotEmpty, isTrue);
      expect(report.operatingProfitEbitda, equals(report.grossProfit - report.totalOperatingExpenses));
      expect(report.otherIncomes.isNotEmpty, isTrue);
      expect(report.netProfitBeforeTax, equals(report.operatingProfitEbitda + report.totalOtherIncomes - report.depreciationAndFinanceCost));
    });

    test('9. generateBalanceSheet ensures perfect asset vs liability/equity equilibrium', () async {
      final report = await service.generateBalanceSheet(yearCriteria);
      expect(report.nonCurrentAssets.isNotEmpty, isTrue);
      expect(report.currentAssets.isNotEmpty, isTrue);
      expect(report.totalAssets, equals(report.totalNonCurrentAssets + report.totalCurrentAssets));
      expect(report.totalLiabilitiesAndEquity, closeTo(report.totalAssets, 1.0));
      expect(report.isBalanced, isTrue);
    });

    test('10. generateReceivablesAging sorts debtors into 0-30, 31-60, 61-90, and >90 buckets', () async {
      final report = await service.generateReceivablesAging(monthCriteria);
      expect(report.customers.isNotEmpty, isTrue);
      expect(report.grandTotal, greaterThan(0));
      expect(report.grandTotal, equals(report.total0to30 + report.total31to60 + report.total61to90 + report.totalAbove90));
    });

    test('11. generatePayablesAging sorts OEM payables into 0-30, 31-60, 61-90, and >90 buckets', () async {
      final report = await service.generatePayablesAging(monthCriteria);
      expect(report.suppliers.isNotEmpty, isTrue);
      expect(report.grandTotal, greaterThan(0));
      expect(report.grandTotal, equals(report.total0to30 + report.total31to60 + report.total61to90 + report.totalAbove90));
    });

    test('12. generateGstReport compiles GSTR-1 and GSTR-3B outward tax and eligible ITC', () async {
      final report = await service.generateGstReport(monthCriteria);
      expect(report['showroomName'], isNotNull);
      expect(report['totalOutwardTaxable'], greaterThan(0));
      expect(report['totalCgst'], greaterThan(0));
      expect(report['totalSgst'], greaterThan(0));
      expect(report['itcEligible'], greaterThan(0));
      expect(report['netTaxPayable'], greaterThanOrEqualTo(0));
    });

    test('13. generateExpenseReport groups operational costs by cost centers', () async {
      final report = await service.generateExpenseReport(monthCriteria);
      expect(report.categories.isNotEmpty, isTrue);
      expect(report.grandTotalExpense, greaterThan(0));
      expect(report.categories.any((c) => c.categoryName.contains('Rent')), isTrue);
    });

    test('14. generateIncomeReport compiles vehicle margins, subventions, and commissions', () async {
      final report = await service.generateIncomeReport(monthCriteria);
      expect(report.incomeCategories.isNotEmpty, isTrue);
      expect(report.grandTotalIncome, greaterThan(0));
      expect(report.incomeCategories.any((c) => c.categoryName.contains('Vehicle Retail Margin')), isTrue);
    });
  });

  group('Phase 16 — ReportsHubCubit', () {
    late ReportsHubCubit cubit;

    setUp(() {
      cubit = ReportsHubCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initializes with all 14 reports in catalog', () {
      expect(cubit.state.status, equals(ReportsHubStatus.initial));
      cubit.init();
      expect(cubit.state.status, equals(ReportsHubStatus.success));
      expect(cubit.state.reports.length, equals(14));
      expect(cubit.state.filteredReports.length, equals(14));
    });

    test('filters reports by category', () {
      cubit.init();

      cubit.filterByCategory('financial');
      expect(cubit.state.filteredReports.length, equals(3));
      expect(cubit.state.filteredReports.every((r) => r.category == 'financial'), isTrue);

      cubit.filterByCategory('books');
      expect(cubit.state.filteredReports.length, equals(3));
      expect(cubit.state.filteredReports.every((r) => r.category == 'books'), isTrue);

      cubit.filterByCategory('registers');
      expect(cubit.state.filteredReports.length, equals(3));
      expect(cubit.state.filteredReports.every((r) => r.category == 'registers'), isTrue);

      cubit.filterByCategory('working_capital');
      expect(cubit.state.filteredReports.length, equals(5));
      expect(cubit.state.filteredReports.every((r) => r.category == 'working_capital'), isTrue);

      cubit.filterByCategory('all');
      expect(cubit.state.filteredReports.length, equals(14));
    });

    test('searches reports by query', () {
      cubit.init();
      cubit.searchReports('cash');
      expect(cubit.state.filteredReports.length, greaterThanOrEqualTo(1));
      expect(cubit.state.filteredReports.first.title.toLowerCase(), contains('cash'));

      cubit.searchReports('');
      expect(cubit.state.filteredReports.length, equals(14));
    });
  });

  group('Phase 16 — ReportViewerCubit', () {
    test('loads sales register report with columns and total row', () async {
      final cubit = ReportViewerCubit(reportType: 'sales_register');
      await cubit.loadReport();

      expect(cubit.state.status, equals(ReportViewerStatus.success));
      expect(cubit.state.columns.length, equals(9));
      expect(cubit.state.rows.isNotEmpty, isTrue);
      expect(cubit.state.rows.last.isTotalRow, isTrue);
      expect(cubit.state.summaryCards.length, equals(4));

      cubit.close();
    });

    test('loads trial balance report with balanced verified totals', () async {
      final cubit = ReportViewerCubit(reportType: 'trial_balance');
      await cubit.loadReport();

      expect(cubit.state.status, equals(ReportViewerStatus.success));
      expect(cubit.state.title, contains('Trial Balance'));
      expect(cubit.state.rows.last.isTotalRow, isTrue);
      expect(cubit.state.summaryCards.any((c) => c['title'] == 'Ledger Status'), isTrue);

      cubit.close();
    });

    test('loads balance sheet with asset and liability sections', () async {
      final cubit = ReportViewerCubit(reportType: 'balance_sheet');
      await cubit.loadReport();

      expect(cubit.state.status, equals(ReportViewerStatus.success));
      expect(cubit.state.title, contains('Balance Sheet'));
      expect(cubit.state.rows.any((r) => r.cells.first.text.contains('EQUITY AND LIABILITIES')), isTrue);
      expect(cubit.state.rows.any((r) => r.cells.first.text.contains('ASSETS')), isTrue);

      cubit.close();
    });

    test('updates showroom filter and reloads report criteria', () async {
      final cubit = ReportViewerCubit(reportType: 'sales_register');
      await cubit.loadReport();

      final newCriteria = cubit.state.criteria.copyWith(
        showroomId: 'showroom-mumbai-main',
        showroomName: 'Mumbai Flagship',
      );
      cubit.updateCriteria(newCriteria);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.criteria.showroomId, equals('showroom-mumbai-main'));
      expect(cubit.state.criteria.showroomName, equals('Mumbai Flagship'));

      cubit.close();
    });
  });
}
