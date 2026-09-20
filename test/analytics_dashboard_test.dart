import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/accounting_management_service.dart';
import 'package:mybike/core/services/analytics_dashboard_service.dart';
import 'package:mybike/core/services/finance_management_service.dart';
import 'package:mybike/core/services/sales_management_service.dart';
import 'package:mybike/features/dashboard/domain/entities/chart_data_point.dart';
import 'package:mybike/features/dashboard/domain/entities/finance_dashboard_data.dart';
import 'package:mybike/features/dashboard/domain/entities/inventory_dashboard_data.dart';
import 'package:mybike/features/dashboard/domain/entities/profit_dashboard_data.dart';
import 'package:mybike/features/dashboard/domain/entities/purchase_dashboard_data.dart';
import 'package:mybike/features/dashboard/domain/entities/sales_dashboard_data.dart';
import 'package:mybike/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mybike/features/dashboard/presentation/cubit/dashboard_state.dart';

void main() {
  setUp(() {
    SalesManagementService.instance.resetDevData();
    FinanceManagementService.instance.resetDevData();
    AccountingManagementService.instance.resetDevData();
  });

  group('Phase 15 — Analytics & Executive Dashboard Domain Entities', () {
    test('ChartDataPoint holds values, percentages, and labels accurately', () {
      const dp = ChartDataPoint(
        label: 'Honda CB350 H\'ness',
        value: 1250000.0,
        secondaryValue: 8,
        percentage: 45.2,
        displayValue: '₹12.5L',
      );

      expect(dp.label, equals('Honda CB350 H\'ness'));
      expect(dp.value, equals(1250000.0));
      expect(dp.secondaryValue, equals(8));
      expect(dp.percentage, equals(45.2));
      expect(dp.displayValue, equals('₹12.5L'));
    });

    test('SalesDashboardData entity properties', () {
      const salesData = SalesDashboardData(
        totalRevenue: 2850000.0,
        deliveredBikesCount: 14,
        pendingBookingsCount: 4,
        averageTicketSize: 198000.0,
        targetAchievementPercent: 92.5,
        monthlyRevenueTrend: [
          ChartDataPoint(label: 'Jan', value: 1800000.0),
          ChartDataPoint(label: 'Feb', value: 2850000.0),
        ],
        powertrainShare: [
          ChartDataPoint(label: 'Petrol (ICE)', value: 10, percentage: 71.4),
          ChartDataPoint(label: 'Electric (EV)', value: 4, percentage: 28.6),
        ],
        topModels: [
          ChartDataPoint(label: 'Honda CB350 DLX', value: 950000.0, displayValue: '5 units'),
        ],
        recentDeliveries: [
          {'customer': 'Amit Patel', 'model': 'Honda CB350', 'amount': 225000.0},
        ],
      );

      expect(salesData.totalRevenue, equals(2850000.0));
      expect(salesData.deliveredBikesCount, equals(14));
      expect(salesData.pendingBookingsCount, equals(4));
      expect(salesData.averageTicketSize, equals(198000.0));
      expect(salesData.targetAchievementPercent, equals(92.5));
      expect(salesData.monthlyRevenueTrend.length, equals(2));
      expect(salesData.powertrainShare.length, equals(2));
      expect(salesData.topModels.first.label, equals('Honda CB350 DLX'));
    });

    test('PurchaseDashboardData entity properties', () {
      const purchaseData = PurchaseDashboardData(
        totalProcurementSpend: 4200000.0,
        inwardUnitsCount: 24,
        pendingOrdersCount: 2,
        supplierPayablesTotal: 1450000.0,
        oemSpendDistribution: [
          ChartDataPoint(label: 'Honda Motorcycle', value: 2450000.0, percentage: 58.3),
          ChartDataPoint(label: 'Ather Energy', value: 1250000.0, percentage: 29.8),
        ],
        categorySpendBreakdown: [
          ChartDataPoint(label: 'Motorcycles (ICE)', value: 2500000.0),
        ],
        monthlyPurchaseTrend: [
          ChartDataPoint(label: 'Jan', value: 3800000.0),
        ],
        recentConsignments: [
          {'consignNo': 'CNS-001', 'supplier': 'Honda', 'units': 12},
        ],
      );

      expect(purchaseData.totalProcurementSpend, equals(4200000.0));
      expect(purchaseData.inwardUnitsCount, equals(24));
      expect(purchaseData.pendingOrdersCount, equals(2));
      expect(purchaseData.supplierPayablesTotal, equals(1450000.0));
      expect(purchaseData.oemSpendDistribution.length, equals(2));
    });

    test('InventoryDashboardData entity properties', () {
      const inventoryData = InventoryDashboardData(
        totalUnitsOnHand: 38,
        totalStockValuationInr: 5510000.0,
        averageHoldingDays: 28.4,
        agingStockCount: 3,
        categoryDistribution: [
          ChartDataPoint(label: 'Motorcycles', value: 18),
        ],
        showroomStockBalance: [
          ChartDataPoint(label: 'Mumbai Flagship', value: 18),
        ],
        stockStatusSplit: [
          ChartDataPoint(label: 'In Stock', value: 24),
        ],
        agingAlerts: [
          {'vin': 'VIN123', 'model': 'Honda CB350', 'days': 74},
        ],
      );

      expect(inventoryData.totalUnitsOnHand, equals(38));
      expect(inventoryData.totalStockValuationInr, equals(5510000.0));
      expect(inventoryData.averageHoldingDays, equals(28.4));
      expect(inventoryData.agingStockCount, equals(3));
      expect(inventoryData.agingAlerts.length, equals(1));
    });

    test('FinanceDashboardData entity properties', () {
      const financeData = FinanceDashboardData(
        totalLiquidFunds: 4850000.0,
        cashOnHand: 850000.0,
        bankBalances: 4000000.0,
        totalReceivables: 650000.0,
        totalPayables: 1450000.0,
        netWorkingCapital: 4050000.0,
        cashVsBankSplit: [
          ChartDataPoint(label: 'Cash in Hand', value: 850000.0),
          ChartDataPoint(label: 'Bank Accounts', value: 4000000.0),
        ],
        receivablesAging: [
          ChartDataPoint(label: '0-30 Days', value: 450000.0),
        ],
        monthlyCashflowTrend: [
          ChartDataPoint(label: 'Jan', value: 2500000.0, secondaryValue: 2100000.0),
        ],
        paymentModeMix: [
          ChartDataPoint(label: 'Bank Transfer', value: 65.0),
          ChartDataPoint(label: 'UPI', value: 20.0),
        ],
        recentVouchers: [
          {'voucher': 'PMT-001', 'amount': 150000.0},
        ],
      );

      expect(financeData.totalLiquidFunds, equals(4850000.0));
      expect(financeData.cashOnHand, equals(850000.0));
      expect(financeData.bankBalances, equals(4000000.0));
      expect(financeData.totalReceivables, equals(650000.0));
      expect(financeData.totalPayables, equals(1450000.0));
      expect(financeData.netWorkingCapital, equals(4050000.0));
      expect(financeData.cashVsBankSplit.length, equals(2));
    });

    test('ProfitDashboardData entity properties', () {
      const profitData = ProfitDashboardData(
        grossRevenue: 3450000.0,
        costOfGoodsSold: 2680000.0,
        grossProfit: 770000.0,
        grossMarginPercent: 22.3,
        operatingExpenses: 340000.0,
        ebitda: 430000.0,
        ebitdaMarginPercent: 12.5,
        revenueVsCogsTrend: [
          ChartDataPoint(label: 'Jan', value: 2800000.0, secondaryValue: 2180000.0),
        ],
        profitContributionBySegment: [
          ChartDataPoint(label: 'Vehicle Sales', value: 520000.0),
          ChartDataPoint(label: 'Accessories & Services', value: 250000.0),
        ],
        showroomProfitabilityRanking: [
          ChartDataPoint(label: 'Mumbai Flagship', value: 245000.0),
        ],
        marginBreakdownByModel: [
          {'model': 'Honda CB350 H\'ness', 'marginPercent': 21.4},
        ],
      );

      expect(profitData.grossRevenue, equals(3450000.0));
      expect(profitData.costOfGoodsSold, equals(2680000.0));
      expect(profitData.grossProfit, equals(770000.0));
      expect(profitData.grossMarginPercent, equals(22.3));
      expect(profitData.operatingExpenses, equals(340000.0));
      expect(profitData.ebitda, equals(430000.0));
      expect(profitData.ebitdaMarginPercent, equals(12.5));
    });
  });

  group('Phase 15 — AnalyticsDashboardService Computation Engine', () {
    late AnalyticsDashboardService service;

    setUp(() {
      service = AnalyticsDashboardService();
    });

    test('getSalesDashboard computes metrics for all showrooms and period', () async {
      final dataMonth = await service.getSalesDashboard(period: 'month');
      expect(dataMonth.totalRevenue, greaterThan(0));
      expect(dataMonth.monthlyRevenueTrend.isNotEmpty, isTrue);
      expect(dataMonth.powertrainShare.isNotEmpty, isTrue);
      expect(dataMonth.topModels.isNotEmpty, isTrue);
      expect(dataMonth.recentDeliveries.isNotEmpty, isTrue);

      final dataQuarter = await service.getSalesDashboard(period: 'quarter');
      expect(dataQuarter.totalRevenue, greaterThan(dataMonth.totalRevenue));

      final dataYear = await service.getSalesDashboard(period: 'year');
      expect(dataYear.totalRevenue, greaterThan(dataQuarter.totalRevenue));
    });

    test('getSalesDashboard filters by individual showroom', () async {
      final allData = await service.getSalesDashboard();
      final showroomData = await service.getSalesDashboard(showroomId: 'showroom-mumbai-main');

      expect(showroomData.totalRevenue, lessThan(allData.totalRevenue));
      expect(showroomData.deliveredBikesCount, lessThanOrEqualTo(allData.deliveredBikesCount));
    });

    test('getPurchaseDashboard computes procurement metrics and OEM split', () async {
      final purchaseAll = await service.getPurchaseDashboard(period: 'month');
      expect(purchaseAll.totalProcurementSpend, greaterThan(0));
      expect(purchaseAll.inwardUnitsCount, greaterThan(0));
      expect(purchaseAll.oemSpendDistribution.isNotEmpty, isTrue);
      expect(purchaseAll.categorySpendBreakdown.isNotEmpty, isTrue);
      expect(purchaseAll.recentConsignments.isNotEmpty, isTrue);

      // Verify filtered showroom purchase
      final purchaseShowroom = await service.getPurchaseDashboard(showroomId: 'showroom-pune-west');
      expect(purchaseShowroom.totalProcurementSpend, lessThan(purchaseAll.totalProcurementSpend));
    });

    test('getInventoryDashboard computes stock health, categories, and aging alerts', () async {
      final invData = await service.getInventoryDashboard();
      expect(invData.totalUnitsOnHand, greaterThan(0));
      expect(invData.totalStockValuationInr, greaterThan(0));
      expect(invData.categoryDistribution.isNotEmpty, isTrue);
      expect(invData.showroomStockBalance.isNotEmpty, isTrue);
      expect(invData.stockStatusSplit.isNotEmpty, isTrue);
      expect(invData.agingAlerts.isNotEmpty, isTrue);
    });

    test('getFinanceDashboard computes liquidity, working capital, and payment mix', () async {
      final finData = await service.getFinanceDashboard();
      expect(finData.totalLiquidFunds, greaterThan(0));
      expect(finData.totalReceivables, greaterThanOrEqualTo(0));
      expect(finData.totalPayables, greaterThan(0));
      expect(finData.netWorkingCapital, equals(finData.totalLiquidFunds + finData.totalReceivables - finData.totalPayables));
      expect(finData.cashOnHand, greaterThan(0));
      expect(finData.bankBalances, greaterThan(0));
      expect(finData.monthlyCashflowTrend.isNotEmpty, isTrue);
      expect(finData.paymentModeMix.isNotEmpty, isTrue);
    });

    test('getProfitDashboard computes revenue, COGS, EBITDA, and showroom ranking', () async {
      final profitData = await service.getProfitDashboard(period: 'month');
      expect(profitData.grossRevenue, greaterThan(profitData.costOfGoodsSold));
      expect(profitData.grossProfit, equals(profitData.grossRevenue - profitData.costOfGoodsSold));
      expect(profitData.grossMarginPercent, greaterThan(0));
      expect(profitData.ebitda, equals(profitData.grossProfit - profitData.operatingExpenses));
      expect(profitData.profitContributionBySegment.isNotEmpty, isTrue);
      expect(profitData.showroomProfitabilityRanking.isNotEmpty, isTrue);
      expect(profitData.revenueVsCogsTrend.isNotEmpty, isTrue);
    });
  });

  group('Phase 15 — DashboardCubit State Management', () {
    late DashboardCubit cubit;

    setUp(() {
      cubit = DashboardCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has activeTab 0, period month, null showroom, and isInitial status', () {
      expect(cubit.state.status, equals(DashboardStatus.initial));
      expect(cubit.state.activeTab, equals(0));
      expect(cubit.state.selectedPeriod, equals('month'));
      expect(cubit.state.selectedShowroomId, isNull);
    });

    test('loadDashboard loads all 5 datasets successfully', () async {
      await cubit.loadDashboard();

      expect(cubit.state.status, equals(DashboardStatus.success));
      expect(cubit.state.salesData, isNotNull);
      expect(cubit.state.purchaseData, isNotNull);
      expect(cubit.state.inventoryData, isNotNull);
      expect(cubit.state.financeData, isNotNull);
      expect(cubit.state.profitData, isNotNull);
      expect(cubit.state.errorMessage, isNull);
    });

    test('setTab changes activeTab without reloading data', () async {
      await cubit.loadDashboard();
      expect(cubit.state.activeTab, equals(0));

      cubit.setTab(1); // Sales
      expect(cubit.state.activeTab, equals(1));

      cubit.setTab(2); // Purchase
      expect(cubit.state.activeTab, equals(2));

      cubit.setTab(3); // Inventory
      expect(cubit.state.activeTab, equals(3));

      cubit.setTab(4); // Finance
      expect(cubit.state.activeTab, equals(4));

      cubit.setTab(5); // Profit
      expect(cubit.state.activeTab, equals(5));
    });

    test('filterByPeriod updates period filter and triggers data reload', () async {
      await cubit.loadDashboard();
      expect(cubit.state.selectedPeriod, equals('month'));

      await cubit.filterByPeriod('quarter');
      expect(cubit.state.selectedPeriod, equals('quarter'));
      expect(cubit.state.status, equals(DashboardStatus.success));

      await cubit.filterByPeriod('year');
      expect(cubit.state.selectedPeriod, equals('year'));
      expect(cubit.state.status, equals(DashboardStatus.success));
    });

    test('filterByShowroom updates showroom filter and reloads filtered metrics', () async {
      await cubit.loadDashboard();
      expect(cubit.state.selectedShowroomId, isNull);

      await cubit.filterByShowroom('showroom-mumbai-main');
      expect(cubit.state.selectedShowroomId, equals('showroom-mumbai-main'));
      expect(cubit.state.status, equals(DashboardStatus.success));
      expect(cubit.state.salesData!.totalRevenue, lessThan(3500000.0));

      // Reset back to All Showrooms
      await cubit.filterByShowroom(null);
      expect(cubit.state.selectedShowroomId, isNull);
      expect(cubit.state.status, equals(DashboardStatus.success));
    });
  });
}
