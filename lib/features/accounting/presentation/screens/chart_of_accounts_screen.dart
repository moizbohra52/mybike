import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../common/layouts/app_scaffold.dart';
import '../../../../common/loaders/app_skeleton.dart';
import '../../../../common/widgets/app_responsive_grid.dart';
import '../../domain/entities/account_entity.dart';
import '../cubit/chart_of_accounts_cubit.dart';
import '../cubit/chart_of_accounts_state.dart';

/// Chart of Accounts Screen
class ChartOfAccountsScreen extends StatelessWidget {
  const ChartOfAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChartOfAccountsCubit()..loadAccounts(),
      child: const _ChartOfAccountsView(),
    );
  }
}

class _ChartOfAccountsView extends StatefulWidget {
  const _ChartOfAccountsView();

  @override
  State<_ChartOfAccountsView> createState() => _ChartOfAccountsViewState();
}

class _ChartOfAccountsViewState extends State<_ChartOfAccountsView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2);
    final compactCurrency = NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹ ');

    return BlocBuilder<ChartOfAccountsCubit, ChartOfAccountsState>(
      builder: (context, state) {
        return AppScaffold(
          activeNavigationId: 'accounts',
          title: 'Chart of Accounts (COA)',
          actions: [
            OutlinedButton.icon(
              onPressed: () => context.go('/accounting/trial-balance'),
              icon: const Icon(Icons.scale_rounded, size: 18),
              label: const Text('Trial Balance'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => context.go('/accounting/journals'),
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: const Text('Journal Ledger'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => context.go('/accounting/journals/create'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New Voucher'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(width: 16),
          ],
          body: state.isLoading
              ? AppSkeleton.list(kpis: 5, rows: 6)
              : RefreshIndicator(
                  onRefresh: () => context.read<ChartOfAccountsCubit>().loadAccounts(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Financial KPI Cards ───
                        AppResponsiveGrid(
                          minItemWidth: 210,
                          children: [
                            _buildKpiCard(
                              context,
                              title: 'Total Assets',
                              value: compactCurrency.format(state.totalAssets),
                              subtitle: 'Cash, Banks, Stock, Debtors',
                              icon: Icons.account_balance_wallet_rounded,
                              color: AppColors.info,
                              isDark: isDark,
                            ),
                            _buildKpiCard(
                              context,
                              title: 'Total Liabilities',
                              value: compactCurrency.format(state.totalLiabilities),
                              subtitle: 'OEM Creditors, Taxes, Advances',
                              icon: Icons.credit_card_rounded,
                              color: AppColors.warning,
                              isDark: isDark,
                            ),
                            _buildKpiCard(
                              context,
                              title: 'Capital & Equity',
                              value: compactCurrency.format(state.totalEquity),
                              subtitle: 'Promoter Equity & Surplus',
                              icon: Icons.pie_chart_rounded,
                              color: AppColors.success,
                              isDark: isDark,
                            ),
                            _buildKpiCard(
                              context,
                              title: 'Sales Revenue',
                              value: compactCurrency.format(state.totalRevenue),
                              subtitle: 'Petrol & EV Two-Wheelers',
                              icon: Icons.trending_up_rounded,
                              color: AppColors.primaryYellowDark,
                              isDark: isDark,
                            ),
                            _buildKpiCard(
                              context,
                              title: 'COGS & Expenses',
                              value: compactCurrency.format(state.totalExpenses),
                              subtitle: 'Stock Cost, Rent & Salaries',
                              icon: Icons.payments_rounded,
                              color: AppColors.error,
                              isDark: isDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ─── Filter Tabs & Search Bar ───
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _searchController,
                                onChanged: (q) => context.read<ChartOfAccountsCubit>().searchAccounts(q),
                                decoration: InputDecoration(
                                  // The full hint is clipped mid-word on a phone.
                                  hintText: context.isMobile
                                      ? 'Search accounts...'
                                      : 'Search by account code, name, or category...',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded),
                                          onPressed: () {
                                            _searchController.clear();
                                            context.read<ChartOfAccountsCubit>().searchAccounts('');
                                          },
                                        )
                                      : null,
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildFilterChip(context, label: 'All Accounts', type: null, isDark: isDark, current: state.selectedAccountType),
                                    const SizedBox(width: 8),
                                    _buildFilterChip(context, label: 'Assets (1000s)', type: 'asset', isDark: isDark, current: state.selectedAccountType),
                                    const SizedBox(width: 8),
                                    _buildFilterChip(context, label: 'Liabilities (2000s)', type: 'liability', isDark: isDark, current: state.selectedAccountType),
                                    const SizedBox(width: 8),
                                    _buildFilterChip(context, label: 'Equity (3000s)', type: 'equity', isDark: isDark, current: state.selectedAccountType),
                                    const SizedBox(width: 8),
                                    _buildFilterChip(context, label: 'Revenue (4000s)', type: 'revenue', isDark: isDark, current: state.selectedAccountType),
                                    const SizedBox(width: 8),
                                    _buildFilterChip(context, label: 'Expenses (5000s/6000s)', type: 'expense', isDark: isDark, current: state.selectedAccountType),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ─── Accounts List / Table ───
                        if (state.filteredAccounts.isEmpty)
                          _buildEmptyState(isDark)
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.filteredAccounts.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final acct = state.filteredAccounts[index];
                              return _buildAccountRow(context, acct, currency, isDark);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacing8),
              Icon(icon, size: AppDimensions.iconMd, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.captionSmall.copyWith(
              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String? type,
    required bool isDark,
    required String? current,
  }) {
    final isSelected = current == type;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: AppColors.primaryYellow,
      labelStyle: AppTypography.captionLarge.copyWith(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primaryBlack : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
      ),
      onSelected: (_) => context.read<ChartOfAccountsCubit>().filterByType(type),
    );
  }

  Widget _buildAccountRow(
    BuildContext context,
    AccountEntity acct,
    NumberFormat currency,
    bool isDark,
  ) {
    Color typeColor;
    switch (acct.accountType) {
      case 'asset':
        typeColor = AppColors.info;
        break;
      case 'liability':
        typeColor = AppColors.warning;
        break;
      case 'equity':
        typeColor = AppColors.success;
        break;
      case 'revenue':
        typeColor = AppColors.primaryYellowDark;
        break;
      case 'expense':
      default:
        typeColor = AppColors.error;
    }

    final codeChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: typeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        acct.accountCode,
        style: AppTypography.captionLarge.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          color: typeColor,
        ),
      ),
    );

    final nameColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          acct.accountName,
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          '${acct.typeDisplayLabel} • Subtype: ${acct.subType.replaceAll('_', ' ').toUpperCase()}',
          style: AppTypography.captionSmall.copyWith(
            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          ),
        ),
      ],
    );

    final balanceColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          currency.format(acct.currentBalance),
          textAlign: TextAlign.right,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          acct.isAsset || acct.isExpense ? 'Debit Balance' : 'Credit Balance',
          style: AppTypography.captionSmall.copyWith(
            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      // A phone cannot hold the code, the name and the balance on one line
      // without squeezing the name to a few characters, so the balance drops
      // onto its own line there.
      child: context.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    codeChip,
                    const SizedBox(width: 12),
                    Expanded(child: nameColumn),
                  ],
                ),
                const SizedBox(height: 10),
                balanceColumn,
              ],
            )
          : Row(
              children: [
                codeChip,
                const SizedBox(width: 16),
                Expanded(child: nameColumn),
                const SizedBox(width: 16),
                balanceColumn,
              ],
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
            const SizedBox(height: 12),
            Text('No Accounts Found', style: AppTypography.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'No accounts match the selected category or search query.',
              style: AppTypography.captionMedium.copyWith(
                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
