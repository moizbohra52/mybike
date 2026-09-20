import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/finance_management_service.dart';
import '../../domain/entities/finance_voucher_entity.dart';
import 'voucher_list_state.dart';

/// Voucher List Cubit
class VoucherListCubit extends Cubit<VoucherListState> {
  final FinanceManagementService _service;

  VoucherListCubit({FinanceManagementService? service})
      : _service = service ?? FinanceManagementService.instance,
        super(const VoucherListState());

  /// Load all vouchers
  Future<void> loadVouchers() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final list = await _service.fetchVouchers(
        showroomId: state.selectedShowroomId,
      );
      _applyFiltersAndKPIs(list, state.selectedType, state.selectedStatus, state.searchQuery);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Filter by voucher type ('all', 'payment', 'receipt', 'contra', 'expense', 'credit_note', 'debit_note')
  void filterByType(String type) {
    _applyFiltersAndKPIs(state.vouchers, type, state.selectedStatus, state.searchQuery);
  }

  /// Filter by status ('all', 'posted', 'draft', 'cancelled')
  void filterByStatus(String status) {
    _applyFiltersAndKPIs(state.vouchers, state.selectedType, status, state.searchQuery);
  }

  /// Search vouchers by voucher number, party name, or reference
  void searchVouchers(String query) {
    _applyFiltersAndKPIs(state.vouchers, state.selectedType, state.selectedStatus, query);
  }

  /// Filter by showroom branch
  void filterByShowroom(String? showroomId) {
    emit(state.copyWith(selectedShowroomId: showroomId));
    loadVouchers();
  }

  /// Clear all filters
  void clearFilters() {
    _applyFiltersAndKPIs(state.vouchers, 'all', 'all', '');
  }

  void _applyFiltersAndKPIs(
    List<FinanceVoucherEntity> allVouchers,
    String type,
    String status,
    String query,
  ) {
    var filtered = List<FinanceVoucherEntity>.from(allVouchers);

    if (type != 'all') {
      filtered = filtered.where((v) => v.voucherType == type).toList();
    }

    if (status != 'all') {
      filtered = filtered.where((v) => v.status == status).toList();
    }

    if (query.isNotEmpty) {
      final s = query.toLowerCase();
      filtered = filtered.where((v) =>
          v.voucherNumber.toLowerCase().contains(s) ||
          v.partyName.toLowerCase().contains(s) ||
          (v.referenceNumber?.toLowerCase().contains(s) ?? false)).toList();
    }

    // Sort descending by date
    filtered.sort((a, b) => b.voucherDate.compareTo(a.voucherDate));

    double disbursed = 0.0;
    double received = 0.0;
    double contra = 0.0;

    for (final v in filtered) {
      if (v.status != 'posted') continue;
      if (v.isPayment || v.isExpense) {
        disbursed += v.netAmount;
      } else if (v.isReceipt) {
        received += v.netAmount;
      } else if (v.isContra) {
        contra += v.netAmount;
      }
    }

    emit(state.copyWith(
      isLoading: false,
      vouchers: allVouchers,
      filteredVouchers: filtered,
      selectedType: type,
      selectedStatus: status,
      searchQuery: query,
      totalDisbursed: disbursed,
      totalReceived: received,
      totalContra: contra,
      count: filtered.length,
    ));
  }
}
