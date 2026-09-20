import 'package:equatable/equatable.dart';
import '../../domain/entities/finance_voucher_entity.dart';
import '../../../accounting/domain/entities/account_entity.dart';

/// Finance Dashboard State
class FinanceDashboardState extends Equatable {
  final bool isLoading;
  final String? error;

  // Liquid Cash & Bank Position
  final double totalLiquid;
  final double totalCash;
  final double totalBank;
  final List<AccountEntity> cashAccounts;
  final List<AccountEntity> bankAccounts;

  // Outstandings Summary
  final double totalReceivables;
  final double totalPayables;
  final double netWorkingBalance;
  final double overdueReceivables;
  final double overduePayables;

  // Recent Activity
  final List<FinanceVoucherEntity> recentVouchers;
  final String? selectedShowroomId;

  const FinanceDashboardState({
    this.isLoading = false,
    this.error,
    this.totalLiquid = 0.0,
    this.totalCash = 0.0,
    this.totalBank = 0.0,
    this.cashAccounts = const [],
    this.bankAccounts = const [],
    this.totalReceivables = 0.0,
    this.totalPayables = 0.0,
    this.netWorkingBalance = 0.0,
    this.overdueReceivables = 0.0,
    this.overduePayables = 0.0,
    this.recentVouchers = const [],
    this.selectedShowroomId,
  });

  FinanceDashboardState copyWith({
    bool? isLoading,
    String? error,
    double? totalLiquid,
    double? totalCash,
    double? totalBank,
    List<AccountEntity>? cashAccounts,
    List<AccountEntity>? bankAccounts,
    double? totalReceivables,
    double? totalPayables,
    double? netWorkingBalance,
    double? overdueReceivables,
    double? overduePayables,
    List<FinanceVoucherEntity>? recentVouchers,
    String? selectedShowroomId,
  }) {
    return FinanceDashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalLiquid: totalLiquid ?? this.totalLiquid,
      totalCash: totalCash ?? this.totalCash,
      totalBank: totalBank ?? this.totalBank,
      cashAccounts: cashAccounts ?? this.cashAccounts,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      totalReceivables: totalReceivables ?? this.totalReceivables,
      totalPayables: totalPayables ?? this.totalPayables,
      netWorkingBalance: netWorkingBalance ?? this.netWorkingBalance,
      overdueReceivables: overdueReceivables ?? this.overdueReceivables,
      overduePayables: overduePayables ?? this.overduePayables,
      recentVouchers: recentVouchers ?? this.recentVouchers,
      selectedShowroomId: selectedShowroomId ?? this.selectedShowroomId,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        totalLiquid,
        totalCash,
        totalBank,
        cashAccounts,
        bankAccounts,
        totalReceivables,
        totalPayables,
        netWorkingBalance,
        overdueReceivables,
        overduePayables,
        recentVouchers,
        selectedShowroomId,
      ];
}
