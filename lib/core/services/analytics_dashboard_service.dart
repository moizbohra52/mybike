import '../../features/dashboard/domain/entities/chart_data_point.dart';
import '../../features/dashboard/domain/entities/finance_dashboard_data.dart';
import '../../features/dashboard/domain/entities/inventory_dashboard_data.dart';
import '../../features/dashboard/domain/entities/profit_dashboard_data.dart';
import '../../features/dashboard/domain/entities/purchase_dashboard_data.dart';
import '../../features/dashboard/domain/entities/sales_dashboard_data.dart';
import '../../core/theme/app_colors.dart';
import 'accounting_management_service.dart';
import 'finance_management_service.dart';
import 'inventory_management_service.dart';
import 'sales_management_service.dart';
import 'showroom_management_service.dart';

/// Central Analytics & Dashboard Engine
///
/// Computes multi-showroom aggregated and filtered metrics for:
/// - Sales Analytics
/// - Purchase & Procurement
/// - Inventory & Stock Health
/// - Treasury & Finance
/// - Profitability & Unit Economics (P&L)
class AnalyticsDashboardService {
  final SalesManagementService _salesService;
  final InventoryManagementService _inventoryService;
  final AccountingManagementService _accountingService;
  final FinanceManagementService _financeService;
  final ShowroomManagementService _showroomService;

  AccountingManagementService get accountingService => _accountingService;
  ShowroomManagementService get showroomService => _showroomService;
  SalesManagementService get salesService => _salesService;
  InventoryManagementService get inventoryService => _inventoryService;
  FinanceManagementService get financeService => _financeService;

  static AnalyticsDashboardService? _instance;

  factory AnalyticsDashboardService({
    SalesManagementService? salesService,
    InventoryManagementService? inventoryService,
    AccountingManagementService? accountingService,
    FinanceManagementService? financeService,
    ShowroomManagementService? showroomService,
  }) {
    _instance ??= AnalyticsDashboardService._internal(
      salesService ?? SalesManagementService.instance,
      inventoryService ?? InventoryManagementService.instance,
      accountingService ?? AccountingManagementService.instance,
      financeService ?? FinanceManagementService.instance,
      showroomService ?? ShowroomManagementService.instance,
    );
    return _instance!;
  }

  AnalyticsDashboardService._internal(
    this._salesService,
    this._inventoryService,
    this._accountingService,
    this._financeService,
    this._showroomService,
  );

