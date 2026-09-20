import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/accounting_management_service.dart';
import '../../domain/entities/account_entity.dart';
import 'chart_of_accounts_state.dart';

/// Chart of Accounts Cubit
class ChartOfAccountsCubit extends Cubit<ChartOfAccountsState> {
  final AccountingManagementService _service;

  ChartOfAccountsCubit({AccountingManagementService? service})
      : _service = service ?? AccountingManagementService.instance,
        super(const ChartOfAccountsState());

  /// Load accounts
  Future<void> loadAccounts() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final accounts = await _service.fetchAccounts(
        showroomId: state.selectedShowroomId,
      );
      _applyFiltersAndTotals(accounts, state.selectedAccountType, state.searchQuery);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Filter by account type ('asset', 'liability', 'equity', 'revenue', 'expense', null)
  void filterByType(String? type) {
    _applyFiltersAndTotals(state.accounts, type, state.searchQuery);
  }

  /// Search accounts by code, name, or subtype
  void searchAccounts(String query) {
    _applyFiltersAndTotals(state.accounts, state.selectedAccountType, query);
  }

  /// Filter by showroom branch
  void filterByShowroom(String? showroomId) {
    emit(state.copyWith(selectedShowroomId: showroomId));
    loadAccounts();
  }

  /// Clear all filters
  void clearFilters() {
    _applyFiltersAndTotals(state.accounts, null, '');
  }

  void _applyFiltersAndTotals(
    List<AccountEntity> allAccounts,
    String? type,
    String query,
  ) {
    var filtered = List<AccountEntity>.from(allAccounts);

    if (type != null && type.isNotEmpty) {
      filtered = filtered.where((a) => a.accountType == type).toList();
    }

    if (query.isNotEmpty) {
      final s = query.toLowerCase();
      filtered = filtered.where((a) =>
          a.accountCode.toLowerCase().contains(s) ||
          a.accountName.toLowerCase().contains(s) ||
          a.subType.toLowerCase().contains(s)).toList();
    }

    // Sort by numerical account code
    filtered.sort((a, b) => a.accountCode.compareTo(b.accountCode));

    // Calculate totals across ALL active accounts
    double assets = 0.0;
    double liabilities = 0.0;
    double equity = 0.0;
    double revenue = 0.0;
    double expenses = 0.0;

    for (final a in allAccounts) {
      if (!a.isActive) continue;
      switch (a.accountType) {
        case 'asset':
          assets += a.currentBalance;
          break;
        case 'liability':
          liabilities += a.currentBalance;
          break;
        case 'equity':
          equity += a.currentBalance;
          break;
        case 'revenue':
          revenue += a.currentBalance;
          break;
        case 'expense':
          expenses += a.currentBalance;
          break;
      }
    }

    emit(state.copyWith(
      isLoading: false,
      accounts: allAccounts,
      filteredAccounts: filtered,
      selectedAccountType: type,
      searchQuery: query,
      totalAssets: assets,
      totalLiabilities: liabilities,
      totalEquity: equity,
      totalRevenue: revenue,
      totalExpenses: expenses,
    ));
  }
}
