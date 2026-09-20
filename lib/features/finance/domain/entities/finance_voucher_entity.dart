import 'package:equatable/equatable.dart';

/// Finance Voucher Domain Entity
///
/// Represents an official financial transaction voucher (Payment, Receipt, Contra,
/// Petty Cash Expense, Credit Note, or Debit Note) in MYBIKE.
class FinanceVoucherEntity extends Equatable {
  final String id;
  final String showroomId;
  final String voucherNumber; // e.g. "PMT-MUM-2026-00001", "RCT-MUM-2026-00001"
  final String voucherType; // 'payment', 'receipt', 'contra', 'expense', 'credit_note', 'debit_note'
  final DateTime voucherDate;
  
  // Party Details
  final String partyType; // 'customer', 'supplier', 'oem', 'staff', 'bank', 'other'
  final String? partyId;
  final String partyName;
  final String? partyPhone;
  
  // Payment & Account Details
  final String paymentMode; // 'cash', 'bank_transfer', 'upi', 'cheque', 'dd', 'clearing'
  final String? sourceAccountId; // COA Account paying or withdrawing
  final String? destinationAccountId; // COA Account receiving or benefiting
  
  // Amounts
  final double amount;
  final double taxDeductedTds;
  final double netAmount;
  
  // References & Cheque Details
  final String? referenceNumber; // Cheque No, UTR, UPI transaction ID, Original Invoice
  final DateTime? referenceDate;
  final String? bankName;
  final String narration;
  
  // Status & Linkage
  final String status; // 'draft', 'posted', 'cancelled'
  final String? journalEntryId; // Linked General Ledger voucher
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Hydrated display helpers
  final String? showroomName;
  final String? sourceAccountName;
  final String? destinationAccountName;

  const FinanceVoucherEntity({
    required this.id,
    required this.showroomId,
    required this.voucherNumber,
    required this.voucherType,
    required this.voucherDate,
    required this.partyType,
    this.partyId,
    required this.partyName,
    this.partyPhone,
    this.paymentMode = 'bank_transfer',
    this.sourceAccountId,
    this.destinationAccountId,
    required this.amount,
    this.taxDeductedTds = 0.0,
    required this.netAmount,
    this.referenceNumber,
    this.referenceDate,
    this.bankName,
    required this.narration,
    this.status = 'posted',
    this.journalEntryId,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.showroomName,
    this.sourceAccountName,
    this.destinationAccountName,
  });

  bool get isPayment => voucherType == 'payment';
  bool get isReceipt => voucherType == 'receipt';
  bool get isContra => voucherType == 'contra';
  bool get isExpense => voucherType == 'expense';
  bool get isCreditNote => voucherType == 'credit_note';
  bool get isDebitNote => voucherType == 'debit_note';

  bool get isPosted => status == 'posted';
  bool get isDraft => status == 'draft';
  bool get isCancelled => status == 'cancelled';

  String get typeLabel {
    switch (voucherType) {
      case 'payment':
        return 'Payment Voucher';
      case 'receipt':
        return 'Receipt Voucher';
      case 'contra':
        return 'Contra Transfer';
      case 'expense':
        return 'Petty Cash Expense';
      case 'credit_note':
        return 'Credit Note';
      case 'debit_note':
        return 'Debit Note';
      default:
        return voucherType.toUpperCase();
    }
  }

  String get paymentModeLabel {
    switch (paymentMode) {
      case 'cash':
        return 'Cash';
      case 'bank_transfer':
        return 'Bank Transfer (NEFT/RTGS)';
      case 'upi':
        return 'UPI / QR Payment';
      case 'cheque':
        return 'Cheque';
      case 'dd':
        return 'Demand Draft';
      case 'clearing':
        return 'Clearing A/c';
      default:
        return paymentMode.toUpperCase();
    }
  }

  FinanceVoucherEntity copyWith({
    String? id,
    String? showroomId,
    String? voucherNumber,
    String? voucherType,
    DateTime? voucherDate,
    String? partyType,
    String? partyId,
    String? partyName,
    String? partyPhone,
    String? paymentMode,
    String? sourceAccountId,
    String? destinationAccountId,
    double? amount,
    double? taxDeductedTds,
    double? netAmount,
    String? referenceNumber,
    DateTime? referenceDate,
    String? bankName,
    String? narration,
    String? status,
    String? journalEntryId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? showroomName,
    String? sourceAccountName,
    String? destinationAccountName,
  }) {
    return FinanceVoucherEntity(
      id: id ?? this.id,
      showroomId: showroomId ?? this.showroomId,
      voucherNumber: voucherNumber ?? this.voucherNumber,
      voucherType: voucherType ?? this.voucherType,
      voucherDate: voucherDate ?? this.voucherDate,
      partyType: partyType ?? this.partyType,
      partyId: partyId ?? this.partyId,
      partyName: partyName ?? this.partyName,
      partyPhone: partyPhone ?? this.partyPhone,
      paymentMode: paymentMode ?? this.paymentMode,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      amount: amount ?? this.amount,
      taxDeductedTds: taxDeductedTds ?? this.taxDeductedTds,
      netAmount: netAmount ?? this.netAmount,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      referenceDate: referenceDate ?? this.referenceDate,
      bankName: bankName ?? this.bankName,
      narration: narration ?? this.narration,
      status: status ?? this.status,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      showroomName: showroomName ?? this.showroomName,
      sourceAccountName: sourceAccountName ?? this.sourceAccountName,
      destinationAccountName: destinationAccountName ?? this.destinationAccountName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        showroomId,
        voucherNumber,
        voucherType,
        voucherDate,
        partyType,
        partyId,
        partyName,
        partyPhone,
        paymentMode,
        sourceAccountId,
        destinationAccountId,
        amount,
        taxDeductedTds,
        netAmount,
        referenceNumber,
        referenceDate,
        bankName,
        narration,
        status,
        journalEntryId,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
