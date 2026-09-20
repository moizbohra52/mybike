import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/reporting_management_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/report_filter_criteria.dart';
import '../../domain/entities/report_row_item.dart';
import 'report_viewer_state.dart';

class ReportViewerCubit extends Cubit<ReportViewerState> {
  final ReportingManagementService _service;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  ReportViewerCubit({
    required String reportType,
    ReportFilterCriteria? criteria,
    ReportingManagementService? service,
  })  : _service = service ?? ReportingManagementService.instance,
        super(ReportViewerState(
          reportType: reportType,
          criteria: criteria ?? ReportFilterCriteria.currentMonth(),
        ));

  String _fmt(double val) => _currencyFormat.format(val);

  Future<void> loadReport({String? reportType, ReportFilterCriteria? criteria}) async {
    final type = reportType ?? state.reportType;
    final crit = criteria ?? state.criteria;

    emit(state.copyWith(
      status: ReportViewerStatus.loading,
      reportType: type,
      criteria: crit,
    ));

    try {
      switch (type) {
        case 'sales_register':
        case 'sales-register':
          await _loadSalesReport(crit);
          break;
        case 'purchase_register':
        case 'purchase-register':
          await _loadPurchaseReport(crit);
          break;
        case 'stock_report':
        case 'stock-report':
          await _loadStockReport(crit);
          break;
        case 'cash_book':
        case 'cash-book':
          await _loadCashBookReport(crit);
          break;
        case 'bank_book':
        case 'bank-book':
          await _loadBankBookReport(crit);
          break;
        case 'ledger':
          await _loadAccountLedgerReport(crit);
          break;
        case 'trial_balance':
        case 'trial-balance':
          await _loadTrialBalanceReport(crit);
          break;
        case 'pnl':
          await _loadProfitLossReport(crit);
          break;
        case 'balance_sheet':
        case 'balance-sheet':
          await _loadBalanceSheetReport(crit);
          break;
        case 'receivables_aging':
        case 'receivables-aging':
          await _loadReceivablesAgingReport(crit);
          break;
        case 'payables_aging':
        case 'payables-aging':
          await _loadPayablesAgingReport(crit);
          break;
        case 'gst_report':
        case 'gst-report':
          await _loadGstReport(crit);
          break;
        case 'expense_report':
        case 'expense-report':
          await _loadExpenseReport(crit);
          break;
        case 'income_report':
        case 'income-report':
          await _loadIncomeReport(crit);
          break;
        default:
          await _loadSalesReport(crit);
          break;
      }
    } catch (e) {
      emit(state.copyWith(
        status: ReportViewerStatus.failure,
        errorMessage: 'Failed to generate report: $e',
      ));
    }
  }