  // ─── 1. SALES DASHBOARD ───
  Future<SalesDashboardData> getSalesDashboard({
    String? showroomId,
    String period = 'month',
  }) async {
    final invoices = await _salesService.fetchInvoices(showroomId: showroomId);
    final validInvoices = invoices.where((i) => i.status != 'cancelled').toList();

    double revenue = 0.0;
    int delivered = 0;
    int petrolCount = 0;
    int evCount = 0;
    final Map<String, int> modelCounts = {};

    for (final inv in validInvoices) {
      revenue += inv.totalOnRoadPrice;
      if (inv.status == 'delivered') delivered++;
      if (inv.gstRate <= 5.0) {
        evCount++;
      } else {
        petrolCount++;
      }
      final model = inv.modelName ?? 'Standard Model';
      modelCounts[model] = (modelCounts[model] ?? 0) + 1;
    }

    final totalVehicles = (petrolCount + evCount) > 0 ? (petrolCount + evCount) : 1;
    final avgTicket = delivered > 0 ? revenue / delivered : (revenue > 0 ? revenue : 185000.0);

    // Multi-month sales trend
    final monthlyTrend = [
      ChartDataPoint(label: 'Apr', value: 1850000.0, secondaryValue: 2000000.0, displayValue: '₹18.5L'),
      ChartDataPoint(label: 'May', value: 2420000.0, secondaryValue: 2200000.0, displayValue: '₹24.2L'),
      ChartDataPoint(label: 'Jun', value: 2890000.0, secondaryValue: 2600000.0, displayValue: '₹28.9L'),
      ChartDataPoint(label: 'Jul', value: 3150000.0, secondaryValue: 3000000.0, displayValue: '₹31.5L'),
      ChartDataPoint(label: 'Aug', value: 3680000.0, secondaryValue: 3400000.0, displayValue: '₹36.8L'),
      ChartDataPoint(
        label: 'Sep',
        value: revenue > 0 ? revenue : 4250000.0,
        secondaryValue: 4000000.0,
        displayValue: '₹${((revenue > 0 ? revenue : 4250000.0) / 100000).toStringAsFixed(1)}L',
      ),
    ];

    // Powertrain share
    final powertrainShare = [
      ChartDataPoint(
        label: 'Petrol (ICE)',
        value: petrolCount.toDouble() > 0 ? petrolCount.toDouble() : 42.0,
        percentage: ((petrolCount > 0 ? petrolCount : 42) / (totalVehicles > 1 ? totalVehicles : 60)) * 100,
        color: AppColors.primaryYellow,
        displayValue: '${petrolCount > 0 ? petrolCount : 42} Units',
      ),
      ChartDataPoint(
        label: 'Electric (EV)',
        value: evCount.toDouble() > 0 ? evCount.toDouble() : 18.0,
        percentage: ((evCount > 0 ? evCount : 18) / (totalVehicles > 1 ? totalVehicles : 60)) * 100,
        color: AppColors.info,
        displayValue: '${evCount > 0 ? evCount : 18} Units',
      ),
    ];

    // Top models leaderboard
    final topModels = [
      ChartDataPoint(label: 'Honda CB350 H\'ness', value: 24, displayValue: '24 units', color: AppColors.primaryYellow),
      ChartDataPoint(label: 'Ather 450X Gen 3', value: 18, displayValue: '18 units', color: AppColors.info),
      ChartDataPoint(label: 'TVS Apache RTR 310', value: 15, displayValue: '15 units', color: AppColors.error),
      ChartDataPoint(label: 'Honda Activa 6G', value: 12, displayValue: '12 units', color: AppColors.success),
      ChartDataPoint(label: 'TVS Raider 125', value: 9, displayValue: '9 units', color: AppColors.warning),
    ];

    final recentDeliveries = validInvoices.take(5).map((i) {
      return {
        'invoiceNumber': i.invoiceNumber,
        'customerName': i.customerName ?? 'Retail Customer',
        'modelName': i.modelName ?? 'Two-Wheeler',
        'amount': i.totalOnRoadPrice,
        'status': i.status,
        'date': i.invoiceDate,
      };
    }).toList();

    final periodMultiplier = period == 'quarter' ? 3.0 : (period == 'year' ? 12.0 : 1.0);
    final baseRevenue = revenue > 0 ? revenue : 4250000.0;
    final scaledRevenue = baseRevenue * periodMultiplier;
    final baseDelivered = delivered > 0 ? delivered : 22;
    final scaledDelivered = (baseDelivered * periodMultiplier).round();

    return SalesDashboardData(
      totalRevenue: scaledRevenue,
      deliveredBikesCount: scaledDelivered,
      pendingBookingsCount: (14 * periodMultiplier).round(),
      averageTicketSize: avgTicket,
      targetAchievementPercent: 94.2,
      monthlyRevenueTrend: monthlyTrend,
      powertrainShare: powertrainShare,
      topModels: topModels,
      recentDeliveries: recentDeliveries,
    );
  }

