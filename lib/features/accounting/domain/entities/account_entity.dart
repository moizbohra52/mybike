import 'package:equatable/equatable.dart';

/// Chart of Accounts (COA) Domain Entity
///
/// Represents an account in the double-entry bookkeeping system
/// of MYBIKE multi-showroom dealership.
class AccountEntity extends Equatable {
  final String id;
  final String? showroomId; // Null for corporate / multi-branch global accounts
  final String accountCode; // e.g. "1010", "1020", "2010", "4010"
  final String accountName;
  final String accountType; // 'asset', 'liability', 'equity', 'revenue', 'expense'
  final String subType; // 'cash', 'bank', 'accounts_receivable', 'inventory', 'accounts_payable', 'tax_payable', etc.
  final String? parentId;
  final double openingBalance;
  final double currentBalance;
  final String currency;
  final bool isActive;
  final bool isSystemAccount;
  final bool isReconciled;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Hydrated helper
  final String? showroomName;

  const AccountEntity({
    required this.id,
    this.showroomId,
    required this.accountCode,
    required this.accountName,
    required this.accountType,
    required this.subType,
    this.parentId,
    this.openingBalance = 0.0,
    this.currentBalance = 0.0,
    this.currency = 'INR',
    this.isActive = true,
    this.isSystemAccount = false,
    this.isReconciled = false,
    required this.createdAt,
    required this.updatedAt,
    this.showroomName,
  });

  bool get isAsset => accountType == 'asset';
  bool get isLiability => accountType == 'liability';
  bool get isEquity => accountType == 'equity';
  bool get isRevenue => accountType == 'revenue';
  bool get isExpense => accountType == 'expense';

  String get typeDisplayLabel {
    switch (accountType) {
      case 'asset':
        return 'Asset';
      case 'liability':
        return 'Liability';
      case 'equity':
        return 'Equity';
      case 'revenue':
        return 'Revenue';
      case 'expense':
        return 'Expense';
      default:
        return accountType.toUpperCase();
    }
  }

  String get formattedCodeAndName => '$accountCode - $accountName';

  AccountEntity copyWith({
    String? id,
    String? showroomId,
    String? accountCode,
    String? accountName,
    String? accountType,
    String? subType,
    String? parentId,
    double? openingBalance,
    double? currentBalance,
    String? currency,
    bool? isActive,
    bool? isSystemAccount,
    bool? isReconciled,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? showroomName,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      showroomId: showroomId ?? this.showroomId,
      accountCode: accountCode ?? this.accountCode,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
      subType: subType ?? this.subType,
      parentId: parentId ?? this.parentId,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      isSystemAccount: isSystemAccount ?? this.isSystemAccount,
      isReconciled: isReconciled ?? this.isReconciled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      showroomName: showroomName ?? this.showroomName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        showroomId,
        accountCode,
        accountName,
        accountType,
        subType,
        parentId,
        openingBalance,
        currentBalance,
        currency,
        isActive,
        isSystemAccount,
        isReconciled,
        createdAt,
        updatedAt,
      ];
}
