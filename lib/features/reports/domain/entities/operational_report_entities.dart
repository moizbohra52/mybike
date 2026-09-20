import 'package:equatable/equatable.dart';

/// Sales Register Row
class SalesRegisterRow extends Equatable {
  final String invoiceNo;
  final DateTime invoiceDate;
  final String customerName;
  final String modelName;
  final String vin;
  final String showroomName;
  final double taxableAmount;
  final double gstAmount;
  final double totalAmount;
  final String paymentStatus;

  const SalesRegisterRow({
    required this.invoiceNo,
    required this.invoiceDate,
    required this.customerName,
    required this.modelName,
    required this.vin,
    required this.showroomName,
    required this.taxableAmount,
    required this.gstAmount,
    required this.totalAmount,
    required this.paymentStatus,
  });

  @override
  List<Object?> get props => [
        invoiceNo,
        invoiceDate,
        customerName,
        modelName,
        vin,
        showroomName,
        taxableAmount,
        gstAmount,
        totalAmount,
        paymentStatus,
      ];
}

/// Sales Register Report
class SalesRegisterReport extends Equatable {
  final String showroomName;
  final DateTime startDate;
  final DateTime endDate;
  final List<SalesRegisterRow> rows;
  final double totalTaxable;
  final double totalGst;
  final double grandTotal;
  final int totalInvoicesCount;

  const SalesRegisterReport({
    required this.showroomName,
    required this.startDate,
    required this.endDate,
    required this.rows,
    required this.totalTaxable,
    required this.totalGst,
    required this.grandTotal,
    required this.totalInvoicesCount,
  });

  @override
  List<Object?> get props => [
        showroomName,
        startDate,
        endDate,
        rows,
        totalTaxable,
        totalGst,
        grandTotal,
        totalInvoicesCount,
      ];
}

/// Purchase Register Row
class PurchaseRegisterRow extends Equatable {
  final String poNumber;
  final DateTime orderDate;
  final String supplierName;
  final String brand;
  final int unitsCount;
  final double subtotal;
  final double gstAmount;
  final double netAmount;
  final String status;

  const PurchaseRegisterRow({
    required this.poNumber,
    required this.orderDate,
    required this.supplierName,
    required this.brand,
    required this.unitsCount,
    required this.subtotal,
    required this.gstAmount,
    required this.netAmount,
    required this.status,
  });

  @override
  List<Object?> get props => [
        poNumber,
        orderDate,
        supplierName,
        brand,
        unitsCount,
        subtotal,
        gstAmount,
        netAmount,
        status,
      ];
}

/// Purchase Register Report
class PurchaseRegisterReport extends Equatable {
  final String showroomName;
  final DateTime startDate;
  final DateTime endDate;
  final List<PurchaseRegisterRow> rows;
  final double totalSpend;
  final int totalUnits;

  const PurchaseRegisterReport({
    required this.showroomName,
    required this.startDate,
    required this.endDate,
    required this.rows,
    required this.totalSpend,
    required this.totalUnits,
  });

  @override
  List<Object?> get props => [showroomName, startDate, endDate, rows, totalSpend, totalUnits];
}

/// Stock Summary Row
class StockSummaryRow extends Equatable {
  final String modelName;
  final String variantName;
  final String powertrain; // Petrol, EV
  final String showroomName;
  final int inStockUnits;
  final int reservedUnits;
  final int transitUnits;
  final double unitCost;
  final double totalValuation;
  final int agingUnitsAbove60Days;

  const StockSummaryRow({
    required this.modelName,
    required this.variantName,
    required this.powertrain,
    required this.showroomName,
    required this.inStockUnits,
    required this.reservedUnits,
    required this.transitUnits,
    required this.unitCost,
    required this.totalValuation,
    required this.agingUnitsAbove60Days,
  });

  @override
  List<Object?> get props => [
        modelName,
        variantName,
        powertrain,
        showroomName,
        inStockUnits,
        reservedUnits,
        transitUnits,
        unitCost,
        totalValuation,
        agingUnitsAbove60Days,
      ];
}

/// Stock Summary Report
class StockSummaryReport extends Equatable {
  final String showroomName;
  final DateTime asOfDate;
  final List<StockSummaryRow> rows;
  final int totalUnits;
  final double totalStockValuation;
  final int totalAgingUnits;

  const StockSummaryReport({
    required this.showroomName,
    required this.asOfDate,
    required this.rows,
    required this.totalUnits,
    required this.totalStockValuation,
    required this.totalAgingUnits,
  });

  @override
  List<Object?> get props => [
        showroomName,
        asOfDate,
        rows,
        totalUnits,
        totalStockValuation,
        totalAgingUnits,
      ];
}

/// Operational Overhead / Expense Summary
class ExpenseCategoryRow extends Equatable {
  final String categoryName;
  final String accountCode;
  final double amount;
  final double percentage;
  final String notes;

  const ExpenseCategoryRow({
    required this.categoryName,
    required this.accountCode,
    required this.amount,
    required this.percentage,
    required this.notes,
  });

  @override
  List<Object?> get props => [categoryName, accountCode, amount, percentage, notes];
}

/// Expense Summary Report
class ExpenseSummaryReport extends Equatable {
  final String showroomName;
  final DateTime startDate;
  final DateTime endDate;
  final List<ExpenseCategoryRow> categories;
  final double grandTotalExpense;

  const ExpenseSummaryReport({
    required this.showroomName,
    required this.startDate,
    required this.endDate,
    required this.categories,
    required this.grandTotalExpense,
  });

  @override
  List<Object?> get props => [showroomName, startDate, endDate, categories, grandTotalExpense];
}

/// Income Summary Report
class IncomeSummaryReport extends Equatable {
  final String showroomName;
  final DateTime startDate;
  final DateTime endDate;
  final List<ExpenseCategoryRow> incomeCategories;
  final double grandTotalIncome;

  const IncomeSummaryReport({
    required this.showroomName,
    required this.startDate,
    required this.endDate,
    required this.incomeCategories,
    required this.grandTotalIncome,
  });

  @override
  List<Object?> get props => [showroomName, startDate, endDate, incomeCategories, grandTotalIncome];
}