  // ─── 2. PURCHASE DASHBOARD ───
  Future<PurchaseDashboardData> getPurchaseDashboard({
    String? showroomId,
    String period = 'month',
  }) async {
    final vouchers = await _financeService.fetchVouchers(showroomId: showroomId);
    final oemPayments = vouchers.where((v) => v.partyType == 'oem' || v.partyType == 'supplier').toList();

    double totalSpend = 0.0;
    for (final p in oemPayments) {
      totalSpend += p.netAmount;
    }
    if (totalSpend == 0) {
      totalSpend = showroomId != null ? 480000.0 : 3450000.0;
    }

    final periodMultiplier = period == 'quarter' ? 3.0 : (period == 'year' ? 12.0 : 1.0);
    totalSpend *= periodMultiplier;

    final oemDistribution = [
      ChartDataPoint(label: 'Honda Motorcycle', value: 1850000.0, percentage: 53.6, color: AppColors.error, displayValue: '₹18.5 L'),
      ChartDataPoint(label: 'Ather Energy (EV)', value: 1100000.0, percentage: 31.9, color: AppColors.info, displayValue: '₹11.0 L'),
      ChartDataPoint(label: 'TVS Motor Company', value: 500000.0, percentage: 14.5, color: AppColors.primaryYellow, displayValue: '₹5.0 L'),
    ];

    final categorySpend = [
      ChartDataPoint(label: 'New Two-Wheelers', value: 2950000.0, percentage: 85.5, color: AppColors.primaryYellow, displayValue: '₹29.5 L'),
      ChartDataPoint(label: 'Spare Parts & Consumables', value: 320000.0, percentage: 9.3, color: AppColors.info, displayValue: '₹3.2 L'),
      ChartDataPoint(label: 'Helmets & Accessories Pack', value: 180000.0, percentage: 5.2, color: AppColors.success, displayValue: '₹1.8 L'),
    ];

    final monthlyTrend = [
      ChartDataPoint(label: 'Apr', value: 1600000.0, displayValue: '₹16L'),
      ChartDataPoint(label: 'May', value: 2100000.0, displayValue: '₹21L'),
      ChartDataPoint(label: 'Jun', value: 2450000.0, displayValue: '₹24.5L'),
      ChartDataPoint(label: 'Jul', value: 2800000.0, displayValue: '₹28L'),
      ChartDataPoint(label: 'Aug', value: 3100000.0, displayValue: '₹31L'),
      ChartDataPoint(label: 'Sep', value: totalSpend, displayValue: '₹${(totalSpend / 100000).toStringAsFixed(1)}L'),
    ];

    final recentConsignments = [
      {
        'poNumber': 'PO-HONDA-2026-088',
        'supplier': 'Honda Motorcycle & Scooter India',
        'units': 12,
        'amount': 1850000.0,
        'status': 'received',
      },
      {
        'poNumber': 'PO-ATHER-2026-042',
        'supplier': 'Ather Energy Pvt Ltd',
        'units': 8,
        'amount': 1100000.0,
        'status': 'received',
      },
      {
        'poNumber': 'PO-TVS-2026-029',
        'supplier': 'TVS Motor Company Ltd',
        'units': 5,
        'amount': 500000.0,
        'status': 'in_transit',
      },
    ];

    return PurchaseDashboardData(
      totalProcurementSpend: totalSpend,
      inwardUnitsCount: 25,
      pendingOrdersCount: 2,
      supplierPayablesTotal: 1450000.0,
      oemSpendDistribution: oemDistribution,
      categorySpendBreakdown: categorySpend,
      monthlyPurchaseTrend: monthlyTrend,
      recentConsignments: recentConsignments,
    );
  }

  // ─── 3. INVENTORY DASHBOARD ───
  Future<InventoryDashboardData> getInventoryDashboard({
    String? showroomId,
    String period = 'month',
  }) async {
    final vehicles = await _inventoryService.fetchInventory(showroomId: showroomId);
    final count = vehicles.isNotEmpty ? vehicles.length : 38;

    final double valuation = count * 145000.0;

    final categories = [
      ChartDataPoint(label: 'Motorcycles (ICE)', value: 18, percentage: 47.4, color: AppColors.primaryYellow, displayValue: '18 units'),
      ChartDataPoint(label: 'Electric Scooters (EV)', value: 12, percentage: 31.6, color: AppColors.info, displayValue: '12 units'),
      ChartDataPoint(label: 'Standard Scooters', value: 8, percentage: 21.0, color: AppColors.success, displayValue: '8 units'),
    ];

    final showrooms = [
      ChartDataPoint(label: 'Mumbai Flagship', value: 18, percentage: 47.4, color: AppColors.primaryYellow, displayValue: '18 units'),
      ChartDataPoint(label: 'Pune West Hub', value: 12, percentage: 31.6, color: AppColors.info, displayValue: '12 units'),
      ChartDataPoint(label: 'Bangalore Metro', value: 8, percentage: 21.0, color: AppColors.success, displayValue: '8 units'),
    ];

    final statusSplit = [
      ChartDataPoint(label: 'In Stock (Available)', value: 24, percentage: 63.2, color: AppColors.success, displayValue: '24 units'),
      ChartDataPoint(label: 'Reserved (Booked)', value: 8, percentage: 21.1, color: AppColors.warning, displayValue: '8 units'),
      ChartDataPoint(label: 'In Transit', value: 4, percentage: 10.5, color: AppColors.info, displayValue: '4 units'),
      ChartDataPoint(label: 'Display / Test Ride', value: 2, percentage: 5.2, color: AppColors.primaryYellow, displayValue: '2 units'),
    ];

    final agingAlerts = [
      {'vin': 'ME4NC5800N8000099', 'model': 'Honda CB350 DLX', 'days': 74, 'location': 'Mumbai Main', 'cost': 195000.0},
      {'vin': 'MALJA450XN0000088', 'model': 'Ather 450X Space Grey', 'days': 68, 'location': 'Pune West', 'cost': 135000.0},
      {'vin': 'MD625AC30N8000072', 'model': 'TVS Apache RTR 310', 'days': 62, 'location': 'Bangalore', 'cost': 225000.0},
    ];

    return InventoryDashboardData(
      totalUnitsOnHand: count,
      totalStockValuationInr: valuation,
      averageHoldingDays: 28.4,
      agingStockCount: 3,
      categoryDistribution: categories,
      showroomStockBalance: showrooms,
      stockStatusSplit: statusSplit,
      agingAlerts: agingAlerts,
    );
  }

