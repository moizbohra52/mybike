import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/accounting_management_service.dart';
import '../../domain/entities/journal_entry_entity.dart';
import 'journal_entry_list_state.dart';

/// Journal Entry List Cubit
class JournalEntryListCubit extends Cubit<JournalEntryListState> {
  final AccountingManagementService _service;

  JournalEntryListCubit({AccountingManagementService? service})
      : _service = service ?? AccountingManagementService.instance,
        super(const JournalEntryListState());

  /// Load journal entries
  Future<void> loadJournals() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final journals = await _service.fetchJournalEntries(
        showroomId: state.selectedShowroomId,
      );
      _applyFiltersAndKPIs(
        journals,
        state.selectedStatus,
        state.selectedReferenceType,
        state.searchQuery,
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Filter by voucher status ('posted', 'draft', 'reversed', null)
  void filterByStatus(String? status) {
    _applyFiltersAndKPIs(
      state.journals,
      status,
      state.selectedReferenceType,
      state.searchQuery,
    );
  }

  /// Filter by reference type
  void filterByReferenceType(String? refType) {
    _applyFiltersAndKPIs(
      state.journals,
      state.selectedStatus,
      refType,
      state.searchQuery,
    );
  }

  /// Search vouchers by voucher number, narration, or reference
  void searchJournals(String query) {
    _applyFiltersAndKPIs(
      state.journals,
      state.selectedStatus,
      state.selectedReferenceType,
      query,
    );
  }

  /// Filter by showroom branch
  void filterByShowroom(String? showroomId) {
    emit(state.copyWith(selectedShowroomId: showroomId));
    loadJournals();
  }

  /// Reverse a posted journal entry
  Future<bool> reverseEntry(String entryId, {required String reason, String reversedBy = 'Showroom Accountant'}) async {
    try {
      await _service.reverseJournalEntry(
        entryId,
        reason: reason,
        reversedBy: reversedBy,
      );
      await loadJournals();
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  void _applyFiltersAndKPIs(
    List<JournalEntryEntity> allJournals,
    String? status,
    String? refType,
    String query,
  ) {
    var filtered = List<JournalEntryEntity>.from(allJournals);

    if (status != null && status.isNotEmpty) {
      filtered = filtered.where((j) => j.status == status).toList();
    }

    if (refType != null && refType.isNotEmpty) {
      filtered = filtered.where((j) => j.referenceType == refType).toList();
    }

    if (query.isNotEmpty) {
      final s = query.toLowerCase();
      filtered = filtered.where((j) =>
          j.entryNumber.toLowerCase().contains(s) ||
          j.narration.toLowerCase().contains(s) ||
          (j.referenceId?.toLowerCase().contains(s) ?? false)).toList();
    }

    // Sort descending by date
    filtered.sort((a, b) => b.entryDate.compareTo(a.entryDate));

    double totalDebits = 0.0;
    double totalCredits = 0.0;
    int posted = 0;
    int reversed = 0;

    for (final j in allJournals) {
      if (j.status == 'posted') {
        posted++;
        totalDebits += j.totalDebit;
        totalCredits += j.totalCredit;
      } else if (j.status == 'reversed') {
        reversed++;
      }
    }

    emit(state.copyWith(
      isLoading: false,
      journals: allJournals,
      filteredJournals: filtered,
      selectedStatus: status,
      selectedReferenceType: refType,
      searchQuery: query,
      totalDebits: totalDebits,
      totalCredits: totalCredits,
      postedCount: posted,
      reversedCount: reversed,
    ));
  }
}
