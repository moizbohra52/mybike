import 'package:equatable/equatable.dart';
import 'chart_data_point.dart';

/// Stock & Inventory Health Analytics Data Entity
class InventoryDashboardData extends Equatable {
  final int totalUnitsOnHand;
  final double totalStockValuationInr;
  final double averageHoldingDays;
  final int agingStockCount; // Held > 60 days
  final List<ChartDataPoint> categoryDistribution; // Motorcycles, Scooters, EV, Spares
  final List<ChartDataPoint> showroomStockBalance; // Mumbai vs Pune vs Bangalore
  final List<ChartDataPoint> stockStatusSplit; // In Stock, Reserved, In Transit, Display
  final List<Map<String, dynamic>> agingAlerts;

  const InventoryDashboardData({
    required this.totalUnitsOnHand,
    required this.totalStockValuationInr,
    required this.averageHoldingDays,
    required this.agingStockCount,
    required this.categoryDistribution,
    required this.showroomStockBalance,
    required this.stockStatusSplit,
    required this.agingAlerts,
  });

  @override
  List<Object?> get props => [
        totalUnitsOnHand,
        totalStockValuationInr,
        averageHoldingDays,
        agingStockCount,
        categoryDistribution,
        showroomStockBalance,
        stockStatusSplit,
        agingAlerts,
      ];
}
