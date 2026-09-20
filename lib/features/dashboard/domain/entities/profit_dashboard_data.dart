import 'package:equatable/equatable.dart';
import 'chart_data_point.dart';

/// Executive Profitability & Unit Economics Data Entity
class ProfitDashboardData extends Equatable {
  final double grossRevenue;
  final double costOfGoodsSold;
  final double grossProfit;
  final double grossMarginPercent;
  final double operatingExpenses;
  final double ebitda;
  final double ebitdaMarginPercent;
  final List<ChartDataPoint> revenueVsCogsTrend;
  final List<ChartDataPoint> profitContributionBySegment; // Vehicle Margins, Accessories, Subventions, Service
  final List<ChartDataPoint> showroomProfitabilityRanking; // Branch margins ranking
  final List<Map<String, dynamic>> marginBreakdownByModel;

  const ProfitDashboardData({
    required this.grossRevenue,
    required this.costOfGoodsSold,
    required this.grossProfit,
    required this.grossMarginPercent,
    required this.operatingExpenses,
    required this.ebitda,
    required this.ebitdaMarginPercent,
    required this.revenueVsCogsTrend,
    required this.profitContributionBySegment,
    required this.showroomProfitabilityRanking,
    required this.marginBreakdownByModel,
  });

  @override
  List<Object?> get props => [
        grossRevenue,
        costOfGoodsSold,
        grossProfit,
        grossMarginPercent,
        operatingExpenses,
        ebitda,
        ebitdaMarginPercent,
        revenueVsCogsTrend,
        profitContributionBySegment,
        showroomProfitabilityRanking,
        marginBreakdownByModel,
      ];
}
