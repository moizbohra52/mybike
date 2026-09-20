import 'package:equatable/equatable.dart';
import 'chart_data_point.dart';

/// Sales Analytics & KPI Data Entity
class SalesDashboardData extends Equatable {
  final double totalRevenue;
  final int deliveredBikesCount;
  final int pendingBookingsCount;
  final double averageTicketSize;
  final double targetAchievementPercent;
  final List<ChartDataPoint> monthlyRevenueTrend;
  final List<ChartDataPoint> powertrainShare; // Petrol vs EV
  final List<ChartDataPoint> topModels; // Best sellers leaderboard
  final List<Map<String, dynamic>> recentDeliveries;

  const SalesDashboardData({
    required this.totalRevenue,
    required this.deliveredBikesCount,
    required this.pendingBookingsCount,
    required this.averageTicketSize,
    required this.targetAchievementPercent,
    required this.monthlyRevenueTrend,
    required this.powertrainShare,
    required this.topModels,
    required this.recentDeliveries,
  });

  @override
  List<Object?> get props => [
        totalRevenue,
        deliveredBikesCount,
        pendingBookingsCount,
        averageTicketSize,
        targetAchievementPercent,
        monthlyRevenueTrend,
        powertrainShare,
        topModels,
        recentDeliveries,
      ];
}
