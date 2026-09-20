import 'package:equatable/equatable.dart';
import 'chart_data_point.dart';

/// Treasury & Cash/Bank Analytics Data Entity
class FinanceDashboardData extends Equatable {
  final double totalLiquidFunds;
  final double cashOnHand;
  final double bankBalances;
  final double totalReceivables; // Sundry Debtors
  final double totalPayables; // Sundry Creditors
  final double netWorkingCapital;
  final List<ChartDataPoint> cashVsBankSplit;
  final List<ChartDataPoint> receivablesAging; // 0-30d, 31-60d, 61-90d, >90d
  final List<ChartDataPoint> paymentModeMix; // UPI, RTGS/NEFT, Cash, Cheque
  final List<ChartDataPoint> monthlyCashflowTrend; // Inflow vs Outflow
  final List<Map<String, dynamic>> recentVouchers;

  const FinanceDashboardData({
    required this.totalLiquidFunds,
    required this.cashOnHand,
    required this.bankBalances,
    required this.totalReceivables,
    required this.totalPayables,
    required this.netWorkingCapital,
    required this.cashVsBankSplit,
    required this.receivablesAging,
    required this.paymentModeMix,
    required this.monthlyCashflowTrend,
    required this.recentVouchers,
  });

  @override
  List<Object?> get props => [
        totalLiquidFunds,
        cashOnHand,
        bankBalances,
        totalReceivables,
        totalPayables,
        netWorkingCapital,
        cashVsBankSplit,
        receivablesAging,
        paymentModeMix,
        monthlyCashflowTrend,
        recentVouchers,
      ];
}