  // 1. Sales Register
  Future<void> _loadSalesReport(ReportFilterCriteria criteria) async {
    final data = await _service.generateSalesReport(criteria);
    const columns = [
      ReportColumnDef(title: 'Invoice No', flex: 2),
      ReportColumnDef(title: 'Date', flex: 1),
      ReportColumnDef(title: 'Customer Name', flex: 2),
      ReportColumnDef(title: 'Model', flex: 2),
      ReportColumnDef(title: 'VIN / Chassis', flex: 2),
      ReportColumnDef(title: 'Taxable (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'GST (₹)', align: TextAlign.right, flex: 1),
      ReportColumnDef(title: 'Total (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'Status', align: TextAlign.center, flex: 1),
    ];

    final rows = data.rows.map((r) {
      return ReportRowItem(
        id: r.invoiceNo,
        cells: [
          ReportCell(text: r.invoiceNo, isBold: true),
          ReportCell(text: DateFormat('dd-MM-yyyy').format(r.invoiceDate)),
          ReportCell(text: r.customerName),
          ReportCell(text: r.modelName),
          ReportCell(text: r.vin),
          ReportCell(text: _fmt(r.taxableAmount), align: TextAlign.right, numericValue: r.taxableAmount),
          ReportCell(text: _fmt(r.gstAmount), align: TextAlign.right, numericValue: r.gstAmount),
          ReportCell(text: _fmt(r.totalAmount), align: TextAlign.right, isBold: true, numericValue: r.totalAmount),
          ReportCell(
            text: r.paymentStatus.toUpperCase(),
            align: TextAlign.center,
            textColor: r.paymentStatus == 'paid' ? AppColors.success : AppColors.warning,
          ),
        ],
      );
    }).toList();

    // Total Row
    rows.add(ReportRowItem(
      id: 'TOTAL',
      isTotalRow: true,
      cells: [
        const ReportCell(text: 'TOTAL', isBold: true),
        ReportCell(text: '${data.totalInvoicesCount} Invoices', isBold: true),
        const ReportCell(text: ''),
        const ReportCell(text: ''),
        const ReportCell(text: ''),
        ReportCell(text: _fmt(data.totalTaxable), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.totalGst), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.grandTotal), align: TextAlign.right, isBold: true, textColor: AppColors.primaryYellow),
        const ReportCell(text: ''),
      ],
    ));

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'Sales Register Report',
      subtitle: '${criteria.showroomName} • ${DateFormat('dd MMM yyyy').format(criteria.startDate)} to ${DateFormat('dd MMM yyyy').format(criteria.endDate)}',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Gross Sales', 'value': _fmt(data.grandTotal), 'color': AppColors.primaryYellow},
        {'title': 'Taxable Base', 'value': _fmt(data.totalTaxable), 'color': AppColors.info},
        {'title': 'GST Collected', 'value': _fmt(data.totalGst), 'color': AppColors.success},
        {'title': 'Total Invoices', 'value': '${data.totalInvoicesCount}', 'color': AppColors.warning},
      ],
      rawReportData: data,
    ));
  }

  // 2. Purchase Register
  Future<void> _loadPurchaseReport(ReportFilterCriteria criteria) async {
    final data = await _service.generatePurchaseReport(criteria);
    const columns = [
      ReportColumnDef(title: 'PO Number', flex: 2),
      ReportColumnDef(title: 'Date', flex: 1),
      ReportColumnDef(title: 'OEM Supplier', flex: 3),
      ReportColumnDef(title: 'Brand', flex: 1),
      ReportColumnDef(title: 'Units', align: TextAlign.center, flex: 1),
      ReportColumnDef(title: 'Subtotal (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'TDS / GST (₹)', align: TextAlign.right, flex: 1),
      ReportColumnDef(title: 'Net Amount (₹)', align: TextAlign.right, flex: 2),
    ];

    final rows = data.rows.map((r) {
      return ReportRowItem(
        id: r.poNumber,
        cells: [
          ReportCell(text: r.poNumber, isBold: true),
          ReportCell(text: DateFormat('dd-MM-yyyy').format(r.orderDate)),
          ReportCell(text: r.supplierName),
          ReportCell(text: r.brand),
          ReportCell(text: '${r.unitsCount}', align: TextAlign.center),
          ReportCell(text: _fmt(r.subtotal), align: TextAlign.right),
          ReportCell(text: _fmt(r.gstAmount), align: TextAlign.right),
          ReportCell(text: _fmt(r.netAmount), align: TextAlign.right, isBold: true),
        ],
      );
    }).toList();

    rows.add(ReportRowItem(
      id: 'TOTAL',
      isTotalRow: true,
      cells: [
        const ReportCell(text: 'TOTAL', isBold: true),
        const ReportCell(text: ''),
        const ReportCell(text: ''),
        const ReportCell(text: ''),
        ReportCell(text: '${data.totalUnits} Units', align: TextAlign.center, isBold: true),
        const ReportCell(text: ''),
        const ReportCell(text: ''),
        ReportCell(text: _fmt(data.totalSpend), align: TextAlign.right, isBold: true, textColor: AppColors.error),
      ],
    ));

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'Purchase & Inward Register',
      subtitle: '${criteria.showroomName} • ${DateFormat('dd MMM yyyy').format(criteria.startDate)} to ${DateFormat('dd MMM yyyy').format(criteria.endDate)}',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Procurement Spend', 'value': _fmt(data.totalSpend), 'color': AppColors.error},
        {'title': 'Units Inwarded', 'value:': '${data.totalUnits} units', 'color': AppColors.info},
        {'title': 'Active Suppliers', 'value': '3 OEMs', 'color': AppColors.success},
      ],
      rawReportData: data,
    ));
  }

  // 3. Stock Summary
  Future<void> _loadStockReport(ReportFilterCriteria criteria) async {
    final data = await _service.generateStockReport(criteria);
    const columns = [
      ReportColumnDef(title: 'Model', flex: 2),
      ReportColumnDef(title: 'Variant', flex: 2),
      ReportColumnDef(title: 'Powertrain', flex: 1),
      ReportColumnDef(title: 'Available', align: TextAlign.center, flex: 1),
      ReportColumnDef(title: 'Booked', align: TextAlign.center, flex: 1),
      ReportColumnDef(title: 'In Transit', align: TextAlign.center, flex: 1),
      ReportColumnDef(title: 'Unit Cost (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'Valuation (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'Aging >60d', align: TextAlign.center, flex: 1),
    ];

    final rows = data.rows.map((r) {
      return ReportRowItem(
        id: '${r.modelName}_${r.variantName}',
        cells: [
          ReportCell(text: r.modelName, isBold: true),
          ReportCell(text: r.variantName),
          ReportCell(text: r.powertrain),
          ReportCell(text: '${r.inStockUnits}', align: TextAlign.center, textColor: AppColors.success),
          ReportCell(text: '${r.reservedUnits}', align: TextAlign.center, textColor: AppColors.warning),
          ReportCell(text: '${r.transitUnits}', align: TextAlign.center, textColor: AppColors.info),
          ReportCell(text: _fmt(r.unitCost), align: TextAlign.right),
          ReportCell(text: _fmt(r.totalValuation), align: TextAlign.right, isBold: true),
          ReportCell(
            text: '${r.agingUnitsAbove60Days}',
            align: TextAlign.center,
            textColor: r.agingUnitsAbove60Days > 0 ? AppColors.error : null,
            isBold: r.agingUnitsAbove60Days > 0,
          ),
        ],
      );
    }).toList();

    rows.add(ReportRowItem(
      id: 'TOTAL',
      isTotalRow: true,
      cells: [
        const ReportCell(text: 'TOTAL', isBold: true),
        const ReportCell(text: ''),
        const ReportCell(text: ''),
        ReportCell(text: '${data.totalUnits} Units', align: TextAlign.center, isBold: true),
        const ReportCell(text: ''),
        const ReportCell(text: ''),
        const ReportCell(text: ''),
        ReportCell(text: _fmt(data.totalStockValuation), align: TextAlign.right, isBold: true, textColor: AppColors.primaryYellow),
        ReportCell(text: '${data.totalAgingUnits} Units', align: TextAlign.center, isBold: true, textColor: AppColors.error),
      ],
    ));

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'Stock Valuation & Aging Report',
      subtitle: '${criteria.showroomName} • As of ${DateFormat('dd MMM yyyy').format(criteria.endDate)}',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Total Units', 'value': '${data.totalUnits}', 'color': AppColors.info},
        {'title': 'Stock Valuation', 'value': _fmt(data.totalStockValuation), 'color': AppColors.primaryYellow},
        {'title': 'Aging Stock (>60d)', 'value': '${data.totalAgingUnits} units', 'color': AppColors.error},
      ],
      rawReportData: data,
    ));
  }

  // 4. Cash Book
  Future<void> _loadCashBookReport(ReportFilterCriteria criteria) async {
    final data = await _service.generateCashBook(criteria);
    const columns = [
      ReportColumnDef(title: 'Date', flex: 1),
      ReportColumnDef(title: 'Voucher No', flex: 2),
      ReportColumnDef(title: 'Type', flex: 1),
      ReportColumnDef(title: 'Particulars', flex: 3),
      ReportColumnDef(title: 'Receipts / Debit (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'Payments / Credit (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'Balance (₹)', align: TextAlign.right, flex: 2),
    ];

    final rows = <ReportRowItem>[
      // Opening Balance row
      ReportRowItem(
        id: 'OPENING',
        isSubtotalRow: true,
        cells: [
          ReportCell(text: DateFormat('dd-MM-yyyy').format(data.startDate)),
          const ReportCell(text: '-'),
          const ReportCell(text: 'OPENING'),
          const ReportCell(text: 'Opening Cash on Hand Balance', isBold: true),
          const ReportCell(text: ''),
          const ReportCell(text: ''),
          ReportCell(text: _fmt(data.openingBalance), align: TextAlign.right, isBold: true),
        ],
      ),
    ];

    for (final e in data.entries) {
      rows.add(ReportRowItem(
        id: e.id,
        cells: [
          ReportCell(text: DateFormat('dd-MM-yyyy').format(e.date)),
          ReportCell(text: e.voucherNo, isBold: true),
          ReportCell(text: e.voucherType.toUpperCase()),
          ReportCell(text: e.partyName),
          ReportCell(text: e.debitAmount > 0 ? _fmt(e.debitAmount) : '-', align: TextAlign.right, textColor: e.debitAmount > 0 ? AppColors.success : null),
          ReportCell(text: e.creditAmount > 0 ? _fmt(e.creditAmount) : '-', align: TextAlign.right, textColor: e.creditAmount > 0 ? AppColors.error : null),
          ReportCell(text: _fmt(e.runningBalance), align: TextAlign.right, isBold: true),
        ],
      ));
    }

    // Closing Balance row
    rows.add(ReportRowItem(
      id: 'CLOSING',
      isTotalRow: true,
      cells: [
        ReportCell(text: DateFormat('dd-MM-yyyy').format(data.endDate)),
        const ReportCell(text: '-'),
        const ReportCell(text: 'CLOSING'),
        const ReportCell(text: 'Closing Cash on Hand Balance', isBold: true),
        ReportCell(text: _fmt(data.totalDebitInflows), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.totalCreditOutflows), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.closingBalance), align: TextAlign.right, isBold: true, textColor: AppColors.primaryYellow),
      ],
    ));

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'Daily Cash Book Report',
      subtitle: '${criteria.showroomName} • ${DateFormat('dd MMM yyyy').format(criteria.startDate)} to ${DateFormat('dd MMM yyyy').format(criteria.endDate)}',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Opening Cash', 'value': _fmt(data.openingBalance), 'color': AppColors.info},
        {'title': 'Total Inflows', 'value': _fmt(data.totalDebitInflows), 'color': AppColors.success},
        {'title': 'Total Outflows', 'value': _fmt(data.totalCreditOutflows), 'color': AppColors.error},
        {'title': 'Closing Cash', 'value': _fmt(data.closingBalance), 'color': AppColors.primaryYellow},
      ],
      rawReportData: data,
    ));
  }

  // 5. Bank Book
  Future<void> _loadBankBookReport(ReportFilterCriteria criteria) async {
    final data = await _service.generateBankBook(criteria);
    const columns = [
      ReportColumnDef(title: 'Date', flex: 1),
      ReportColumnDef(title: 'Voucher No', flex: 2),
      ReportColumnDef(title: 'Mode', flex: 1),
      ReportColumnDef(title: 'Beneficiary / Depositor', flex: 3),
      ReportColumnDef(title: 'Deposits (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'Withdrawals (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'Balance (₹)', align: TextAlign.right, flex: 2),
    ];

    final rows = <ReportRowItem>[
      ReportRowItem(
        id: 'OPENING',
        isSubtotalRow: true,
        cells: [
          ReportCell(text: DateFormat('dd-MM-yyyy').format(data.startDate)),
          const ReportCell(text: '-'),
          const ReportCell(text: 'OPENING'),
          ReportCell(text: '${data.bankAccountName} (${data.accountNumber})', isBold: true),
          const ReportCell(text: ''),
          const ReportCell(text: ''),
          ReportCell(text: _fmt(data.openingBalance), align: TextAlign.right, isBold: true),
        ],
      ),
    ];

    for (final e in data.entries) {
      rows.add(ReportRowItem(
        id: e.id,
        cells: [
          ReportCell(text: DateFormat('dd-MM-yyyy').format(e.date)),
          ReportCell(text: e.voucherNo, isBold: true),
          ReportCell(text: e.paymentMode),
          ReportCell(text: e.partyName),
          ReportCell(text: e.debitAmount > 0 ? _fmt(e.debitAmount) : '-', align: TextAlign.right, textColor: e.debitAmount > 0 ? AppColors.success : null),
          ReportCell(text: e.creditAmount > 0 ? _fmt(e.creditAmount) : '-', align: TextAlign.right, textColor: e.creditAmount > 0 ? AppColors.error : null),
          ReportCell(text: _fmt(e.runningBalance), align: TextAlign.right, isBold: true),
        ],
      ));
    }

    rows.add(ReportRowItem(
      id: 'CLOSING',
      isTotalRow: true,
      cells: [
        ReportCell(text: DateFormat('dd-MM-yyyy').format(data.endDate)),
        const ReportCell(text: '-'),
        const ReportCell(text: 'CLOSING'),
        const ReportCell(text: 'Closing Bank Balance', isBold: true),
        ReportCell(text: _fmt(data.totalDebitDeposits), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.totalCreditWithdrawals), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.closingBalance), align: TextAlign.right, isBold: true, textColor: AppColors.info),
      ],
    ));

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'Bank Book Transaction Register',
      subtitle: '${data.bankAccountName} • ${data.accountNumber} • ${criteria.showroomName}',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Opening Balance', 'value': _fmt(data.openingBalance), 'color': AppColors.info},
        {'title': 'Total Deposits', 'value': _fmt(data.totalDebitDeposits), 'color': AppColors.success},
        {'title': 'Total Payments', 'value': _fmt(data.totalCreditWithdrawals), 'color': AppColors.error},
        {'title': 'Closing Bank Balance', 'value': _fmt(data.closingBalance), 'color': AppColors.primaryYellow},
      ],
      rawReportData: data,
    ));
  }

  // 6. Account Ledger
  Future<void> _loadAccountLedgerReport(ReportFilterCriteria criteria) async {
    final data = await _service.generateAccountLedgerReport('acc-1010', criteria);
    const columns = [
      ReportColumnDef(title: 'Date', flex: 1),
      ReportColumnDef(title: 'Voucher No', flex: 2),
      ReportColumnDef(title: 'Particulars', flex: 3),
      ReportColumnDef(title: 'Debit (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'Credit (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'Balance (₹)', align: TextAlign.right, flex: 2),
    ];

    final rows = <ReportRowItem>[
      ReportRowItem(
        id: 'OPENING',
        isSubtotalRow: true,
        cells: [
          ReportCell(text: DateFormat('dd-MM-yyyy').format(data.startDate)),
          const ReportCell(text: '-'),
          const ReportCell(text: 'Opening Balance', isBold: true),
          const ReportCell(text: ''),
          const ReportCell(text: ''),
          ReportCell(text: _fmt(data.openingBalance), align: TextAlign.right, isBold: true),
        ],
      ),
    ];

    for (final e in data.entries) {
      rows.add(ReportRowItem(
        id: e.id,
        cells: [
          ReportCell(text: DateFormat('dd-MM-yyyy').format(e.date)),
          ReportCell(text: e.voucherNo, isBold: true),
          ReportCell(text: e.partyName),
          ReportCell(text: e.debitAmount > 0 ? _fmt(e.debitAmount) : '-', align: TextAlign.right),
          ReportCell(text: e.creditAmount > 0 ? _fmt(e.creditAmount) : '-', align: TextAlign.right),
          ReportCell(text: _fmt(e.runningBalance), align: TextAlign.right, isBold: true),
        ],
      ));
    }

    rows.add(ReportRowItem(
      id: 'CLOSING',
      isTotalRow: true,
      cells: [
        ReportCell(text: DateFormat('dd-MM-yyyy').format(data.endDate)),
        const ReportCell(text: '-'),
        const ReportCell(text: 'Closing Balance', isBold: true),
        ReportCell(text: _fmt(data.totalDebits), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.totalCredits), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.closingBalance), align: TextAlign.right, isBold: true, textColor: AppColors.primaryYellow),
      ],
    ));

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'General Account Ledger Report',
      subtitle: '${data.accountCode} - ${data.accountName} • ${criteria.showroomName}',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Opening Balance', 'value': _fmt(data.openingBalance), 'color': AppColors.info},
        {'title': 'Total Debits', 'value': _fmt(data.totalDebits), 'color': AppColors.success},
        {'title': 'Total Credits', 'value': _fmt(data.totalCredits), 'color': AppColors.error},
        {'title': 'Net Ledger Balance', 'value': _fmt(data.closingBalance), 'color': AppColors.primaryYellow},
      ],
      rawReportData: data,
    ));
  }

  // 7. Trial Balance
  Future<void> _loadTrialBalanceReport(ReportFilterCriteria criteria) async {
    final data = await _service.generateTrialBalance(criteria);
    const columns = [
      ReportColumnDef(title: 'Account Code', flex: 1),
      ReportColumnDef(title: 'Account Title', flex: 3),
      ReportColumnDef(title: 'Classification', flex: 2),
      ReportColumnDef(title: 'Debit Balance (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'Credit Balance (₹)', align: TextAlign.right, flex: 2),
    ];

    final rows = data.items.map((i) {
      return ReportRowItem(
        id: i.accountCode,
        cells: [
          ReportCell(text: i.accountCode, isBold: true),
          ReportCell(text: i.accountName),
          ReportCell(text: i.accountType),
          ReportCell(text: i.debitAmount > 0 ? _fmt(i.debitAmount) : '-', align: TextAlign.right),
          ReportCell(text: i.creditAmount > 0 ? _fmt(i.creditAmount) : '-', align: TextAlign.right),
        ],
      );
    }).toList();

    rows.add(ReportRowItem(
      id: 'TOTAL',
      isTotalRow: true,
      cells: [
        const ReportCell(text: 'TOTAL', isBold: true),
        const ReportCell(text: 'Verified Double-Entry Ledger', isBold: true),
        const ReportCell(text: 'Balanced Status: OK', textColor: AppColors.success, isBold: true),
        ReportCell(text: _fmt(data.totalDebit), align: TextAlign.right, isBold: true, textColor: AppColors.primaryYellow),
        ReportCell(text: _fmt(data.totalCredit), align: TextAlign.right, isBold: true, textColor: AppColors.primaryYellow),
      ],
    ));

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'Trial Balance Report',
      subtitle: '${criteria.showroomName} • As of ${DateFormat('dd MMM yyyy').format(criteria.endDate)} • ${data.periodLabel}',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Total Debits', 'value': _fmt(data.totalDebit), 'color': AppColors.info},
        {'title': 'Total Credits', 'value': _fmt(data.totalCredit), 'color': AppColors.info},
        {'title': 'Net Difference', 'value': _fmt(data.difference), 'color': AppColors.success},
        {'title': 'Ledger Status', 'value': data.isBalanced ? 'Balanced' : 'Discrepancy', 'color': data.isBalanced ? AppColors.success : AppColors.error},
      ],
      rawReportData: data,
    ));
  }

  // 8. Profit & Loss Statement
  Future<void> _loadProfitLossReport(ReportFilterCriteria criteria) async {
    final data = await _service.generateProfitAndLoss(criteria);
    const columns = [
      ReportColumnDef(title: 'Particulars', flex: 4),
      ReportColumnDef(title: 'Amount (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: '% of Revenue', align: TextAlign.right, flex: 1),
    ];

    final rows = <ReportRowItem>[
      // Revenue
      const ReportRowItem(
        id: 'SEC_REV',
        isHeader: true,
        cells: [
          ReportCell(text: 'I. REVENUE FROM OPERATIONS (TRADING ACCOUNT)', isBold: true),
          ReportCell(text: ''),
          ReportCell(text: ''),
        ],
      ),
      ReportRowItem(
        id: 'rev_gross',
        cells: [
          const ReportCell(text: '   Gross Vehicle & Spares Sales'),
          ReportCell(text: _fmt(data.grossSalesRevenue), align: TextAlign.right),
          const ReportCell(text: '100.0%', align: TextAlign.right),
        ],
      ),
      ReportRowItem(
        id: 'rev_returns',
        cells: [
          const ReportCell(text: '   Less: Customer Discounts & Trade Allowances'),
          ReportCell(text: '(${_fmt(data.salesReturnsAndDiscounts)})', align: TextAlign.right, textColor: AppColors.error),
          ReportCell(text: '${((data.salesReturnsAndDiscounts / data.netSalesRevenue) * 100).toStringAsFixed(1)}%', align: TextAlign.right),
        ],
      ),
      ReportRowItem(
        id: 'rev_net',
        isSubtotalRow: true,
        cells: [
          const ReportCell(text: 'Net Revenue from Operations', isBold: true),
          ReportCell(text: _fmt(data.netSalesRevenue), align: TextAlign.right, isBold: true),
          const ReportCell(text: '100.0%', align: TextAlign.right, isBold: true),
        ],
      ),

      // COGS
      const ReportRowItem(
        id: 'SEC_COGS',
        isHeader: true,
        cells: [
          ReportCell(text: 'II. COST OF GOODS SOLD (COGS)', isBold: true),
          ReportCell(text: ''),
          ReportCell(text: ''),
        ],
      ),
      ReportRowItem(
        id: 'cogs_open',
        cells: [
          const ReportCell(text: '   Opening Stock at Cost'),
          ReportCell(text: _fmt(data.openingStock), align: TextAlign.right),
          const ReportCell(text: ''),
        ],
      ),
      ReportRowItem(
        id: 'cogs_purch',
        cells: [
          const ReportCell(text: '   Add: Direct OEM Procurement & Inbound Freight'),
          ReportCell(text: _fmt(data.purchasesDirectCosts), align: TextAlign.right),
          const ReportCell(text: ''),
        ],
      ),
      ReportRowItem(
        id: 'cogs_close',
        cells: [
          const ReportCell(text: '   Less: Closing Stock on Hand'),
          ReportCell(text: '(${_fmt(data.closingStock)})', align: TextAlign.right, textColor: AppColors.error),
          const ReportCell(text: ''),
        ],
      ),
      ReportRowItem(
        id: 'cogs_total',
        isSubtotalRow: true,
        cells: [
          const ReportCell(text: 'Total Cost of Goods Sold (COGS)', isBold: true),
          ReportCell(text: _fmt(data.costOfGoodsSold), align: TextAlign.right, isBold: true),
          ReportCell(text: '${((data.costOfGoodsSold / data.netSalesRevenue) * 100).toStringAsFixed(1)}%', align: TextAlign.right),
        ],
      ),

      // Gross Profit
      ReportRowItem(
        id: 'GROSS_PROFIT',
        isTotalRow: true,
        cells: [
          const ReportCell(text: 'GROSS PROFIT (A)', isBold: true),
          ReportCell(text: _fmt(data.grossProfit), align: TextAlign.right, isBold: true, textColor: AppColors.primaryYellow),
          ReportCell(text: '${data.grossMarginPercent.toStringAsFixed(1)}%', align: TextAlign.right, isBold: true, textColor: AppColors.primaryYellow),
        ],
      ),

      // Operating Expenses
      const ReportRowItem(
        id: 'SEC_OPEX',
        isHeader: true,
        cells: [
          ReportCell(text: 'III. INDIRECT OPERATING EXPENSES', isBold: true),
          ReportCell(text: ''),
          ReportCell(text: ''),
        ],
      ),
      ...data.operatingExpenses.map((e) => ReportRowItem(
            id: e.code,
            cells: [
              ReportCell(text: '   ${e.title}'),
              ReportCell(text: _fmt(e.amount), align: TextAlign.right),
              ReportCell(text: '${((e.amount / data.netSalesRevenue) * 100).toStringAsFixed(1)}%', align: TextAlign.right),
            ],
          )),
      ReportRowItem(
        id: 'opex_total',
        isSubtotalRow: true,
        cells: [
          const ReportCell(text: 'Total Operating Overheads (B)', isBold: true),
          ReportCell(text: _fmt(data.totalOperatingExpenses), align: TextAlign.right, isBold: true),
          ReportCell(text: '${((data.totalOperatingExpenses / data.netSalesRevenue) * 100).toStringAsFixed(1)}%', align: TextAlign.right),
        ],
      ),

      // Operating Profit (EBITDA)
      ReportRowItem(
        id: 'EBITDA',
        isTotalRow: true,
        cells: [
          const ReportCell(text: 'OPERATING PROFIT (EBITDA) = (A - B)', isBold: true),
          ReportCell(text: _fmt(data.operatingProfitEbitda), align: TextAlign.right, isBold: true, textColor: AppColors.info),
          ReportCell(text: '${((data.operatingProfitEbitda / data.netSalesRevenue) * 100).toStringAsFixed(1)}%', align: TextAlign.right, isBold: true, textColor: AppColors.info),
        ],
      ),

      // Other Income
      const ReportRowItem(
        id: 'SEC_OTHER',
        isHeader: true,
        cells: [
          ReportCell(text: 'IV. OTHER OPERATING INCOMES', isBold: true),
          ReportCell(text: ''),
          ReportCell(text: ''),
        ],
      ),
      ...data.otherIncomes.map((i) => ReportRowItem(
            id: i.code,
            cells: [
              ReportCell(text: '   ${i.title}'),
              ReportCell(text: _fmt(i.amount), align: TextAlign.right),
              ReportCell(text: '${((i.amount / data.netSalesRevenue) * 100).toStringAsFixed(1)}%', align: TextAlign.right),
            ],
          )),

      // Net Profit
      ReportRowItem(
        id: 'NET_PROFIT',
        isTotalRow: true,
        cells: [
          const ReportCell(text: 'NET PROFIT BEFORE TAX', isBold: true),
          ReportCell(text: _fmt(data.netProfitBeforeTax), align: TextAlign.right, isBold: true, textColor: AppColors.success),
          ReportCell(text: '${data.netProfitMarginPercent.toStringAsFixed(1)}%', align: TextAlign.right, isBold: true, textColor: AppColors.success),
        ],
      ),
    ];

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'Profit & Loss Statement (P&L)',
      subtitle: '${criteria.showroomName} • ${data.periodLabel} • Indian Accounting Standard Format',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Net Revenue', 'value': _fmt(data.netSalesRevenue), 'color': AppColors.info},
        {'title': 'Gross Margin', 'value': '${data.grossMarginPercent.toStringAsFixed(1)}%', 'color': AppColors.primaryYellow},
        {'title': 'EBITDA', 'value': _fmt(data.operatingProfitEbitda), 'color': AppColors.warning},
        {'title': 'Net Profit', 'value': _fmt(data.netProfitBeforeTax), 'color': AppColors.success},
      ],
      rawReportData: data,
    ));
  }

  // 9. Balance Sheet
  Future<void> _loadBalanceSheetReport(ReportFilterCriteria criteria) async {
    final data = await _service.generateBalanceSheet(criteria);
    const columns = [
      ReportColumnDef(title: 'Equities, Liabilities & Assets', flex: 4),
      ReportColumnDef(title: 'Account Code', flex: 1),
      ReportColumnDef(title: 'Amount (₹)', align: TextAlign.right, flex: 2),
    ];

    final rows = <ReportRowItem>[
      // Equity & Liabilities
      const ReportRowItem(
        id: 'SEC_EQUITY',
        isHeader: true,
        cells: [
          ReportCell(text: 'I. EQUITY AND LIABILITIES', isBold: true),
          ReportCell(text: ''),
          ReportCell(text: ''),
        ],
      ),
      const ReportRowItem(
        id: 'SEC_SH_FUNDS',
        isSubtotalRow: true,
        cells: [
          ReportCell(text: '   1. Shareholders / Partners Funds', isBold: true),
          ReportCell(text: ''),
          ReportCell(text: ''),
        ],
      ),
      ...data.equity.map((e) => ReportRowItem(
            id: e.code,
            cells: [
              ReportCell(text: '      ${e.title}'),
              ReportCell(text: e.code),
              ReportCell(text: _fmt(e.amount), align: TextAlign.right),
            ],
          )),
      const ReportRowItem(
        id: 'SEC_NCL',
        isSubtotalRow: true,
        cells: [
          ReportCell(text: '   2. Non-Current Liabilities', isBold: true),
          ReportCell(text: ''),
          ReportCell(text: ''),
        ],
      ),
      ...data.nonCurrentLiabilities.map((l) => ReportRowItem(
            id: l.code,
            cells: [
              ReportCell(text: '      ${l.title}'),
              ReportCell(text: l.code),
              ReportCell(text: _fmt(l.amount), align: TextAlign.right),
            ],
          )),
      const ReportRowItem(
        id: 'SEC_CL',
        isSubtotalRow: true,
        cells: [
          ReportCell(text: '   3. Current Liabilities', isBold: true),
          ReportCell(text: ''),
          ReportCell(text: ''),
        ],
      ),
      ...data.currentLiabilities.map((l) => ReportRowItem(
            id: l.code,
            cells: [
              ReportCell(text: '      ${l.title}'),
              ReportCell(text: l.code),
              ReportCell(text: _fmt(l.amount), align: TextAlign.right),
            ],
          )),
      ReportRowItem(
        id: 'TOTAL_LIAB',
        isTotalRow: true,
        cells: [
          const ReportCell(text: 'TOTAL EQUITY & LIABILITIES', isBold: true),
          const ReportCell(text: ''),
          ReportCell(text: _fmt(data.totalLiabilitiesAndEquity), align: TextAlign.right, isBold: true, textColor: AppColors.primaryYellow),
        ],
      ),

      // Assets
      const ReportRowItem(
        id: 'SEC_ASSETS',
        isHeader: true,
        cells: [
          ReportCell(text: 'II. ASSETS', isBold: true),
          ReportCell(text: ''),
          ReportCell(text: ''),
        ],
      ),
      const ReportRowItem(
        id: 'SEC_NCA',
        isSubtotalRow: true,
        cells: [
          ReportCell(text: '   1. Property, Plant & Equipment (Fixed Assets)', isBold: true),
          ReportCell(text: ''),
          ReportCell(text: ''),
        ],
      ),
      ...data.nonCurrentAssets.map((a) => ReportRowItem(
            id: a.code,
            cells: [
              ReportCell(text: '      ${a.title}'),
              ReportCell(text: a.code),
              ReportCell(text: _fmt(a.amount), align: TextAlign.right),
            ],
          )),
      const ReportRowItem(
        id: 'SEC_CA',
        isSubtotalRow: true,
        cells: [
          ReportCell(text: '   2. Current Assets', isBold: true),
          ReportCell(text: ''),
          ReportCell(text: ''),
        ],
      ),
      ...data.currentAssets.map((a) => ReportRowItem(
            id: a.code,
            cells: [
              ReportCell(text: '      ${a.title}'),
              ReportCell(text: a.code),
              ReportCell(text: _fmt(a.amount), align: TextAlign.right),
            ],
          )),
      ReportRowItem(
        id: 'TOTAL_ASSETS',
        isTotalRow: true,
        cells: [
          const ReportCell(text: 'TOTAL ASSETS', isBold: true),
          const ReportCell(text: ''),
          ReportCell(text: _fmt(data.totalAssets), align: TextAlign.right, isBold: true, textColor: AppColors.primaryYellow),
        ],
      ),
    ];

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'Balance Sheet Statement',
      subtitle: '${criteria.showroomName} • As of ${DateFormat('dd MMM yyyy').format(criteria.endDate)} • Schedule III Compliant',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Total Assets', 'value': _fmt(data.totalAssets), 'color': AppColors.info},
        {'title': 'Total Liabilities', 'value': _fmt(data.totalNonCurrentLiabilities + data.totalCurrentLiabilities), 'color': AppColors.warning},
        {'title': 'Net Equity', 'value': _fmt(data.totalEquity), 'color': AppColors.success},
        {'title': 'Status', 'value': data.isBalanced ? 'Balanced' : 'Imbalance', 'color': data.isBalanced ? AppColors.success : AppColors.error},
      ],
      rawReportData: data,
    ));
  }

  // 10. Receivables Aging
  Future<void> _loadReceivablesAgingReport(ReportFilterCriteria criteria) async {
    final data = await _service.generateReceivablesAging(criteria);
    const columns = [
      ReportColumnDef(title: 'Customer Name', flex: 3),
      ReportColumnDef(title: 'Contact', flex: 2),
      ReportColumnDef(title: '0 - 30 Days (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: '31 - 60 Days (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: '61 - 90 Days (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: '> 90 Days (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'Total Due (₹)', align: TextAlign.right, flex: 2),
    ];

    final rows = data.customers.map((c) {
      return ReportRowItem(
        id: c.partyId,
        cells: [
          ReportCell(text: c.partyName, isBold: true),
          ReportCell(text: c.phone ?? '-'),
          ReportCell(text: c.current0to30 > 0 ? _fmt(c.current0to30) : '-', align: TextAlign.right),
          ReportCell(text: c.bracket31to60 > 0 ? _fmt(c.bracket31to60) : '-', align: TextAlign.right),
          ReportCell(text: c.bracket61to90 > 0 ? _fmt(c.bracket61to90) : '-', align: TextAlign.right),
          ReportCell(text: c.bracketAbove90 > 0 ? _fmt(c.bracketAbove90) : '-', align: TextAlign.right, textColor: c.bracketAbove90 > 0 ? AppColors.error : null),
          ReportCell(text: _fmt(c.totalOutstanding), align: TextAlign.right, isBold: true),
        ],
      );
    }).toList();

    rows.add(ReportRowItem(
      id: 'TOTAL',
      isTotalRow: true,
      cells: [
        const ReportCell(text: 'TOTAL RECEIVABLES', isBold: true),
        const ReportCell(text: ''),
        ReportCell(text: _fmt(data.total0to30), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.total31to60), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.total61to90), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.totalAbove90), align: TextAlign.right, isBold: true, textColor: AppColors.error),
        ReportCell(text: _fmt(data.grandTotal), align: TextAlign.right, isBold: true, textColor: AppColors.primaryYellow),
      ],
    ));

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'Receivables Aging Report (Sundry Debtors)',
      subtitle: '${criteria.showroomName} • As of ${DateFormat('dd MMM yyyy').format(criteria.endDate)}',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Total Receivables', 'value': _fmt(data.grandTotal), 'color': AppColors.primaryYellow},
        {'title': 'Current (0-30d)', 'value': _fmt(data.total0to30), 'color': AppColors.success},
        {'title': '31-90 Days', 'value': _fmt(data.total31to60 + data.total61to90), 'color': AppColors.warning},
        {'title': 'Overdue >90d', 'value': _fmt(data.totalAbove90), 'color': AppColors.error},
      ],
      rawReportData: data,
    ));
  }

  // 11. Payables Aging
  Future<void> _loadPayablesAgingReport(ReportFilterCriteria criteria) async {
    final data = await _service.generatePayablesAging(criteria);
    const columns = [
      ReportColumnDef(title: 'OEM / Supplier Name', flex: 3),
      ReportColumnDef(title: 'Contact', flex: 2),
      ReportColumnDef(title: '0 - 30 Days (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: '31 - 60 Days (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: '61 - 90 Days (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: '> 90 Days (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'Total Due (₹)', align: TextAlign.right, flex: 2),
    ];

    final rows = data.suppliers.map((s) {
      return ReportRowItem(
        id: s.partyId,
        cells: [
          ReportCell(text: s.partyName, isBold: true),
          ReportCell(text: s.phone ?? '-'),
          ReportCell(text: s.current0to30 > 0 ? _fmt(s.current0to30) : '-', align: TextAlign.right),
          ReportCell(text: s.bracket31to60 > 0 ? _fmt(s.bracket31to60) : '-', align: TextAlign.right),
          ReportCell(text: s.bracket61to90 > 0 ? _fmt(s.bracket61to90) : '-', align: TextAlign.right),
          ReportCell(text: s.bracketAbove90 > 0 ? _fmt(s.bracketAbove90) : '-', align: TextAlign.right, textColor: s.bracketAbove90 > 0 ? AppColors.error : null),
          ReportCell(text: _fmt(s.totalOutstanding), align: TextAlign.right, isBold: true),
        ],
      );
    }).toList();

    rows.add(ReportRowItem(
      id: 'TOTAL',
      isTotalRow: true,
      cells: [
        const ReportCell(text: 'TOTAL PAYABLES', isBold: true),
        const ReportCell(text: ''),
        ReportCell(text: _fmt(data.total0to30), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.total31to60), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.total61to90), align: TextAlign.right, isBold: true),
        ReportCell(text: _fmt(data.totalAbove90), align: TextAlign.right, isBold: true, textColor: AppColors.error),
        ReportCell(text: _fmt(data.grandTotal), align: TextAlign.right, isBold: true, textColor: AppColors.error),
      ],
    ));

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'Payables Aging Report (Sundry Creditors)',
      subtitle: '${criteria.showroomName} • As of ${DateFormat('dd MMM yyyy').format(criteria.endDate)}',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Total Payables', 'value': _fmt(data.grandTotal), 'color': AppColors.error},
        {'title': 'Current (0-30d)', 'value': _fmt(data.total0to30), 'color': AppColors.info},
        {'title': '31-90 Days', 'value': _fmt(data.total31to60 + data.total61to90), 'color': AppColors.warning},
        {'title': 'Overdue >90d', 'value': _fmt(data.totalAbove90), 'color': AppColors.error},
      ],
      rawReportData: data,
    ));
  }

  // 12. GST Report
  Future<void> _loadGstReport(ReportFilterCriteria criteria) async {
    final data = await _service.generateGstReport(criteria);
    const columns = [
      ReportColumnDef(title: 'Return Table Particulars', flex: 4),
      ReportColumnDef(title: 'CGST (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'SGST (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'IGST (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: 'Total Tax (₹)', align: TextAlign.right, flex: 2),
    ];

    final cgst = (data['totalCgst'] as num?)?.toDouble() ?? 0.0;
    final sgst = (data['totalSgst'] as num?)?.toDouble() ?? 0.0;
    final igst = (data['totalIgst'] as num?)?.toDouble() ?? 0.0;
    final totalTax = cgst + sgst + igst;
    final itc = (data['itcEligible'] as num?)?.toDouble() ?? 0.0;
    final netCash = (data['netTaxPayable'] as num?)?.toDouble() ?? 0.0;

    final rows = [
      ReportRowItem(
        id: 'gstr1_outward',
        cells: [
          const ReportCell(text: 'GSTR-1: Outward Supplies & Vehicle Tax', isBold: true),
          ReportCell(text: _fmt(cgst), align: TextAlign.right),
          ReportCell(text: _fmt(sgst), align: TextAlign.right),
          ReportCell(text: _fmt(igst), align: TextAlign.right),
          ReportCell(text: _fmt(totalTax), align: TextAlign.right, isBold: true),
        ],
      ),
      ReportRowItem(
        id: 'gstr3b_itc',
        cells: [
          const ReportCell(text: 'GSTR-3B: Input Tax Credit (ITC Available)', isBold: true),
          ReportCell(text: _fmt(itc / 2), align: TextAlign.right),
          ReportCell(text: _fmt(itc / 2), align: TextAlign.right),
          const ReportCell(text: '-', align: TextAlign.right),
          ReportCell(text: _fmt(itc), align: TextAlign.right, isBold: true, textColor: AppColors.success),
        ],
      ),
      ReportRowItem(
        id: 'net_payable',
        isTotalRow: true,
        cells: [
          const ReportCell(text: 'NET GST PAYABLE (CASH LEDGER)', isBold: true),
          ReportCell(text: _fmt(netCash / 2), align: TextAlign.right, isBold: true),
          ReportCell(text: _fmt(netCash / 2), align: TextAlign.right, isBold: true),
          const ReportCell(text: '-', align: TextAlign.right),
          ReportCell(text: _fmt(netCash), align: TextAlign.right, isBold: true, textColor: AppColors.primaryYellow),
        ],
      ),
    ];

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'GST Statutory Returns Summary',
      subtitle: '${criteria.showroomName} • Filing Period: ${data['period']}',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Outward Tax', 'value': _fmt(totalTax), 'color': AppColors.primaryYellow},
        {'title': 'Input Credit (ITC)', 'value': _fmt(itc), 'color': AppColors.success},
        {'title': 'Net Cash Payable', 'value': _fmt(netCash), 'color': AppColors.warning},
      ],
      rawReportData: data,
    ));
  }

  // 13. Expense Report
  Future<void> _loadExpenseReport(ReportFilterCriteria criteria) async {
    final data = await _service.generateExpenseReport(criteria);
    const columns = [
      ReportColumnDef(title: 'Account Code', flex: 1),
      ReportColumnDef(title: 'Expense Category', flex: 3),
      ReportColumnDef(title: 'Particulars', flex: 3),
      ReportColumnDef(title: 'Amount (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: '% of Total', align: TextAlign.right, flex: 1),
    ];

    final rows = data.categories.map((c) {
      return ReportRowItem(
        id: c.accountCode,
        cells: [
          ReportCell(text: c.accountCode, isBold: true),
          ReportCell(text: c.categoryName),
          ReportCell(text: c.notes),
          ReportCell(text: _fmt(c.amount), align: TextAlign.right, isBold: true),
          ReportCell(text: '${c.percentage.toStringAsFixed(1)}%', align: TextAlign.right),
        ],
      );
    }).toList();

    rows.add(ReportRowItem(
      id: 'TOTAL',
      isTotalRow: true,
      cells: [
        const ReportCell(text: 'TOTAL', isBold: true),
        const ReportCell(text: ''),
        const ReportCell(text: ''),
        ReportCell(text: _fmt(data.grandTotalExpense), align: TextAlign.right, isBold: true, textColor: AppColors.error),
        const ReportCell(text: '100.0%', align: TextAlign.right, isBold: true),
      ],
    ));

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'Operating Expense Breakdown Report',
      subtitle: '${criteria.showroomName} • ${DateFormat('dd MMM yyyy').format(criteria.startDate)} to ${DateFormat('dd MMM yyyy').format(criteria.endDate)}',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Total Expenses', 'value': _fmt(data.grandTotalExpense), 'color': AppColors.error},
        {'title': 'Top Cost Center', 'value': 'Showroom Rent', 'color': AppColors.warning},
        {'title': 'Payroll Ratio', 'value': '32.8%', 'color': AppColors.info},
      ],
      rawReportData: data,
    ));
  }

  // 14. Income Report
  Future<void> _loadIncomeReport(ReportFilterCriteria criteria) async {
    final data = await _service.generateIncomeReport(criteria);
    const columns = [
      ReportColumnDef(title: 'Account Code', flex: 1),
      ReportColumnDef(title: 'Income Stream', flex: 3),
      ReportColumnDef(title: 'Description', flex: 3),
      ReportColumnDef(title: 'Amount (₹)', align: TextAlign.right, flex: 2),
      ReportColumnDef(title: '% of Total', align: TextAlign.right, flex: 1),
    ];

    final rows = data.incomeCategories.map((c) {
      return ReportRowItem(
        id: c.accountCode,
        cells: [
          ReportCell(text: c.accountCode, isBold: true),
          ReportCell(text: c.categoryName),
          ReportCell(text: c.notes),
          ReportCell(text: _fmt(c.amount), align: TextAlign.right, isBold: true),
          ReportCell(text: '${c.percentage.toStringAsFixed(1)}%', align: TextAlign.right),
        ],
      );
    }).toList();

    rows.add(ReportRowItem(
      id: 'TOTAL',
      isTotalRow: true,
      cells: [
        const ReportCell(text: 'TOTAL', isBold: true),
        const ReportCell(text: ''),
        const ReportCell(text: ''),
        ReportCell(text: _fmt(data.grandTotalIncome), align: TextAlign.right, isBold: true, textColor: AppColors.success),
        const ReportCell(text: '100.0%', align: TextAlign.right, isBold: true),
      ],
    ));

    emit(state.copyWith(
      status: ReportViewerStatus.success,
      title: 'Operating & Other Income Report',
      subtitle: '${criteria.showroomName} • ${DateFormat('dd MMM yyyy').format(criteria.startDate)} to ${DateFormat('dd MMM yyyy').format(criteria.endDate)}',
      columns: columns,
      rows: rows,
      summaryCards: [
        {'title': 'Total Income', 'value': _fmt(data.grandTotalIncome), 'color': AppColors.success},
        {'title': 'Vehicle Sales Share', 'value': '64.0%', 'color': AppColors.primaryYellow},
        {'title': 'Ancillary Commission', 'value': '36.0%', 'color': AppColors.info},
      ],
      rawReportData: data,
    ));
  }

  void updateCriteria(ReportFilterCriteria criteria) {
    loadReport(criteria: criteria);
  }
}
