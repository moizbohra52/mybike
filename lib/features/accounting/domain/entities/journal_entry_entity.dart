import 'package:equatable/equatable.dart';
import 'journal_line_entity.dart';

/// Journal Entry Domain Entity (General Ledger Voucher)
///
/// Models a complete double-entry transaction voucher in MYBIKE.
class JournalEntryEntity extends Equatable {
  final String id;
  final String showroomId;
  final String entryNumber; // e.g. "JRN-MUM-2026-00001"
  final DateTime entryDate;
  final String? financialYearId;
  final String referenceType; // 'manual', 'sales_invoice', 'payment_receipt', 'purchase_invoice', 'expense', 'reversal'
  final String? referenceId;
  final String narration;
  final double totalDebit;
  final double totalCredit;
  final bool isBalanced;
  final String status; // 'draft', 'posted', 'reversed'
  final String? reversedEntryId;
  final String? createdBy;
  final DateTime? postedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Hydrated lines
  final List<JournalLineEntity> lines;
  final String? showroomName;

  const JournalEntryEntity({
    required this.id,
    required this.showroomId,
    required this.entryNumber,
    required this.entryDate,
    this.financialYearId,
    this.referenceType = 'manual',
    this.referenceId,
    required this.narration,
    this.totalDebit = 0.0,
    this.totalCredit = 0.0,
    this.isBalanced = true,
    this.status = 'draft',
    this.reversedEntryId,
    this.createdBy,
    this.postedAt,
    required this.createdAt,
    required this.updatedAt,
    this.lines = const [],
    this.showroomName,
  });

  bool get isPosted => status == 'posted';
  bool get isDraft => status == 'draft';
  bool get isReversed => status == 'reversed';

  double get balanceDifference => (totalDebit - totalCredit).abs();
  bool get checkBalance => balanceDifference < 0.01;

  String get referenceTypeLabel {
    switch (referenceType) {
      case 'sales_invoice':
        return 'Sales Invoice';
      case 'payment_receipt':
        return 'Payment Receipt';
      case 'purchase_invoice':
        return 'Purchase Bill';
      case 'expense':
        return 'Expense Voucher';
      case 'reversal':
        return 'Reversal Voucher';
      case 'manual':
      default:
        return 'Manual Journal';
    }
  }

  JournalEntryEntity copyWith({
    String? id,
    String? showroomId,
    String? entryNumber,
    DateTime? entryDate,
    String? financialYearId,
    String? referenceType,
    String? referenceId,
    String? narration,
    double? totalDebit,
    double? totalCredit,
    bool? isBalanced,
    String? status,
    String? reversedEntryId,
    String? createdBy,
    DateTime? postedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<JournalLineEntity>? lines,
    String? showroomName,
  }) {
    return JournalEntryEntity(
      id: id ?? this.id,
      showroomId: showroomId ?? this.showroomId,
      entryNumber: entryNumber ?? this.entryNumber,
      entryDate: entryDate ?? this.entryDate,
      financialYearId: financialYearId ?? this.financialYearId,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      narration: narration ?? this.narration,
      totalDebit: totalDebit ?? this.totalDebit,
      totalCredit: totalCredit ?? this.totalCredit,
      isBalanced: isBalanced ?? this.isBalanced,
      status: status ?? this.status,
      reversedEntryId: reversedEntryId ?? this.reversedEntryId,
      createdBy: createdBy ?? this.createdBy,
      postedAt: postedAt ?? this.postedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lines: lines ?? this.lines,
      showroomName: showroomName ?? this.showroomName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        showroomId,
        entryNumber,
        entryDate,
        financialYearId,
        referenceType,
        referenceId,
        narration,
        totalDebit,
        totalCredit,
        isBalanced,
        status,
        reversedEntryId,
        createdBy,
        postedAt,
        createdAt,
        updatedAt,
        lines,
      ];
}