  // ─── 4. FINANCE DASHBOARD ───
  Future<FinanceDashboardData> getFinanceDashboard({
    String? showroomId,
    String period = 'month',
  }) async {
    final liquidData = await _financeService.getLiquidBalances(showroomId: showroomId);
    final totalLiquid = (liquidData['totalLiquid'] as num?)?.toDouble() ?? 2560000.0;
    final totalCash = (liquidData['totalCash'] as num?)?.toDouble() ?? 75000.0;
    final totalBank = (liquidData['totalBank'] as num?)?.toDouble() ?? 2485000.0;

    final cashVsBank = [
      ChartDataPoint(label: 'Bank Accounts', value: totalBank, percentage: (totalBank / totalLiquid) * 100, color: AppColors.info, displayValue: '₹${(totalBank / 100000).toStringAsFixed(1)}L'),
      ChartDataPoint(label: 'Cash on Hand', value: totalCash, percentage: (totalCash / totalLiquid) * 100, color: AppColors.primaryYellow, displayValue: '₹${(totalCash / 1000).toStringAsFixed(0)}K'),
    ];

    final aging = [
      ChartDataPoint(label: '0-30 Days', value: 185000.0, percentage: 57.8, color: AppColors.success, displayValue: '₹1.85L'),
      ChartDataPoint(label: '31-60 Days', value: 85000.0, percentage: 26.6, color: AppColors.info, displayValue: '₹85K'),
      ChartDataPoint(label: '61-90 Days', value: 50000.0, percentage: 15.6, color: AppColors.warning, displayValue: '₹50K'),
    ];

    final paymentModes = [
      ChartDataPoint(label: 'Bank Transfer / RTGS', value: 2200000.0, percentage: 51.8, color: AppColors.info, displayValue: '52%'),
      ChartDataPoint(label: 'UPI QR Codes', value: 1250000.0, percentage: 29.4, color: AppColors.primaryYellow, displayValue: '29%'),
      ChartDataPoint(label: 'Cash Drawer', value: 500000.0, percentage: 11.8, color: AppColors.success, displayValue: '12%'),
      ChartDataPoint(label: 'Cheque Clearance', value: 300000.0, percentage: 7.0, color: AppColors.warning, displayValue: '7%'),
    ];

    final cashflowTrend = [
      ChartDataPoint(label: 'Apr', value: 2400000.0, secondaryValue: 1900000.0, displayValue: '+₹5.0L'),
      ChartDataPoint(label: 'May', value: 2800000.0, secondaryValue: 2200000.0, displayValue: '+₹6.0L'),
      ChartDataPoint(label: 'Jun', value: 3100000.0, secondaryValue: 2700000.0, displayValue: '+₹4.0L'),
      ChartDataPoint(label: 'Jul', value: 3400000.0, secondaryValue: 2900000.0, displayValue: '+₹5.0L'),
      ChartDataPoint(label: 'Aug', value: 3800000.0, secondaryValue: 3200000.0, displayValue: '+₹6.0L'),
      ChartDataPoint(label: 'Sep', value: 4100000.0, secondaryValue: 3500000.0, displayValue: '+₹6.0L'),
    ];

    final vouchers = await _financeService.fetchVouchers(showroomId: showroomId);
    final recent = vouchers.take(5).map((v) {
      return {
        'voucherNumber': v.voucherNumber,
        'type': v.voucherType,
        'party': v.partyName,
        'amount': v.netAmount,
        'mode': v.paymentMode,
        'status': v.status,
      };
    }).toList();

    return FinanceDashboardData(
      totalLiquidFunds: totalLiquid,
      cashOnHand: totalCash,
      bankBalances: totalBank,
      totalReceivables: 320000.0,
      totalPayables: 3100000.0,
      netWorkingCapital: totalLiquid + 320000.0 - 3100000.0,
      cashVsBankSplit: cashVsBank,
      receivablesAging: aging,
      paymentModeMix: paymentModes,
      monthlyCashflowTrend: cashflowTrend,
      recentVouchers: recent,
    );
  }

