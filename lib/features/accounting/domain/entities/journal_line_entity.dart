import 'package:equatable/equatable.dart';

/// Journal Entry Line Entity
///
/// Represents an individual debit or credit line in a double-entry transaction.
class JournalLineEntity extends Equatable {
  final String id;
  final String journalEntryId;
  final String accountId;
  final String? description;
  final double debitAmount;
  final double creditAmount;
  final String? showroomId;
  final DateTime createdAt;

  // Hydrated display helpers
  final String? accountCode;
  final String? accountName;
  final String? accountType;

  const JournalLineEntity({
    required this.id,
    required this.journalEntryId,
    required this.accountId,
    this.description,
    this.debitAmount = 0.0,
    this.creditAmount = 0.0,
    this.showroomId,
    required this.createdAt,
    this.accountCode,
    this.accountName,
    this.accountType,
  });

  bool get isDebit => debitAmount > 0;
  bool get isCredit => creditAmount > 0;

  JournalLineEntity copyWith({
    String? id,
    String? journalEntryId,
    String? accountId,
    String? description,
    double? debitAmount,
    double? creditAmount,
    String? showroomId,
    DateTime? createdAt,
    String? accountCode,
    String? accountName,
    String? accountType,
  }) {
    return JournalLineEntity(
      id: id ?? this.id,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      accountId: accountId ?? this.accountId,
      description: description ?? this.description,
      debitAmount: debitAmount ?? this.debitAmount,
      creditAmount: creditAmount ?? this.creditAmount,
      showroomId: showroomId ?? this.showroomId,
      createdAt: createdAt ?? this.createdAt,
      accountCode: accountCode ?? this.accountCode,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
    );
  }

  @override
  List<Object?> get props => [
        id,
        journalEntryId,
        accountId,
        description,
        debitAmount,
        creditAmount,
        showroomId,
        createdAt,
      ];
}
