import 'package:equatable/equatable.dart';
import '../../domain/entities/finance_voucher_entity.dart';

/// Voucher List State
class VoucherListState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<FinanceVoucherEntity> vouchers;
  final List<FinanceVoucherEntity> filteredVouchers;

  final String selectedType; // 'all', 'payment', 'receipt', 'contra', 'expense', 'credit_note', 'debit_note'
  final String selectedStatus; // 'all', 'posted', 'draft', 'cancelled'
  final String searchQuery;
  final String? selectedShowroomId;

  // KPIs across current filtered list
  final double totalDisbursed; // Payments & Expenses
  final double totalReceived; // Receipts
  final double totalContra; // Contra transfers
  final int count;

  const VoucherListState({
    this.isLoading = false,
    this.error,
    this.vouchers = const [],
    this.filteredVouchers = const [],
    this.selectedType = 'all',
    this.selectedStatus = 'all',
    this.searchQuery = '',
    this.selectedShowroomId,
    this.totalDisbursed = 0.0,
    this.totalReceived = 0.0,
    this.totalContra = 0.0,
    this.count = 0,
  });

  VoucherListState copyWith({
    bool? isLoading,
    String? error,
    List<FinanceVoucherEntity>? vouchers,
    List<FinanceVoucherEntity>? filteredVouchers,
    String? selectedType,
    String? selectedStatus,
    String? searchQuery,
    String? selectedShowroomId,
    double? totalDisbursed,
    double? totalReceived,
    double? totalContra,
    int? count,
  }) {
    return VoucherListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      vouchers: vouchers ?? this.vouchers,
      filteredVouchers: filteredVouchers ?? this.filteredVouchers,
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedShowroomId: selectedShowroomId ?? this.selectedShowroomId,
      totalDisbursed: totalDisbursed ?? this.totalDisbursed,
      totalReceived: totalReceived ?? this.totalReceived,
      totalContra: totalContra ?? this.totalContra,
      count: count ?? this.count,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        vouchers,
        filteredVouchers,
        selectedType,
        selectedStatus,
        searchQuery,
        selectedShowroomId,
        totalDisbursed,
        totalReceived,
        totalContra,
        count,
      ];
}
