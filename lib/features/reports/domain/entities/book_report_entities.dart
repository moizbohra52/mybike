import 'package:equatable/equatable.dart';

/// Single transaction entry in Cash or Bank Book
class BookTransactionEntry extends Equatable {
  final String id;
  final DateTime date;
  final String voucherNo;
  final String voucherType;
  final String partyName;
  final String narration;
  final String paymentMode;
  final double debitAmount;
  final double creditAmount;
  final double runningBalance;

  const BookTransactionEntry({
    required this.id,
    required this.date,
    required this.voucherNo,
    required this.voucherType,
    required this.partyName,
    required this.narration,
    required this.paymentMode,
    required this.debitAmount,
    required this.creditAmount,
    required this.runningBalance,
  });

  @override
  List<Object?> get props => [
        id,
        date,
        voucherNo,
        voucherType,
        partyName,
        narration,
        paymentMode,
        debitAmount,
        creditAmount,
        runningBalance,
      ];
}

/// Cash Book Report
class CashBookReport extends Equatable {
  final String showroomName;
  final DateTime startDate;
  final DateTime endDate;
  final double openingBalance;
  final List<BookTransactionEntry> entries;
  final double totalDebitInflows;
  final double totalCreditOutflows;
  final double closingBalance;

  const CashBookReport({
    required this.showroomName,
    required this.startDate,
    required this.endDate,
    required this.openingBalance,
    required this.entries,
    required this.totalDebitInflows,
    required this.totalCreditOutflows,
    required this.closingBalance,
  });

  @override
  List<Object?> get props => [
        showroomName,
        startDate,
        endDate,
        openingBalance,
        entries,
        totalDebitInflows,
        totalCreditOutflows,
        closingBalance,
      ];
}

/// Bank Book Report
class BankBookReport extends Equatable {
  final String showroomName;
  final String bankAccountName;
  final String accountNumber;
  final DateTime startDate;
  final DateTime endDate;
  final double openingBalance;
  final List<BookTransactionEntry> entries;
  final double totalDebitDeposits;
  final double totalCreditWithdrawals;
  final double closingBalance;

  const BankBookReport({
    required this.showroomName,
    required this.bankAccountName,
    required this.accountNumber,
    required this.startDate,
    required this.endDate,
    required this.openingBalance,
    required this.entries,
    required this.totalDebitDeposits,
    required this.totalCreditWithdrawals,
    required this.closingBalance,
  });

  @override
  List<Object?> get props => [
        showroomName,
        bankAccountName,
        accountNumber,
        startDate,
        endDate,
        openingBalance,
        entries,
        totalDebitDeposits,
        totalCreditWithdrawals,
        closingBalance,
      ];
}

/// General Party/Account Ledger Report
class AccountLedgerReport extends Equatable {
  final String showroomName;
  final String accountCode;
  final String accountName;
  final String accountType;
  final DateTime startDate;
  final DateTime endDate;
  final double openingBalance;
  final List<BookTransactionEntry> entries;
  final double totalDebits;
  final double totalCredits;
  final double closingBalance;

  const AccountLedgerReport({
    required this.showroomName,
    required this.accountCode,
    required this.accountName,
    required this.accountType,
    required this.startDate,
    required this.endDate,
    required this.openingBalance,
    required this.entries,
    required this.totalDebits,
    required this.totalCredits,
    required this.closingBalance,
  });

  @override
  List<Object?> get props => [
        showroomName,
        accountCode,
        accountName,
        accountType,
        startDate,
        endDate,
        openingBalance,
        entries,
        totalDebits,
        totalCredits,
        closingBalance,
      ];
}
