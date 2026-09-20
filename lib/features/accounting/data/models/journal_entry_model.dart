import '../../domain/entities/journal_entry_entity.dart';
import '../../domain/entities/journal_line_entity.dart';

/// Journal Entry & Line Data Model (Supabase JSON ↔ Entity)
class JournalEntryModel {
  const JournalEntryModel._();

  static JournalEntryEntity fromJson(Map<String, dynamic> json, {List<JournalLineEntity>? lines}) {
    return JournalEntryEntity(
      id: json['id'] as String,
      showroomId: json['showroom_id'] as String,
      entryNumber: json['entry_number'] as String,
      entryDate: DateTime.parse(json['entry_date'] as String),
      financialYearId: json['financial_year_id'] as String?,
      referenceType: json['reference_type'] as String? ?? 'manual',
      referenceId: json['reference_id'] as String?,
      narration: json['narration'] as String? ?? '',
      totalDebit: (json['total_debit'] as num?)?.toDouble() ?? 0.0,
      totalCredit: (json['total_credit'] as num?)?.toDouble() ?? 0.0,
      isBalanced: json['is_balanced'] as bool? ?? true,
      status: json['status'] as String? ?? 'draft',
      reversedEntryId: json['reversed_entry_id'] as String?,
      createdBy: json['created_by'] as String?,
      postedAt: json['posted_at'] != null ? DateTime.parse(json['posted_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lines: lines ?? [],
      showroomName: json['showroom_name'] as String?,
    );
  }

  static Map<String, dynamic> toJson(JournalEntryEntity entity) {
    return {
      'id': entity.id,
      'showroom_id': entity.showroomId,
      'entry_number': entity.entryNumber,
      'entry_date': entity.entryDate.toIso8601String().split('T').first,
      'financial_year_id': entity.financialYearId,
      'reference_type': entity.referenceType,
      'reference_id': entity.referenceId,
      'narration': entity.narration,
      'total_debit': entity.totalDebit,
      'total_credit': entity.totalCredit,
      'is_balanced': entity.isBalanced,
      'status': entity.status,
      'reversed_entry_id': entity.reversedEntryId,
      'created_by': entity.createdBy,
      'posted_at': entity.postedAt?.toIso8601String(),
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> toInsertJson(JournalEntryEntity entity) {
    final map = toJson(entity);
    if (entity.id.isEmpty) {
      map.remove('id');
    }
    return map;
  }
}

/// Journal Line Model
class JournalLineModel {
  const JournalLineModel._();

  static JournalLineEntity fromJson(Map<String, dynamic> json) {
    return JournalLineEntity(
      id: json['id'] as String,
      journalEntryId: json['journal_entry_id'] as String,
      accountId: json['account_id'] as String,
      description: json['description'] as String?,
      debitAmount: (json['debit_amount'] as num?)?.toDouble() ?? 0.0,
      creditAmount: (json['credit_amount'] as num?)?.toDouble() ?? 0.0,
      showroomId: json['showroom_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      accountCode: json['account_code'] as String?,
      accountName: json['account_name'] as String?,
      accountType: json['account_type'] as String?,
    );
  }

  static Map<String, dynamic> toJson(JournalLineEntity entity) {
    return {
      'id': entity.id,
      'journal_entry_id': entity.journalEntryId,
      'account_id': entity.accountId,
      'description': entity.description,
      'debit_amount': entity.debitAmount,
      'credit_amount': entity.creditAmount,
      'showroom_id': entity.showroomId,
      'created_at': entity.createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> toInsertJson(JournalLineEntity entity) {
    final map = toJson(entity);
    if (entity.id.isEmpty) {
      map.remove('id');
    }
    return map;
  }
}
