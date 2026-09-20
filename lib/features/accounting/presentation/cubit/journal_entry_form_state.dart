import 'package:equatable/equatable.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/journal_entry_entity.dart';
import '../../domain/entities/journal_line_entity.dart';

/// Journal Entry Form State
class JournalEntryFormState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final JournalEntryEntity? savedEntry;
  final List<AccountEntity> availableAccounts;
  final String showroomId;
  final DateTime entryDate;
  final String referenceType;
  final String referenceId;
  final String narration;
  final List<JournalLineEntity> lines;

  const JournalEntryFormState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.savedEntry,
    this.availableAccounts = const [],
    this.showroomId = 'showroom-mumbai-main',
    required this.entryDate,
    this.referenceType = 'manual',
    this.referenceId = '',
    this.narration = '',
    this.lines = const [],
  });

  double get totalDebit => lines.fold<double>(0.0, (sum, l) => sum + l.debitAmount);
  double get totalCredit => lines.fold<double>(0.0, (sum, l) => sum + l.creditAmount);
  double get balanceDifference => (totalDebit - totalCredit).abs();
  bool get isBalanced => balanceDifference < 0.01 && totalDebit > 0;
  bool get isValid => isBalanced && narration.trim().isNotEmpty && lines.length >= 2;

  JournalEntryFormState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    JournalEntryEntity? savedEntry,
    List<AccountEntity>? availableAccounts,
    String? showroomId,
    DateTime? entryDate,
    String? referenceType,
    String? referenceId,
    String? narration,
    List<JournalLineEntity>? lines,
  }) {
    return JournalEntryFormState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      savedEntry: savedEntry,
      availableAccounts: availableAccounts ?? this.availableAccounts,
      showroomId: showroomId ?? this.showroomId,
      entryDate: entryDate ?? this.entryDate,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      narration: narration ?? this.narration,
      lines: lines ?? this.lines,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        error,
        savedEntry,
        availableAccounts,
        showroomId,
        entryDate,
        referenceType,
        referenceId,
        narration,
        lines,
      ];
}
