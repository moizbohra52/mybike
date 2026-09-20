import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../common/common.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/gstr1_report_entity.dart';
import '../cubit/gstr1_report_cubit.dart';
import '../cubit/gstr1_report_state.dart';

/// Statutory GSTR-1 Outward Supplies Return Screen
class Gstr1ReportScreen extends StatelessWidget {
  const Gstr1ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Gstr1ReportCubit()..loadReport(),
      child: const _Gstr1ReportView(),
    );
  }
}

class _Gstr1ReportView extends StatelessWidget {
  const _Gstr1ReportView();

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isDark = context.isDarkMode;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return AppScaffold(
      title: 'GSTR-1 Outward Supplies Return',
      activeNavigationId: 'gst',
      actions: [
        IconButton(
          tooltip: 'Back to GST Hub',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        const SizedBox(width: AppDimensions.spacing8),
        IconButton(
          tooltip: 'Copy Return Summary',
          icon: const Icon(Icons.copy_rounded),
          onPressed: () => _copyReturnSummary(context),
        ),
        IconButton(
          tooltip: 'Refresh Return',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => context.read<Gstr1ReportCubit>().loadReport(),
        ),
      ],
      body: BlocBuilder<Gstr1ReportCubit, Gstr1ReportState>(
        builder: (context, state) {
          if (state.status == Gstr1ReportStatus.loading && state.report == null) {
            return const Center(child: AppLoading(message: 'Compiling GSTR-1 outward registers...'));
          }

          if (state.status == Gstr1ReportStatus.failure && state.report == null) {
            return AppErrorState(
              title: 'Failed to Compile GSTR-1',
              message: state.errorMessage ?? 'An error occurred while compiling return tables.',
              onRetry: () => context.read<Gstr1ReportCubit>().loadReport(),
            );
          }

          final report = state.report;
          if (report == null) {
            return const Center(child: Text('No data available'));
          }

          return Column(
            children: [
              // Period Selector & Summary Header
              _buildSummaryHeader(context, state, report, currencyFormat, isDark),

              // Tab Navigation
              _buildTabSelector(context, state, isDark),

              // Tab Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? AppDimensions.spacing20 : AppDimensions.spacing16),
                  child: _buildActiveTabContent(context, state, report, currencyFormat, isDesktop, isDark),
                ),
              ),

              // Sticky Bottom Totals Bar
              _buildStickyTotalsBar(report, currencyFormat, isDark),
            ],
          );
        },
      ),
    );
  }

  // ─── Summary Header ───
  Widget _buildSummaryHeader(
    BuildContext context,
    Gstr1ReportState state,
    Gstr1ReportEntity report,
    NumberFormat currency,
    bool isDark,
  ) {
    const periods = ['2026-09', '2026-08', '2026-07'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222B) : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'GSTIN: ${report.gstin}',
                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'COMPUTED • READY TO FILE',
                  style: AppTypography.captionSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text('Period: ', style: AppTypography.captionMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Wrap(
                spacing: 6,
                children: periods.map((p) {
                  final isSelected = state.selectedPeriod == p;
                  return ChoiceChip(
                    label: Text(p, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
                    selected: isSelected,
                    selectedColor: AppColors.primaryYellow,
                    onSelected: (selected) {
                      if (selected) context.read<Gstr1ReportCubit>().changePeriod(p);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Tab Selector ───
  Widget _buildTabSelector(BuildContext context, Gstr1ReportState state, bool isDark) {
    final tabs = [
      {'title': '4. B2B Invoices', 'count': state.report?.b2bInvoices.length ?? 0},
      {'title': '5. B2C Large', 'count': state.report?.b2cLargeInvoices.length ?? 0},
      {'title': '7. B2C Small', 'count': state.report?.b2cSmallInvoices.length ?? 0},
      {'title': '9. Credit/Debit Notes', 'count': state.report?.creditDebitNotes.length ?? 0},
      {'title': '12. HSN Summary', 'count': state.report?.hsnSummary.length ?? 0},
      {'title': '13. Doc Summary', 'count': state.report?.docSummary.length ?? 0},
    ];

    return Container(
      color: isDark ? const Color(0xFF191C24) : Colors.grey.shade100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final idx = entry.key;
            final tab = entry.value;
            final isSelected = state.activeTab == idx;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => context.read<Gstr1ReportCubit>().setTab(idx),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryYellow : (isDark ? Colors.white10 : Colors.white),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Text(
                        tab['title'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white24 : (isDark ? Colors.white12 : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${tab['count']}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Active Tab Content Router ───
  Widget _buildActiveTabContent(
    BuildContext context,
    Gstr1ReportState state,
    Gstr1ReportEntity report,
    NumberFormat currency,
    bool isDesktop,
    bool isDark,
  ) {
    switch (state.activeTab) {
      case 0:
        return _buildInvoiceTable(
          title: 'Table 4: Taxable Outward Supplies made to Registered Persons (B2B)',
          items: report.b2bInvoices,
          currency: currency,
          isDesktop: isDesktop,
          isDark: isDark,
        );
      case 1:
        return _buildInvoiceTable(
          title: 'Table 5: Taxable Outward Inter-State Supplies to Unregistered Persons > ₹2.5L (B2C Large)',
          items: report.b2cLargeInvoices,
          currency: currency,
          isDesktop: isDesktop,
          isDark: isDark,
        );
      case 2:
        return _buildInvoiceTable(
          title: 'Table 7: Taxable Supplies to Unregistered Persons Net of Notes (B2C Small)',
          items: report.b2cSmallInvoices,
          currency: currency,
          isDesktop: isDesktop,
          isDark: isDark,
        );
      case 3:
        return _buildInvoiceTable(
          title: 'Table 9: Credit & Debit Notes Issued to Unregistered / Registered Persons',
          items: report.creditDebitNotes,
          currency: currency,
          isDesktop: isDesktop,
          isDark: isDark,
        );
      case 4:
        return _buildHsnSummaryTable(report.hsnSummary, currency, isDesktop, isDark);
      case 5:
        return _buildDocSummaryTable(report.docSummary, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Standard Invoices Table ───
  Widget _buildInvoiceTable({
    required String title,
    required List<Gstr1InvoiceItem> items,
    required NumberFormat currency,
    required bool isDesktop,
    required bool isDark,
  }) {
    if (items.isEmpty) {
      return AppEmptyState(
        title: 'No Transactions for Table',
        description: 'No supplies qualify under this statutory section for the selected period.',
      );
    }

    final dateFormat = DateFormat('dd-MMM-yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade200),
            itemBuilder: (context, idx) {
              final item = items[idx];
              return ListTile(
                dense: true,
                title: Row(
                  children: [
                    Text(item.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(dateFormat.format(item.invoiceDate), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    if (item.customerGstin != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(item.customerGstin!, style: const TextStyle(fontSize: 10, color: AppColors.info)),
                      ),
                    ],
                  ],
                ),
                subtitle: Text('${item.customerName} • POS: ${item.placeOfSupply}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(currency.format(item.invoiceValue), style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'Taxable: ${currency.format(item.taxableAmount)} | ${item.gstRate}%',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Table 12: HSN Summary ───
  Widget _buildHsnSummaryTable(
    List<Gstr1HsnSummaryItem> items,
    NumberFormat currency,
    bool isDesktop,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Table 12: HSN-Wise Summary of Outward Supplies', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.map((hsn) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(hsn.hsnSacCode, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryYellow)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hsn.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('Quantity: ${hsn.totalQuantity} ${hsn.uqc}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Taxable: ${currency.format(hsn.taxableValue)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'CGST: ${currency.format(hsn.cgstAmount)} | SGST: ${currency.format(hsn.sgstAmount)}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─── Table 13: Documents Summary ───
  Widget _buildDocSummaryTable(List<Gstr1DocSummaryItem> items, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Table 13: Documents Issued During the Tax Period', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.map((doc) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc.docType, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Range: ${doc.fromSerial} to ${doc.toSerial}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    Row(
                      children: [
                        _docMetric('Total Issued', doc.totalCount),
                        const SizedBox(width: 16),
                        _docMetric('Cancelled', doc.cancelledCount),
                        const SizedBox(width: 16),
                        _docMetric('Net Issued', doc.netIssuedCount, isBold: true),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _docMetric(String label, int val, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$val', style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // ─── Sticky Bottom Totals Bar ───
  Widget _buildStickyTotalsBar(Gstr1ReportEntity report, NumberFormat currency, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222B) : Colors.grey.shade900,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _totalItem('Gross Taxable Value', currency.format(report.totalTaxableValue)),
              const SizedBox(width: 24),
              _totalItem('CGST', currency.format(report.totalCgstAmount)),
              const SizedBox(width: 24),
              _totalItem('SGST', currency.format(report.totalSgstAmount)),
              const SizedBox(width: 24),
              _totalItem('IGST', currency.format(report.totalIgstAmount)),
            ],
          ),
          _totalItem('Total Invoice Value', currency.format(report.totalInvoiceValue), isHighlight: true),
        ],
      ),
    );
  }

  Widget _totalItem(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 15 : 13,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.success : Colors.white,
          ),
        ),
      ],
    );
  }

  void _copyReturnSummary(BuildContext context) {
    final report = context.read<Gstr1ReportCubit>().state.report;
    if (report == null) return;

    final text = 'GSTR-1 Outward Supplies Summary\n'
        'Filing Period: ${report.filingPeriod}\n'
        'GSTIN: ${report.gstin}\n'
        'Taxable Value: ₹${report.totalTaxableValue}\n'
        'CGST: ₹${report.totalCgstAmount}\n'
        'SGST: ₹${report.totalSgstAmount}\n'
        'IGST: ₹${report.totalIgstAmount}\n'
        'Total Tax: ₹${report.totalTaxAmount}\n'
        'Total Invoice Value: ₹${report.totalInvoiceValue}\n';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GSTR-1 summary copied to clipboard!'), backgroundColor: AppColors.success),
    );
  }
}
