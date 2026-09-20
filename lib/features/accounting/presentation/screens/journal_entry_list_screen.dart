import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../common/layouts/app_scaffold.dart';
import '../../domain/entities/journal_entry_entity.dart';
import '../cubit/journal_entry_list_cubit.dart';
import '../cubit/journal_entry_list_state.dart';

/// Journal Entry List Screen (General Journal Ledger)
class JournalEntryListScreen extends StatelessWidget {
  const JournalEntryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JournalEntryListCubit()..loadJournals(),
      child: const _JournalEntryListView(),
    );
  }
}

class _JournalEntryListView extends StatefulWidget {
  const _JournalEntryListView();

  @override
  State<_JournalEntryListView> createState() => _JournalEntryListViewState();
}

class _JournalEntryListViewState extends State<_JournalEntryListView> {
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

  void _showReverseDialog(BuildContext context, JournalEntryEntity journal) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text('Reverse Voucher ${journal.entryNumber}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Per ERP audit compliance, posted vouchers cannot be deleted. '
                'An opposing reversal voucher will be generated to cancel out the debit/credit balances.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Reversal *',
                  hintText: 'e.g. Invoicing error, cancelled transaction',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) return;
                Navigator.of(dialogCtx).pop();

                final success = await context.read<JournalEntryListCubit>().reverseEntry(
                      journal.id,
                      reason: reason,
                    );

                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Voucher ${journal.entryNumber} successfully reversed.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Confirm Reversal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2);
    final compact = NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹ ');
    final dateFormat = DateFormat('dd MMM yyyy');

    return BlocBuilder<JournalEntryListCubit, JournalEntryListState>(
      builder: (context, state) {
        return AppScaffold(
          activeNavigationId: 'accounts',
          title: 'General Journal & Vouchers',
          actions: [
            OutlinedButton.icon(
              onPressed: () => context.go('/accounting'),
              icon: const Icon(Icons.account_tree_outlined, size: 18),
              label: const Text('Chart of Accounts'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => context.go('/accounting/trial-balance'),
              icon: const Icon(Icons.scale_rounded, size: 18),
              label: const Text('Trial Balance'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => context.go('/accounting/journals/create'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New Journal Voucher'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(width: 16),
          ],
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => context.read<JournalEntryListCubit>().loadJournals(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── KPI Cards ───
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Total Debits Posted',
                                value: compact.format(state.totalDebits),
                                icon: Icons.arrow_downward_rounded,
                                color: AppColors.info,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Total Credits Posted',
                                value: compact.format(state.totalCredits),
                                icon: Icons.arrow_upward_rounded,
                                color: AppColors.success,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Posted Vouchers',
                                value: '${state.postedCount}',
                                icon: Icons.verified_rounded,
                                color: AppColors.primaryYellowDark,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                title: 'Reversals & Adjustments',
                                value: '${state.reversedCount}',
                                icon: Icons.history_rounded,
                                color: AppColors.warning,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ─── Filters & Search ───
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
                                onChanged: (q) => context.read<JournalEntryListCubit>().searchJournals(q),
                                decoration: InputDecoration(
                                  hintText: 'Search voucher number, narration, or reference...',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded),
                                          onPressed: () {
                                            _searchController.clear();
                                            context.read<JournalEntryListCubit>().searchJournals('');
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
                                    _buildStatusChip(context, label: 'All Vouchers', status: null, isDark: isDark, current: state.selectedStatus),
                                    const SizedBox(width: 8),
                                    _buildStatusChip(context, label: 'Posted', status: 'posted', isDark: isDark, current: state.selectedStatus),
                                    const SizedBox(width: 8),
                                    _buildStatusChip(context, label: 'Draft', status: 'draft', isDark: isDark, current: state.selectedStatus),
                                    const SizedBox(width: 8),
                                    _buildStatusChip(context, label: 'Reversed', status: 'reversed', isDark: isDark, current: state.selectedStatus),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ─── Journal Vouchers List ───
                        if (state.filteredJournals.isEmpty)
                          _buildEmptyState(isDark)
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.filteredJournals.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final journal = state.filteredJournals[index];
                              return _buildJournalCard(context, journal, currency, dateFormat, isDark);
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

  Widget _buildMetricCard({
    required String title,
    required String value,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.captionSmall.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required String label,
    required String? status,
    required bool isDark,
    required String? current,
  }) {
    final isSelected = current == status;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: AppColors.primaryYellow,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primaryBlack : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
      ),
      onSelected: (_) => context.read<JournalEntryListCubit>().filterByStatus(status),
    );
  }

  Widget _buildJournalCard(
    BuildContext context,
    JournalEntryEntity journal,
    NumberFormat currency,
    DateFormat dateFormat,
    bool isDark,
  ) {
    Color statusColor;
    switch (journal.status) {
      case 'posted':
        statusColor = AppColors.success;
        break;
      case 'reversed':
        statusColor = AppColors.warning;
        break;
      case 'draft':
      default:
        statusColor = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
          // Voucher Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    journal.entryNumber,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      journal.status.toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Text(
                      journal.referenceTypeLabel,
                      style: AppTypography.captionSmall,
                    ),
                  ),
                ],
              ),
              Text(
                dateFormat.format(journal.entryDate),
                style: AppTypography.captionMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Narration
          Text(
            journal.narration,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 16),

          // Lines Breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Column(
              children: [
                ...journal.lines.map((l) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            l.accountCode ?? '',
                            style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            l.accountName ?? (l.description ?? 'Account Entry'),
                            style: AppTypography.bodySmall,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            l.debitAmount > 0 ? currency.format(l.debitAmount) : '-',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: l.debitAmount > 0 ? FontWeight.bold : FontWeight.normal,
                              color: l.debitAmount > 0 ? AppColors.info : null,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            l.creditAmount > 0 ? currency.format(l.creditAmount) : '-',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: l.creditAmount > 0 ? FontWeight.bold : FontWeight.normal,
                              color: l.creditAmount > 0 ? AppColors.success : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Voucher Balance Proof:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        'DR: ${currency.format(journal.totalDebit)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.info),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        'CR: ${currency.format(journal.totalCredit)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          if (journal.status == 'posted') ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showReverseDialog(context, journal),
                  icon: const Icon(Icons.undo_rounded, size: 16),
                  label: const Text('Reverse Voucher'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
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
            Icon(Icons.menu_book_outlined, size: 48, color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
            const SizedBox(height: 12),
            Text('No Journal Vouchers Found', style: AppTypography.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'No journal vouchers match your current filters or query.',
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
