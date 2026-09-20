import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/finance_management_service.dart';
import '../../domain/entities/party_outstanding_entity.dart';
import 'outstanding_state.dart';

/// Outstanding Cubit
class OutstandingCubit extends Cubit<OutstandingState> {
  final FinanceManagementService _service;

  OutstandingCubit({FinanceManagementService? service})
      : _service = service ?? FinanceManagementService.instance,
        super(const OutstandingState());

  /// Load both receivables and payables ledgers with aging
  Future<void> loadOutstandings({String? showroomId}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final shId = showroomId ?? state.selectedShowroomId;

      final receivables = await _service.fetchCustomerReceivables(showroomId: shId);
      final payables = await _service.fetchSupplierPayables(showroomId: shId);
      final summary = await _service.getOutstandingsSummary(showroomId: shId);

      _applyTabAndSearch(
        receivables: receivables,
        payables: payables,
        tab: state.activeTab,
        query: state.searchQuery,
        summary: summary,
        showroomId: shId,
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Switch between Customer Receivables and Vendor Payables
  void switchTab(String tab) {
    _applyTabAndSearch(
      receivables: state.customerReceivables,
      payables: state.supplierPayables,
      tab: tab,
      query: state.searchQuery,
    );
  }

  /// Search parties by name or phone
  void searchParties(String query) {
    _applyTabAndSearch(
      receivables: state.customerReceivables,
      payables: state.supplierPayables,
      tab: state.activeTab,
      query: query,
    );
  }

  /// Filter by showroom branch
  void filterByShowroom(String? showroomId) {
    loadOutstandings(showroomId: showroomId);
  }

  void _applyTabAndSearch({
    required List<PartyOutstandingEntity> receivables,
    required List<PartyOutstandingEntity> payables,
    required String tab,
    required String query,
    Map<String, dynamic>? summary,
    String? showroomId,
  }) {
    List<PartyOutstandingEntity> filteredRec = List.from(receivables);
    List<PartyOutstandingEntity> filteredPay = List.from(payables);

    if (query.isNotEmpty) {
      final s = query.toLowerCase();
      filteredRec = filteredRec.where((p) =>
          p.partyName.toLowerCase().contains(s) ||
          (p.phone?.toLowerCase().contains(s) ?? false) ||
          (p.email?.toLowerCase().contains(s) ?? false)).toList();

      filteredPay = filteredPay.where((p) =>
          p.partyName.toLowerCase().contains(s) ||
          (p.phone?.toLowerCase().contains(s) ?? false) ||
          (p.email?.toLowerCase().contains(s) ?? false)).toList();
    }

    final totalRec = summary != null
        ? (summary['totalReceivable'] as double)
        : state.totalReceivables;
    final totalPay = summary != null
        ? (summary['totalPayable'] as double)
        : state.totalPayables;
    final netBal = summary != null
        ? (summary['netWorkingBalance'] as double)
        : state.netBalance;

    final overdue = tab == 'receivables'
        ? filteredRec.fold<double>(0.0, (sum, p) => sum + (p.bucket31To60 + p.bucket61To90 + p.bucket90Plus))
        : filteredPay.fold<double>(0.0, (sum, p) => sum + (p.bucket31To60 + p.bucket61To90 + p.bucket90Plus));

    emit(state.copyWith(
      isLoading: false,
      customerReceivables: receivables,
      filteredReceivables: filteredRec,
      supplierPayables: payables,
      filteredPayables: filteredPay,
      activeTab: tab,
      searchQuery: query,
      selectedShowroomId: showroomId ?? state.selectedShowroomId,
      totalReceivables: totalRec,
      totalPayables: totalPay,
      netBalance: netBal,
      totalOverdue: overdue,
    ));
  }
}
