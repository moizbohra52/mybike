import '../../domain/entities/finance_voucher_entity.dart';

/// Finance Voucher Data Model (Supabase JSON ↔ Entity)
class FinanceVoucherModel {
  const FinanceVoucherModel._();

  static FinanceVoucherEntity fromJson(Map<String, dynamic> json) {
    return FinanceVoucherEntity(
      id: json['id'] as String,
      showroomId: json['showroom_id'] as String,
      voucherNumber: json['voucher_number'] as String,
      voucherType: json['voucher_type'] as String,
      voucherDate: DateTime.parse(json['voucher_date'] as String),
      partyType: json['party_type'] as String,
      partyId: json['party_id'] as String?,
      partyName: json['party_name'] as String,
      partyPhone: json['party_phone'] as String?,
      paymentMode: json['payment_mode'] as String? ?? 'bank_transfer',
      sourceAccountId: json['source_account_id'] as String?,
      destinationAccountId: json['destination_account_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      taxDeductedTds: (json['tax_deducted_tds'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['net_amount'] as num).toDouble(),
      referenceNumber: json['reference_number'] as String?,
      referenceDate: json['reference_date'] != null
          ? DateTime.parse(json['reference_date'] as String)
          : null,
      bankName: json['bank_name'] as String?,
      narration: json['narration'] as String? ?? '',
      status: json['status'] as String? ?? 'posted',
      journalEntryId: json['journal_entry_id'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      showroomName: json['showroom_name'] as String?,
      sourceAccountName: json['source_account_name'] as String?,
      destinationAccountName: json['destination_account_name'] as String?,
    );
  }

  static Map<String, dynamic> toJson(FinanceVoucherEntity entity) {
    return {
      'id': entity.id,
      'showroom_id': entity.showroomId,
      'voucher_number': entity.voucherNumber,
      'voucher_type': entity.voucherType,
      'voucher_date': entity.voucherDate.toIso8601String().split('T').first,
      'party_type': entity.partyType,
      'party_id': entity.partyId,
      'party_name': entity.partyName,
      'party_phone': entity.partyPhone,
      'payment_mode': entity.paymentMode,
      'source_account_id': entity.sourceAccountId,
      'destination_account_id': entity.destinationAccountId,
      'amount': entity.amount,
      'tax_deducted_tds': entity.taxDeductedTds,
      'net_amount': entity.netAmount,
      'reference_number': entity.referenceNumber,
      'reference_date': entity.referenceDate?.toIso8601String().split('T').first,
      'bank_name': entity.bankName,
      'narration': entity.narration,
      'status': entity.status,
      'journal_entry_id': entity.journalEntryId,
      'created_by': entity.createdBy,
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> toInsertJson(FinanceVoucherEntity entity) {
    final map = toJson(entity);
    if (entity.id.isEmpty) {
      map.remove('id');
    }
    return map;
  }
}
