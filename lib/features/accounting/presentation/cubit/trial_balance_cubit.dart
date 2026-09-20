import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/accounting_management_service.dart';
import '../../domain/entities/trial_balance_item_entity.dart';
import 'trial_balance_state.dart';

/// Trial Balance Cubit
class TrialBalanceCubit extends Cubit<TrialBalanceState> {
  final AccountingManagementService _service;

  TrialBalanceCubit({AccountingManagementService? service})
      : _service = service ?? AccountingManagementService.instance,
        super(TrialBalanceState(asOfDate: DateTime.now()));

  /// Load live Trial Balance statement
  Future<void> loadTrialBalance({String? showroomId, DateTime? asOfDate}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final shId = showroomId ?? state.selectedShowroomId;
      final date = asOfDate ?? state.asOfDate;

      final result = await _service.generateTrialBalance(
        showroomId: shId,
        asOfDate: date,
      );

      final items = result['items'] as List<TrialBalanceItemEntity>;
      // Sort by account code
      items.sort((a, b) => a.accountCode.compareTo(b.accountCode));

      emit(state.copyWith(
        isLoading: false,
        items: items,
        totalDebit: result['totalDebit'] as double,
        totalCredit: result['totalCredit'] as double,
        difference: result['difference'] as double,
        isBalanced: result['isBalanced'] as bool,
        asOfDate: date,
        selectedShowroomId: shId,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Filter trial balance by showroom branch
  void filterByShowroom(String? showroomId) {
    loadTrialBalance(showroomId: showroomId);
  }
}
