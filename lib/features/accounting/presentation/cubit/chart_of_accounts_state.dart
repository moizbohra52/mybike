import 'package:equatable/equatable.dart';
import '../../domain/entities/account_entity.dart';

/// Chart of Accounts State
class ChartOfAccountsState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<AccountEntity> accounts;
  final List<AccountEntity> filteredAccounts;
  final String? selectedAccountType; // null = all, 'asset', 'liability', 'equity', 'revenue', 'expense'
  final String? selectedShowroomId;
  final String searchQuery;

  // KPI Balance Aggregations
  final double totalAssets;
  final double totalLiabilities;
  final double totalEquity;
  final double totalRevenue;
  final double totalExpenses;

  const ChartOfAccountsState({
    this.isLoading = false,
    this.error,
    this.accounts = const [],
    this.filteredAccounts = const [],
    this.selectedAccountType,
    this.selectedShowroomId,
    this.searchQuery = '',
    this.totalAssets = 0.0,
    this.totalLiabilities = 0.0,
    this.totalEquity = 0.0,
    this.totalRevenue = 0.0,
    this.totalExpenses = 0.0,
  });

  ChartOfAccountsState copyWith({
    bool? isLoading,
    String? error,
    List<AccountEntity>? accounts,
    List<AccountEntity>? filteredAccounts,
    String? selectedAccountType,
    String? selectedShowroomId,
    String? searchQuery,
    double? totalAssets,
    double? totalLiabilities,
    double? totalEquity,
    double? totalRevenue,
    double? totalExpenses,
  }) {
    return ChartOfAccountsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      accounts: accounts ?? this.accounts,
      filteredAccounts: filteredAccounts ?? this.filteredAccounts,
      selectedAccountType: selectedAccountType ?? this.selectedAccountType,
      selectedShowroomId: selectedShowroomId ?? this.selectedShowroomId,
      searchQuery: searchQuery ?? this.searchQuery,
      totalAssets: totalAssets ?? this.totalAssets,
      totalLiabilities: totalLiabilities ?? this.totalLiabilities,
      totalEquity: totalEquity ?? this.totalEquity,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalExpenses: totalExpenses ?? this.totalExpenses,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        accounts,
        filteredAccounts,
        selectedAccountType,
        selectedShowroomId,
        searchQuery,
        totalAssets,
        totalLiabilities,
        totalEquity,
        totalRevenue,
        totalExpenses,
      ];
}
