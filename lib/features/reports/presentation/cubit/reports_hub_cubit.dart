import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/report_filter_criteria.dart';
import 'reports_hub_state.dart';

class ReportsHubCubit extends Cubit<ReportsHubState> {
  ReportsHubCubit()
      : super(ReportsHubState(
          criteria: ReportFilterCriteria.currentMonth(),
        ));

  void init() {
    final catalog = [
      // Financial Statements
      const ReportMetadata(
        id: 'trial_balance',
        title: 'Trial Balance',
        category: 'financial',
        description: 'Comprehensive double-entry debit & credit verification across Chart of Accounts.',
        icon: Icons.balance_rounded,
        iconColor: AppColors.primaryYellow,
        routeSlug: 'trial-balance',
      ),
      const ReportMetadata(
        id: 'pnl',
        title: 'Profit & Loss Statement (P&L)',
        category: 'financial',
        description: 'Trading account, gross margin, operating overheads, and net profit before tax.',
        icon: Icons.trending_up_rounded,
        iconColor: AppColors.success,
        routeSlug: 'pnl',
      ),
      const ReportMetadata(
        id: 'balance_sheet',
        title: 'Balance Sheet',
        category: 'financial',
        description: 'Dealership financial position, non-current/current assets, liabilities, and equity.',
        icon: Icons.account_balance_rounded,
        iconColor: AppColors.info,
        routeSlug: 'balance-sheet',
      ),

      // Books & Ledgers
      const ReportMetadata(
        id: 'cash_book',
        title: 'Daily Cash Book',
        category: 'books',
        description: 'Physical cash-in-hand register with daily token advances, petty cash, and contra deposits.',
        icon: Icons.payments_rounded,
        iconColor: AppColors.warning,
        routeSlug: 'cash-book',
      ),
      const ReportMetadata(
        id: 'bank_book',
        title: 'Bank Book (NEFT/RTGS/UPI)',
        category: 'books',
        description: 'Bank operations account register, disbursements, loan payouts, and running balances.',
        icon: Icons.account_balance_wallet_rounded,
        iconColor: AppColors.info,
        routeSlug: 'bank-book',
      ),
      const ReportMetadata(
        id: 'ledger',
        title: 'Party & Account Ledger',
        category: 'books',
        description: 'Chronological double-entry debit/credit ledger with running balance per account.',
        icon: Icons.menu_book_rounded,
        iconColor: AppColors.primaryYellow,
        routeSlug: 'ledger',
      ),

      // Operational Registers
      const ReportMetadata(
        id: 'sales_register',
        title: 'Sales Register',
        category: 'registers',
        description: 'GST Tax Invoices register, customer particulars, vehicle VIN, and collection status.',
        icon: Icons.receipt_long_rounded,
        iconColor: AppColors.success,
        routeSlug: 'sales-register',
      ),
      const ReportMetadata(
        id: 'purchase_register',
        title: 'Purchase Register',
        category: 'registers',
        description: 'OEM procurement consignments, inbound stock batches, and supplier bills.',
        icon: Icons.shopping_cart_rounded,
        iconColor: AppColors.error,
        routeSlug: 'purchase-register',
      ),
      const ReportMetadata(
        id: 'stock_report',
        title: 'Stock & Inventory Valuation',
        category: 'registers',
        description: 'Vehicle units on hand, DSI holding days, inventory valuation, and aging stock alerts (>60d).',
        icon: Icons.two_wheeler_rounded,
        iconColor: AppColors.info,
        routeSlug: 'stock-report',
      ),

      // Working Capital & Statutory
      const ReportMetadata(
        id: 'receivables_aging',
        title: 'Receivables Aging (Sundry Debtors)',
        category: 'working_capital',
        description: 'Customer outstanding balances analyzed across 0-30, 31-60, 61-90, and 90+ day buckets.',
        icon: Icons.timer_outlined,
        iconColor: AppColors.warning,
        routeSlug: 'receivables-aging',
      ),
      const ReportMetadata(
        id: 'payables_aging',
        title: 'Payables Aging (Sundry Creditors)',
        category: 'working_capital',
        description: 'OEM and supplier obligations categorized by maturity buckets to optimize treasury outflow.',
        icon: Icons.hourglass_top_rounded,
        iconColor: AppColors.error,
        routeSlug: 'payables-aging',
      ),
      const ReportMetadata(
        id: 'gst_report',
        title: 'GST Statutory Returns Summary',
        category: 'working_capital',
        description: 'GSTR-1 outward tax liability, GSTR-3B summary, eligible ITC, and net cash payable.',
        icon: Icons.calculate_rounded,
        iconColor: AppColors.primaryYellow,
        routeSlug: 'gst-report',
      ),
      const ReportMetadata(
        id: 'expense_report',
        title: 'Operating Expense Breakdown',
        category: 'working_capital',
        description: 'Category-wise operational overheads: Rent, Salaries, Electricity, and Promotion.',
        icon: Icons.money_off_rounded,
        iconColor: AppColors.error,
        routeSlug: 'expense-report',
      ),
      const ReportMetadata(
        id: 'income_report',
        title: 'Other Income & Subventions',
        category: 'working_capital',
        description: 'Vehicle gross margins, auto loan subventions, insurance commissions, and accessories.',
        icon: Icons.attach_money_rounded,
        iconColor: AppColors.success,
        routeSlug: 'income-report',
      ),
    ];

    emit(state.copyWith(
      status: ReportsHubStatus.success,
      reports: catalog,
    ));
  }

  void filterByCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void searchReports(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setFilterCriteria(ReportFilterCriteria criteria) {
    emit(state.copyWith(criteria: criteria));
  }
}