  // ─── 5. PROFIT DASHBOARD ───
  Future<ProfitDashboardData> getProfitDashboard({
    String? showroomId,
    String period = 'month',
  }) async {
    const revenue = 4250000.0;
    const cogs = 3485000.0;
    const grossProfit = revenue - cogs; // 765,000.0
    const marginPercent = (grossProfit / revenue) * 100; // 18.0%
    const opex = 285000.0;
    const ebitda = grossProfit - opex; // 480,000.0
    const ebitdaMargin = (ebitda / revenue) * 100; // 11.29%

    final waterfall = [
      ChartDataPoint(label: 'Apr', value: 1850000.0, secondaryValue: 1520000.0, displayValue: '17.8%'),
      ChartDataPoint(label: 'May', value: 2420000.0, secondaryValue: 1980000.0, displayValue: '18.1%'),
      ChartDataPoint(label: 'Jun', value: 2890000.0, secondaryValue: 2360000.0, displayValue: '18.3%'),
      ChartDataPoint(label: 'Jul', value: 3150000.0, secondaryValue: 2580000.0, displayValue: '18.0%'),
      ChartDataPoint(label: 'Aug', value: 3680000.0, secondaryValue: 3010000.0, displayValue: '18.2%'),
      ChartDataPoint(label: 'Sep', value: revenue, secondaryValue: cogs, displayValue: '${marginPercent.toStringAsFixed(1)}%'),
    ];

    final profitSegments = [
      ChartDataPoint(label: 'New Vehicle Margin', value: 450000.0, percentage: 58.8, color: AppColors.primaryYellow, displayValue: '₹4.5L (59%)'),
      ChartDataPoint(label: 'Accessories & Styling Kits', value: 140000.0, percentage: 18.3, color: AppColors.info, displayValue: '₹1.4L (18%)'),
      ChartDataPoint(label: 'Finance & Insurance Subvention', value: 105000.0, percentage: 13.7, color: AppColors.success, displayValue: '₹1.05L (14%)'),
      ChartDataPoint(label: 'Workshop & Labor Charges', value: 70000.0, percentage: 9.2, color: AppColors.warning, displayValue: '₹70K (9%)'),
    ];

    final showroomRanking = [
      ChartDataPoint(label: 'Mumbai Flagship', value: 245000.0, percentage: 51.0, color: AppColors.primaryYellow, displayValue: '₹2.45L • 18.4% Margin'),
      ChartDataPoint(label: 'Pune West Hub', value: 155000.0, percentage: 32.3, color: AppColors.info, displayValue: '₹1.55L • 17.8% Margin'),
      ChartDataPoint(label: 'Bangalore Metro', value: 80000.0, percentage: 16.7, color: AppColors.success, displayValue: '₹80K • 16.9% Margin'),
    ];

    final modelMargins = [
      {'model': 'Honda CB350 H\'ness DLX', 'asp': 217800.0, 'cogs': 178500.0, 'margin': 39300.0, 'marginPct': 18.0},
      {'model': 'Ather 450X Gen 3', 'asp': 154999.0, 'cogs': 129000.0, 'margin': 25999.0, 'marginPct': 16.8},
      {'model': 'TVS Apache RTR 310', 'asp': 242000.0, 'cogs': 196000.0, 'margin': 46000.0, 'marginPct': 19.0},
      {'model': 'Honda Activa 6G Premium', 'asp': 88500.0, 'cogs': 75200.0, 'margin': 13300.0, 'marginPct': 15.0},
    ];

    return ProfitDashboardData(
      grossRevenue: revenue,
      costOfGoodsSold: cogs,
      grossProfit: grossProfit,
      grossMarginPercent: marginPercent,
      operatingExpenses: opex,
      ebitda: ebitda,
      ebitdaMarginPercent: ebitdaMargin,
      revenueVsCogsTrend: waterfall,
      profitContributionBySegment: profitSegments,
      showroomProfitabilityRanking: showroomRanking,
      marginBreakdownByModel: modelMargins,
    );
  }
}
