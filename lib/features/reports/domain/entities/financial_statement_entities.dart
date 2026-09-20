import 'package:equatable/equatable.dart';

/// Single item in Trial Balance
class TrialBalanceItem extends Equatable {
  final String accountCode;
  final String accountName;
  final String accountType; // Asset, Liability, Equity, Revenue, Expense
  final double debitAmount;
  final double creditAmount;

  const TrialBalanceItem({
    required this.accountCode,
    required this.accountName,
    required this.accountType,
    required this.debitAmount,
    required this.creditAmount,
  });

  @override
  List<Object?> get props => [accountCode, accountName, accountType, debitAmount, creditAmount];
}

/// Trial Balance Report Entity
class TrialBalanceReport extends Equatable {
  final String showroomName;
  final String periodLabel;
  final DateTime asOfDate;
  final List<TrialBalanceItem> items;
  final double totalDebit;
  final double totalCredit;
  final double difference;

  const TrialBalanceReport({
    required this.showroomName,
    required this.periodLabel,
    required this.asOfDate,
    required this.items,
    required this.totalDebit,
    required this.totalCredit,
    required this.difference,
  });

  bool get isBalanced => (totalDebit - totalCredit).abs() < 0.01;

  @override
  List<Object?> get props => [showroomName, periodLabel, asOfDate, items, totalDebit, totalCredit, difference];
}

/// Financial line item in P&L or Balance Sheet
class StatementLineItem extends Equatable {
  final String code;
  final String title;
  final double amount;
  final String? note;
  final bool isHeader;
  final bool isSubtotal;

  const StatementLineItem({
    required this.code,
    required this.title,
    required this.amount,
    this.note,
    this.isHeader = false,
    this.isSubtotal = false,
  });

  @override
  List<Object?> get props => [code, title, amount, note, isHeader, isSubtotal];
}

/// Profit & Loss Statement (Income Statement)
class ProfitLossReport extends Equatable {
  final String showroomName;
  final String periodLabel;
  final DateTime startDate;
  final DateTime endDate;

  // Trading Account
  final double grossSalesRevenue;
  final double salesReturnsAndDiscounts;
  final double netSalesRevenue;
  final double openingStock;
  final double purchasesDirectCosts;
  final double closingStock;
  final double costOfGoodsSold;
  final double grossProfit;
  final double grossMarginPercent;

  // Indirect Income & Expenses
  final List<StatementLineItem> operatingExpenses;
  final double totalOperatingExpenses;
  final double operatingProfitEbitda;
  final List<StatementLineItem> otherIncomes;
  final double totalOtherIncomes;
  final double depreciationAndFinanceCost;
  final double netProfitBeforeTax;
  final double netProfitMarginPercent;

  const ProfitLossReport({
    required this.showroomName,
    required this.periodLabel,
    required this.startDate,
    required this.endDate,
    required this.grossSalesRevenue,
    required this.salesReturnsAndDiscounts,
    required this.netSalesRevenue,
    required this.openingStock,
    required this.purchasesDirectCosts,
    required this.closingStock,
    required this.costOfGoodsSold,
    required this.grossProfit,
    required this.grossMarginPercent,
    required this.operatingExpenses,
    required this.totalOperatingExpenses,
    required this.operatingProfitEbitda,
    required this.otherIncomes,
    required this.totalOtherIncomes,
    required this.depreciationAndFinanceCost,
    required this.netProfitBeforeTax,
    required this.netProfitMarginPercent,
  });

  @override
  List<Object?> get props => [
        showroomName,
        periodLabel,
        startDate,
        endDate,
        grossSalesRevenue,
        salesReturnsAndDiscounts,
        netSalesRevenue,
        openingStock,
        purchasesDirectCosts,
        closingStock,
        costOfGoodsSold,
        grossProfit,
        grossMarginPercent,
        operatingExpenses,
        totalOperatingExpenses,
        operatingProfitEbitda,
        otherIncomes,
        totalOtherIncomes,
        depreciationAndFinanceCost,
        netProfitBeforeTax,
        netProfitMarginPercent,
      ];
}

/// Balance Sheet Statement
class BalanceSheetReport extends Equatable {
  final String showroomName;
  final String periodLabel;
  final DateTime asOfDate;

  // Assets
  final List<StatementLineItem> nonCurrentAssets;
  final double totalNonCurrentAssets;
  final List<StatementLineItem> currentAssets;
  final double totalCurrentAssets;
  final double totalAssets;

  // Equity & Liabilities
  final List<StatementLineItem> equity;
  final double totalEquity;
  final List<StatementLineItem> nonCurrentLiabilities;
  final double totalNonCurrentLiabilities;
  final List<StatementLineItem> currentLiabilities;
  final double totalCurrentLiabilities;
  final double totalLiabilitiesAndEquity;

  const BalanceSheetReport({
    required this.showroomName,
    required this.periodLabel,
    required this.asOfDate,
    required this.nonCurrentAssets,
    required this.totalNonCurrentAssets,
    required this.currentAssets,
    required this.totalCurrentAssets,
    required this.totalAssets,
    required this.equity,
    required this.totalEquity,
    required this.nonCurrentLiabilities,
    required this.totalNonCurrentLiabilities,
    required this.currentLiabilities,
    required this.totalCurrentLiabilities,
    required this.totalLiabilitiesAndEquity,
  });

  bool get isBalanced => (totalAssets - totalLiabilitiesAndEquity).abs() < 1.0;

  @override
  List<Object?> get props => [
        showroomName,
        periodLabel,
        asOfDate,
        nonCurrentAssets,
        totalNonCurrentAssets,
        currentAssets,
        totalCurrentAssets,
        totalAssets,
        equity,
        totalEquity,
        nonCurrentLiabilities,
        totalNonCurrentLiabilities,
        currentLiabilities,
        totalCurrentLiabilities,
        totalLiabilitiesAndEquity,
      ];
}
