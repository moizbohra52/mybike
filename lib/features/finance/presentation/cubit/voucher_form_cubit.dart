import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/finance_management_service.dart';
import '../../../../core/services/accounting_management_service.dart';
import '../../domain/entities/finance_voucher_entity.dart';
import 'voucher_form_state.dart';

/// Voucher Form Cubit
class VoucherFormCubit extends Cubit<VoucherFormState> {
  final FinanceManagementService _service;
  final AccountingManagementService _accountingService;

  VoucherFormCubit({
    FinanceManagementService? service,
    AccountingManagementService? accountingService,
  })  : _service = service ?? FinanceManagementService.instance,
        _accountingService = accountingService ?? AccountingManagementService.instance,
        super(VoucherFormState(voucherDate: DateTime.now()));

  /// Initialize form and set smart defaults based on voucher type
  Future<void> init({
    String voucherType = 'payment',
    String? defaultShowroomId,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final accounts = await _accountingService.fetchAccounts(showroomId: defaultShowroomId);
      final shId = defaultShowroomId ?? state.showroomId;

      String? defaultSourceId;
      String? defaultDestId;
      String defaultPartyType = 'supplier';
      String defaultPaymentMode = 'bank_transfer';

      final bankAcct = accounts.cast().firstWhere((a) => a.accountCode == '1020', orElse: () => accounts.isNotEmpty ? accounts.first : null);
      final cashAcct = accounts.cast().firstWhere((a) => a.accountCode == '1010', orElse: () => accounts.isNotEmpty ? accounts.first : null);
      final creditorAcct = accounts.cast().firstWhere((a) => a.accountCode == '2010', orElse: () => accounts.isNotEmpty ? accounts.first : null);
      final debtorAcct = accounts.cast().firstWhere((a) => a.accountCode == '1030', orElse: () => accounts.isNotEmpty ? accounts.first : null);
      final advanceAcct = accounts.cast().firstWhere((a) => a.accountCode == '2030', orElse: () => accounts.isNotEmpty ? accounts.first : null);
      final utilityExpenseAcct = accounts.cast().firstWhere((a) => a.accountCode == '6030', orElse: () => accounts.isNotEmpty ? accounts.first : null);

      if (voucherType == 'payment') {
        defaultSourceId = bankAcct?.id;
        defaultDestId = creditorAcct?.id;
        defaultPartyType = 'supplier';
        defaultPaymentMode = 'bank_transfer';
      } else if (voucherType == 'receipt') {
        defaultSourceId = advanceAcct?.id ?? debtorAcct?.id;
        defaultDestId = bankAcct?.id;
        defaultPartyType = 'customer';
        defaultPaymentMode = 'upi';
      } else if (voucherType == 'contra') {
        defaultSourceId = cashAcct?.id;
        defaultDestId = bankAcct?.id;
        defaultPartyType = 'bank';
        defaultPaymentMode = 'cash';
      } else if (voucherType == 'expense') {
        defaultSourceId = cashAcct?.id;
        defaultDestId = utilityExpenseAcct?.id;
        defaultPartyType = 'other';
        defaultPaymentMode = 'cash';
      } else if (voucherType == 'credit_note') {
        defaultSourceId = debtorAcct?.id;
        defaultDestId = accounts.cast().firstWhere((a) => a.accountCode == '4020', orElse: () => accounts.isNotEmpty ? accounts.first : null)?.id;
        defaultPartyType = 'customer';
        defaultPaymentMode = 'clearing';
      } else if (voucherType == 'debit_note') {
        defaultSourceId = creditorAcct?.id;
        defaultDestId = accounts.cast().firstWhere((a) => a.accountCode == '1040', orElse: () => accounts.isNotEmpty ? accounts.first : null)?.id;
        defaultPartyType = 'supplier';
        defaultPaymentMode = 'clearing';
      }

      emit(state.copyWith(
        isLoading: false,
        availableAccounts: accounts,
        showroomId: shId,
        voucherType: voucherType,
        sourceAccountId: defaultSourceId,
        destinationAccountId: defaultDestId,
        partyType: defaultPartyType,
        paymentMode: defaultPaymentMode,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void updateField({
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
    emit(state.copyWith(
      voucherType: voucherType ?? state.voucherType,
      voucherDate: voucherDate ?? state.voucherDate,
      partyType: partyType ?? state.partyType,
      partyName: partyName ?? state.partyName,
      partyPhone: partyPhone ?? state.partyPhone,
      paymentMode: paymentMode ?? state.paymentMode,
      sourceAccountId: sourceAccountId ?? state.sourceAccountId,
      destinationAccountId: destinationAccountId ?? state.destinationAccountId,
      amount: amount ?? state.amount,
      tdsDeducted: tdsDeducted ?? state.tdsDeducted,
      referenceNumber: referenceNumber ?? state.referenceNumber,
      bankName: bankName ?? state.bankName,
      narration: narration ?? state.narration,
    ));
  }

  /// Submit voucher and auto-post to General Ledger
  Future<bool> submitVoucher({bool autoPostToGL = true}) async {
    if (!state.isValid) {
      emit(state.copyWith(
        error: 'Please fill in all mandatory fields: Amount, Party, Source Account, Destination Account, and Narration.',
      ));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      final voucher = FinanceVoucherEntity(
        id: '',
        showroomId: state.showroomId,
        voucherNumber: '',
        voucherType: state.voucherType,
        voucherDate: state.voucherDate,
        partyType: state.partyType,
        partyName: state.partyName.trim(),
        partyPhone: state.partyPhone.trim().isNotEmpty ? state.partyPhone.trim() : null,
        paymentMode: state.paymentMode,
        sourceAccountId: state.sourceAccountId,
        destinationAccountId: state.destinationAccountId,
        amount: state.amount,
        taxDeductedTds: state.tdsDeducted,
        netAmount: state.netAmount,
        referenceNumber: state.referenceNumber.trim().isNotEmpty ? state.referenceNumber.trim() : null,
        bankName: state.bankName.trim().isNotEmpty ? state.bankName.trim() : null,
        narration: state.narration.trim(),
        status: 'posted',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await _service.createVoucher(
        voucher,
        autoPostToGL: autoPostToGL,
      );

      emit(state.copyWith(
        isSubmitting: false,
        savedVoucher: saved,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
      return false;
    }
  }
}
