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
import '../../domain/entities/trial_balance_item_entity.dart';
import '../cubit/trial_balance_cubit.dart';
import '../cubit/trial_balance_state.dart';

/// Width the trial balance table needs before it starts scrolling sideways
/// instead of squeezing its columns.
const double _minTableWidth = 700;

/// Trial Balance Statement Screen
class TrialBalanceScreen extends StatelessWidget {
  const TrialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrialBalanceCubit()..loadTrialBalance(),
      child: const _TrialBalanceView(),
    );
  }
}

class _TrialBalanceView extends StatelessWidget {
  const _TrialBalanceView();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMMM yyyy');

    return BlocBuilder<TrialBalanceCubit, TrialBalanceState>(
      builder: (context, state) {
        return AppScaffold(
          activeNavigationId: 'accounts',
          title: 'Trial Balance Statement',
          actions: [
            OutlinedButton.icon(
              onPressed: () => context.go('/accounting'),
              icon: const Icon(Icons.account_tree_outlined, size: 18),
              label: const Text('Chart of Accounts'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => context.go('/accounting/journals'),
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: const Text('Journal Ledger'),
            ),
            const SizedBox(width: 16),
          ],
          body: state.isLoading
              ? AppSkeleton.table(kpis: 3, rows: 8, columns: 5)
              : RefreshIndicator(
                  onRefresh: () => context.read<TrialBalanceCubit>().loadTrialBalance(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── Financial Header & Balance Proof Banner ───
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Builder(
                                    builder: (context) {
                                      final headerInfo = Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'MYBIKE DEALERSHIP ENTERPRISE',
                                            style: AppTypography.headlineSmall.copyWith(
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          Text(
                                            'General Ledger Trial Balance Statement • As of ${dateFormat.format(state.asOfDate)}',
                                            style: AppTypography.captionMedium.copyWith(
                                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                                            ),
                                          ),
                                        ],
                                      );
                                      final balanceChip = Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: state.isBalanced
                                              ? AppColors.success.withValues(alpha: 0.12)
                                              : AppColors.error.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                          border: Border.all(
                                            color: state.isBalanced
                                                ? AppColors.success.withValues(alpha: 0.3)
                                                : AppColors.error.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              state.isBalanced ? Icons.verified_rounded : Icons.error_outline_rounded,
                                              color: state.isBalanced ? AppColors.success : AppColors.error,
                                              size: AppDimensions.iconMd,
                                            ),
                                            const SizedBox(width: AppDimensions.spacing8),
                                            Text(
                                              state.isBalanced ? 'BALANCE PROVED (DR = CR)' : 'OUT OF BALANCE',
                                              style: AppTypography.labelMedium.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: state.isBalanced ? AppColors.success : AppColors.error,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      return context.isMobile
                                          ? Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                headerInfo,
                                                const SizedBox(height: AppDimensions.spacing12),
                                                balanceChip,
                                              ],
                                            )
                                          : Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(child: headerInfo),
                                                const SizedBox(width: AppDimensions.spacing12),
                                                balanceChip,
                                              ],
                                            );
                                    },
                                  ),
                                  const Divider(height: 32),

                                  // Summary Metric Columns
                                  AppResponsiveGrid(
                                    minItemWidth: 210,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Total Debit Balances (DR)', style: AppTypography.captionSmall),
                                          const SizedBox(height: 4),
                                          Text(
                                            currency.format(state.totalDebit),
                                            style: AppTypography.headlineSmall.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.info,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Total Credit Balances (CR)', style: AppTypography.captionSmall),
                                          const SizedBox(height: 4),
                                          Text(
                                            currency.format(state.totalCredit),
                                            style: AppTypography.headlineSmall.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Net Trial Variance', style: AppTypography.captionSmall),
                                          const SizedBox(height: 4),
                                          Text(
                                            currency.format(state.difference),
                                            style: AppTypography.headlineSmall.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: state.isBalanced ? AppColors.success : AppColors.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ─── Trial Balance Data Table ───
                            // Five columns need ~700px. Below that the table
                            // scrolls sideways rather than crushing the
                            // classification and the amounts out of the card.
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final tableWidth = constraints.maxWidth < _minTableWidth
                                      ? _minTableWidth
                                      : constraints.maxWidth;
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: tableWidth,
                                      child: Column(
                                        children: [
                                          // Table Header
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                                            child: const Row(
                                              children: [
                                                SizedBox(width: 80, child: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
                                                Expanded(child: Text('Account Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                                SizedBox(width: 110, child: Text('Classification', style: TextStyle(fontWeight: FontWeight.bold))),
                                                SizedBox(width: 150, child: Text('Debit (DR)', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                                                SizedBox(width: 150, child: Text('Credit (CR)', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                                              ],
                                            ),
                                          ),
                                          const Divider(height: 1),

                                          // Table Rows
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: state.items.length,
                                            separatorBuilder: (_, _) => const Divider(height: 1),
                                            itemBuilder: (context, index) {
                                              final item = state.items[index];
                                              return _buildRow(context, item, currency, isDark);
                                            },
                                          ),
                                          const Divider(height: 1, thickness: 2),

                                          // Table Footer (Total Proof)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 80),
                                                Expanded(
                                                  child: Text(
                                                    'TOTAL TRIAL BALANCE PROOF:',
                                                    style: AppTypography.labelLarge.copyWith(
                                                      fontWeight: FontWeight.w900,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 110),
                                                SizedBox(
                                                  width: 150,
                                                  child: Text(
                                                    currency.format(state.totalDebit),
                                                    textAlign: TextAlign.right,
                                                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w900, color: AppColors.info),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 150,
                                                  child: Text(
                                                    currency.format(state.totalCredit),
                                                    textAlign: TextAlign.right,
                                                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w900, color: AppColors.success),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildRow(
    BuildContext context,
    TrialBalanceItemEntity item,
    NumberFormat currency,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              item.accountCode,
              style: AppTypography.captionLarge.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              item.accountName,
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              item.accountType.toUpperCase(),
              style: AppTypography.captionSmall.copyWith(
                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
              ),
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              item.debitBalance > 0 ? currency.format(item.debitBalance) : '-',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: item.debitBalance > 0 ? FontWeight.bold : FontWeight.normal,
                color: item.debitBalance > 0 ? (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText) : null,
              ),
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              item.creditBalance > 0 ? currency.format(item.creditBalance) : '-',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: item.creditBalance > 0 ? FontWeight.bold : FontWeight.normal,
                color: item.creditBalance > 0 ? (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
