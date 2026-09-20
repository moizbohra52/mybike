import 'package:equatable/equatable.dart';
import 'chart_data_point.dart';

/// Procurement & Supplier Analytics Data Entity
class PurchaseDashboardData extends Equatable {
  final double totalProcurementSpend;
  final int inwardUnitsCount;
  final int pendingOrdersCount;
  final double supplierPayablesTotal;
  final List<ChartDataPoint> oemSpendDistribution; // Honda vs Ather vs TVS
  final List<ChartDataPoint> categorySpendBreakdown; // New Vehicles vs Spare Parts vs Riding Gear
  final List<ChartDataPoint> monthlyPurchaseTrend;
  final List<Map<String, dynamic>> recentConsignments;

  const PurchaseDashboardData({
    required this.totalProcurementSpend,
    required this.inwardUnitsCount,
    required this.pendingOrdersCount,
    required this.supplierPayablesTotal,
    required this.oemSpendDistribution,
    required this.categorySpendBreakdown,
    required this.monthlyPurchaseTrend,
    required this.recentConsignments,
  });

  @override
  List<Object?> get props => [
        totalProcurementSpend,
        inwardUnitsCount,
        pendingOrdersCount,
        supplierPayablesTotal,
        oemSpendDistribution,
        categorySpendBreakdown,
        monthlyPurchaseTrend,
        recentConsignments,
      ];
}
