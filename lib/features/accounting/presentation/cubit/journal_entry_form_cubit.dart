import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/accounting_management_service.dart';
import '../../domain/entities/journal_entry_entity.dart';
import '../../domain/entities/journal_line_entity.dart';
import 'journal_entry_form_state.dart';

/// Journal Entry Form Cubit
class JournalEntryFormCubit extends Cubit<JournalEntryFormState> {
  final AccountingManagementService _service;

  JournalEntryFormCubit({AccountingManagementService? service})
      : _service = service ?? AccountingManagementService.instance,
        super(JournalEntryFormState(entryDate: DateTime.now()));

  /// Initialize form with accounts and initial 2 balanced lines
  Future<void> init({String? defaultShowroomId}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final accounts = await _service.fetchAccounts(showroomId: defaultShowroomId);
      final shId = defaultShowroomId ?? state.showroomId;

      final initialLines = [
        JournalLineEntity(
          id: 'line-temp-1',
          journalEntryId: '',
          accountId: accounts.isNotEmpty ? accounts.first.id : '',
          accountCode: accounts.isNotEmpty ? accounts.first.accountCode : '',
          accountName: accounts.isNotEmpty ? accounts.first.accountName : '',
          accountType: accounts.isNotEmpty ? accounts.first.accountType : '',
          debitAmount: 0.0,
          creditAmount: 0.0,
          showroomId: shId,
          createdAt: DateTime.now(),
        ),
        JournalLineEntity(
          id: 'line-temp-2',
          journalEntryId: '',
          accountId: accounts.length > 1 ? accounts[1].id : (accounts.isNotEmpty ? accounts.first.id : ''),
          accountCode: accounts.length > 1 ? accounts[1].accountCode : '',
          accountName: accounts.length > 1 ? accounts[1].accountName : '',
          accountType: accounts.length > 1 ? accounts[1].accountType : '',
          debitAmount: 0.0,
          creditAmount: 0.0,
          showroomId: shId,
          createdAt: DateTime.now(),
        ),
      ];

      emit(state.copyWith(
        isLoading: false,
        availableAccounts: accounts,
        showroomId: shId,
        lines: initialLines,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Update voucher header fields
  void updateHeader({
    DateTime? date,
    String? referenceType,
    String? referenceId,
    String? narration,
    String? showroomId,
  }) {
    emit(state.copyWith(
      entryDate: date ?? state.entryDate,
      referenceType: referenceType ?? state.referenceType,
      referenceId: referenceId ?? state.referenceId,
      narration: narration ?? state.narration,
      showroomId: showroomId ?? state.showroomId,
    ));
  }

  /// Add an empty line
  void addLine() {
    final defaultAcc = state.availableAccounts.isNotEmpty ? state.availableAccounts.first : null;
    final newLine = JournalLineEntity(
      id: 'line-temp-${DateTime.now().microsecondsSinceEpoch}',
      journalEntryId: '',
      accountId: defaultAcc?.id ?? '',
      accountCode: defaultAcc?.accountCode,
      accountName: defaultAcc?.accountName,
      accountType: defaultAcc?.accountType,
      debitAmount: 0.0,
      creditAmount: 0.0,
      showroomId: state.showroomId,
      createdAt: DateTime.now(),
    );

    final updated = List<JournalLineEntity>.from(state.lines)..add(newLine);
    emit(state.copyWith(lines: updated));
  }

  /// Remove line at index (must keep at least 2 lines)
  void removeLine(int index) {
    if (state.lines.length <= 2) return;
    final updated = List<JournalLineEntity>.from(state.lines)..removeAt(index);
    emit(state.copyWith(lines: updated));
  }

  /// Update individual line item
  void updateLine(
    int index, {
    String? accountId,
    double? debit,
    double? credit,
    String? description,
  }) {
    if (index < 0 || index >= state.lines.length) return;

    final line = state.lines[index];
    final updatedAcc = accountId != null
        ? state.availableAccounts.firstWhere((a) => a.id == accountId)
        : null;

    final updatedLine = line.copyWith(
      accountId: accountId ?? line.accountId,
      accountCode: updatedAcc?.accountCode ?? line.accountCode,
      accountName: updatedAcc?.accountName ?? line.accountName,
      accountType: updatedAcc?.accountType ?? line.accountType,
      debitAmount: debit ?? line.debitAmount,
      creditAmount: credit ?? line.creditAmount,
      description: description ?? line.description,
    );

    final updatedLines = List<JournalLineEntity>.from(state.lines);
    updatedLines[index] = updatedLine;

    emit(state.copyWith(lines: updatedLines));
  }

  /// Submit and post the Journal Voucher
  Future<bool> submitJournal({bool autoPost = true}) async {
    if (!state.isValid) {
      emit(state.copyWith(
        error: 'Cannot submit: Voucher is unbalanced or missing required narration.',
      ));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      final entry = JournalEntryEntity(
        id: '',
        showroomId: state.showroomId,
        entryNumber: '',
        entryDate: state.entryDate,
        referenceType: state.referenceType,
        referenceId: state.referenceId.isNotEmpty ? state.referenceId : null,
        narration: state.narration.trim(),
        totalDebit: state.totalDebit,
        totalCredit: state.totalCredit,
        isBalanced: true,
        status: autoPost ? 'posted' : 'draft',
        postedAt: autoPost ? DateTime.now() : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await _service.createJournalEntry(
        entry,
        state.lines,
        autoPost: autoPost,
      );

      emit(state.copyWith(
        isSubmitting: false,
        savedEntry: saved,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
      return false;
    }
  }
}
