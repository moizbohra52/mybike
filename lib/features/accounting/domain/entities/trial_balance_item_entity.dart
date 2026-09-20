import 'package:equatable/equatable.dart';

/// Trial Balance Line Item Entity
///
/// Models a single row in the Trial Balance statement.
class TrialBalanceItemEntity extends Equatable {
  final String accountId;
  final String accountCode;
  final String accountName;
  final String accountType; // 'asset', 'liability', 'equity', 'revenue', 'expense'
  final double debitBalance;
  final double creditBalance;

  const TrialBalanceItemEntity({
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    required this.accountType,
    this.debitBalance = 0.0,
    this.creditBalance = 0.0,
  });

  bool get isDebit => debitBalance > 0;
  bool get isCredit => creditBalance > 0;

  @override
  List<Object?> get props => [
        accountId,
        accountCode,
        accountName,
        accountType,
        debitBalance,
        creditBalance,
      ];
}
