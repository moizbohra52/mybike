import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/finance_management_service.dart';
import '../../../accounting/domain/entities/account_entity.dart';
import 'finance_dashboard_state.dart';

/// Finance Dashboard Cubit
class FinanceDashboardCubit extends Cubit<FinanceDashboardState> {
  final FinanceManagementService _service;

  FinanceDashboardCubit({FinanceManagementService? service})
      : _service = service ?? FinanceManagementService.instance,
        super(const FinanceDashboardState());

  /// Load all finance KPIs, Cash/Bank liquid accounts, outstandings and recent vouchers
  Future<void> loadDashboard({String? showroomId}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final shId = showroomId ?? state.selectedShowroomId;

      final liquidData = await _service.getLiquidBalances(showroomId: shId);
      final outstandingsData = await _service.getOutstandingsSummary(showroomId: shId);
      final vouchers = await _service.fetchVouchers(showroomId: shId);

      emit(state.copyWith(
        isLoading: false,
        totalLiquid: liquidData['totalLiquid'] as double,
        totalCash: liquidData['totalCash'] as double,
        totalBank: liquidData['totalBank'] as double,
        cashAccounts: liquidData['cashAccounts'] as List<AccountEntity>,
        bankAccounts: liquidData['bankAccounts'] as List<AccountEntity>,
        totalReceivables: outstandingsData['totalReceivable'] as double,
        totalPayables: outstandingsData['totalPayable'] as double,
        netWorkingBalance: outstandingsData['netWorkingBalance'] as double,
        overdueReceivables: outstandingsData['overdueReceivables'] as double,
        overduePayables: outstandingsData['overduePayables'] as double,
        recentVouchers: vouchers.take(8).toList(),
        selectedShowroomId: shId,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Filter dashboard by showroom branch
  void filterByShowroom(String? showroomId) {
    loadDashboard(showroomId: showroomId);
  }
}
