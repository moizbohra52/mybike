import 'package:equatable/equatable.dart';
import '../../domain/entities/journal_entry_entity.dart';

/// Journal Entry List State
class JournalEntryListState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<JournalEntryEntity> journals;
  final List<JournalEntryEntity> filteredJournals;
  final String? selectedStatus; // null = all, 'posted', 'draft', 'reversed'
  final String? selectedReferenceType;
  final String? selectedShowroomId;
  final String searchQuery;

  // KPIs
  final double totalDebits;
  final double totalCredits;
  final int postedCount;
  final int reversedCount;

  const JournalEntryListState({
    this.isLoading = false,
    this.error,
    this.journals = const [],
    this.filteredJournals = const [],
    this.selectedStatus,
    this.selectedReferenceType,
    this.selectedShowroomId,
    this.searchQuery = '',
    this.totalDebits = 0.0,
    this.totalCredits = 0.0,
    this.postedCount = 0,
    this.reversedCount = 0,
  });

  JournalEntryListState copyWith({
    bool? isLoading,
    String? error,
    List<JournalEntryEntity>? journals,
    List<JournalEntryEntity>? filteredJournals,
    String? selectedStatus,
    String? selectedReferenceType,
    String? selectedShowroomId,
    String? searchQuery,
    double? totalDebits,
    double? totalCredits,
    int? postedCount,
    int? reversedCount,
  }) {
    return JournalEntryListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      journals: journals ?? this.journals,
      filteredJournals: filteredJournals ?? this.filteredJournals,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedReferenceType: selectedReferenceType ?? this.selectedReferenceType,
      selectedShowroomId: selectedShowroomId ?? this.selectedShowroomId,
      searchQuery: searchQuery ?? this.searchQuery,
      totalDebits: totalDebits ?? this.totalDebits,
      totalCredits: totalCredits ?? this.totalCredits,
      postedCount: postedCount ?? this.postedCount,
      reversedCount: reversedCount ?? this.reversedCount,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        journals,
        filteredJournals,
        selectedStatus,
        selectedReferenceType,
        selectedShowroomId,
        searchQuery,
        totalDebits,
        totalCredits,
        postedCount,
        reversedCount,
      ];
}
