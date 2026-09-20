import 'package:equatable/equatable.dart';
import '../../domain/entities/finance_voucher_entity.dart';
import '../../../accounting/domain/entities/account_entity.dart';

/// Voucher Form State
class VoucherFormState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final FinanceVoucherEntity? savedVoucher;

  // Available GL accounts from Chart of Accounts
  final List<AccountEntity> availableAccounts;

  // Form Fields
  final String showroomId;
  final String voucherType; // 'payment', 'receipt', 'contra', 'expense', 'credit_note', 'debit_note'
  final DateTime voucherDate;
  final String partyType; // 'customer', 'supplier', 'oem', 'staff', 'bank', 'other'
  final String partyName;
  final String partyPhone;
  final String paymentMode; // 'cash', 'bank_transfer', 'upi', 'cheque'
  final String? sourceAccountId;
  final String? destinationAccountId;
  final double amount;
  final double tdsDeducted;
  final String referenceNumber;
  final String bankName;
  final String narration;

  const VoucherFormState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.savedVoucher,
    this.availableAccounts = const [],
    this.showroomId = 'showroom-mumbai-main',
    this.voucherType = 'payment',
    required this.voucherDate,
    this.partyType = 'supplier',
    this.partyName = '',
    this.partyPhone = '',
    this.paymentMode = 'bank_transfer',
    this.sourceAccountId,
    this.destinationAccountId,
    this.amount = 0.0,
    this.tdsDeducted = 0.0,
    this.referenceNumber = '',
    this.bankName = '',
    this.narration = '',
  });

  double get netAmount => (amount - tdsDeducted) > 0 ? (amount - tdsDeducted) : 0.0;
  bool get isValid =>
      amount > 0 &&
      partyName.trim().isNotEmpty &&
      sourceAccountId != null &&
      destinationAccountId != null &&
      sourceAccountId != destinationAccountId &&
      narration.trim().isNotEmpty;

  VoucherFormState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    FinanceVoucherEntity? savedVoucher,
    List<AccountEntity>? availableAccounts,
    String? showroomId,
    String? voucherType,
    DateTime? voucherDate,
    String? partyType,
    String? partyName,
    String? partyPhone,
    String? paymentMode,
    String? sourceAccountId,
    String? destinationAccountId,
    double? amount,
    double? tdsDeducted,
    String? referenceNumber,
    String? bankName,
    String? narration,
  }) {
    return VoucherFormState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      savedVoucher: savedVoucher,
      availableAccounts: availableAccounts ?? this.availableAccounts,
      showroomId: showroomId ?? this.showroomId,
      voucherType: voucherType ?? this.voucherType,
      voucherDate: voucherDate ?? this.voucherDate,
      partyType: partyType ?? this.partyType,
      partyName: partyName ?? this.partyName,
      partyPhone: partyPhone ?? this.partyPhone,
      paymentMode: paymentMode ?? this.paymentMode,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      amount: amount ?? this.amount,
      tdsDeducted: tdsDeducted ?? this.tdsDeducted,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      bankName: bankName ?? this.bankName,
      narration: narration ?? this.narration,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        error,
        savedVoucher,
        availableAccounts,
        showroomId,
        voucherType,
        voucherDate,
        partyType,
        partyName,
        partyPhone,
        paymentMode,
        sourceAccountId,
        destinationAccountId,
        amount,
        tdsDeducted,
        referenceNumber,
        bankName,
        narration,
      ];
}
