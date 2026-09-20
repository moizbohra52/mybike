import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../common/layouts/app_scaffold.dart';
import '../../../../core/services/document_export_service.dart';
import '../../domain/entities/sales_invoice_entity.dart';
import '../../../reports/presentation/screens/document_preview_screen.dart';
import '../../../reports/presentation/widgets/export_action_modal.dart';
import '../cubit/sales_invoice_detail_cubit.dart';
import '../cubit/sales_invoice_detail_state.dart';

/// Sales Invoice Detail Screen (GST Tax Invoice Dossier)
class SalesInvoiceDetailScreen extends StatelessWidget {
  final String invoiceId;
  const SalesInvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SalesInvoiceDetailCubit()..loadInvoice(invoiceId),
      child: const _SalesInvoiceDetailView(),
    );
  }
}

class _SalesInvoiceDetailView extends StatelessWidget {
  const _SalesInvoiceDetailView();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMMM yyyy');
    final accentColor = isDark ? AppColors.primaryYellow : AppColors.primaryYellowDark;

    return BlocBuilder<SalesInvoiceDetailCubit, SalesInvoiceDetailState>(
      builder: (context, state) {
        final invoice = state.invoice;

        return AppScaffold(
          activeNavigationId: 'sales',
          title: invoice != null ? 'Tax Invoice: ${invoice.invoiceNumber}' : 'Tax Invoice',
          actions: [
            if (invoice != null) ...[
              OutlinedButton.icon(
                onPressed: () => _showPrintOptions(context, invoice),
                icon: const Icon(Icons.print_rounded, size: 18),
                label: const Text('Print / PDF Invoice'),
              ),
              const SizedBox(width: 8),
            ],
            if (invoice != null && invoice.status == 'issued')
              FilledButton.icon(
                onPressed: () => context.go('/sales/${invoice.id}/delivery'),
                icon: const Icon(Icons.local_shipping_rounded, size: 18),
                label: const Text('Generate Delivery Challan'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            const SizedBox(width: 16),
          ],
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : invoice == null
                  ? const Center(child: Text('Invoice not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 950),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ─── Tax Invoice Header ───
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'MYBIKE DEALERSHIP NETWORK',
                                          style: AppTypography.headlineLarge.copyWith(
                                            color: accentColor,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        Text(
                                          'Authorized Dealer • GSTIN: 27AAACM9988C1Z4',
                                          style: AppTypography.captionLarge.copyWith(
                                            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                                          ),
                                        ),
                                        Text(
                                          'Branch: ${invoice.showroomName ?? "Main Showroom"}',
                                          style: AppTypography.captionMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryYellow.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'TAX INVOICE',
                                            style: AppTypography.headlineSmall.copyWith(
                                              color: accentColor,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          Text(
                                            invoice.invoiceNumber,
                                            style: AppTypography.captionLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Date: ${dateFormat.format(invoice.invoiceDate)}',
                                            style: AppTypography.captionSmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 36),

                                // ─── Customer & Vehicle Section ───
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'BUYER / BILLED TO:',
                                            style: AppTypography.captionSmall.copyWith(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            invoice.customerName ?? 'Customer',
                                            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          if (invoice.customerMobile != null)
                                            Text('Mobile: +91 ${invoice.customerMobile}'),
                                          const Text('State: Maharashtra • POS: 27'),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'VEHICLE PARTICULARS:',
                                            style: AppTypography.captionSmall.copyWith(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${invoice.modelName ?? ""} ${invoice.variantName ?? ""}',
                                            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          Text('Color: ${invoice.colorName ?? "Standard"}'),
                                          Text(
                                            'VIN (Chassis): ${invoice.vin}',
                                            style: AppTypography.bodySmall.copyWith(
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.bold,
                                              color: accentColor,
                                            ),
                                          ),
                                          if (invoice.engineNumber != null)
                                            Text('Engine No: ${invoice.engineNumber}', style: const TextStyle(fontFamily: 'monospace')),
                                          if (invoice.motorNumber != null)
                                            Text('Motor No: ${invoice.motorNumber}', style: const TextStyle(fontFamily: 'monospace')),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),

                                // ─── Tax & Pricing Breakdown Table ───
                                Text(
                                  'TAX & PRICING COMPUTATION (HSN 8711):',
                                  style: AppTypography.captionSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildPriceRow('Ex-Showroom Price (Vehicle Base)', currencyFormat.format(invoice.exShowroomPrice), isDark, accentColor),
                                if (invoice.discountAmount > 0)
                                  _buildPriceRow('Special Dealer Discount', '- ${currencyFormat.format(invoice.discountAmount)}', isDark, accentColor, isHighlight: true),
                                _buildPriceRow('Taxable Value', currencyFormat.format(invoice.taxableAmount), isDark, accentColor),
                                _buildPriceRow(
                                  'CGST (${(invoice.gstRate / 2).toStringAsFixed(1)}%)',
                                  currencyFormat.format(invoice.cgstAmount),
                                  isDark,
                                  accentColor,
                                ),
                                _buildPriceRow(
                                  'SGST (${(invoice.gstRate / 2).toStringAsFixed(1)}%)',
                                  currencyFormat.format(invoice.sgstAmount),
                                  isDark,
                                  accentColor,
                                ),
                                _buildPriceRow('RTO Registration & Road Tax', currencyFormat.format(invoice.rtoCharges), isDark, accentColor),
                                _buildPriceRow('Comprehensive Insurance (1+5 Yrs)', currencyFormat.format(invoice.insuranceCharges), isDark, accentColor),
                                if (invoice.accessoriesTotal > 0)
                                  _buildPriceRow('Mandatory & Lifestyle Accessories Pack', currencyFormat.format(invoice.accessoriesTotal), isDark, accentColor),
                                if (invoice.extendedWarrantyAmount > 0)
                                  _buildPriceRow('Extended Warranty (5 Yrs RSA Package)', currencyFormat.format(invoice.extendedWarrantyAmount), isDark, accentColor),
                                if (invoice.fastagCharges > 0)
                                  _buildPriceRow('Fastag / RFID Tag Fees', currencyFormat.format(invoice.fastagCharges), isDark, accentColor),
                                if (invoice.hypothecationCharges > 0)
                                  _buildPriceRow('Hypothecation Endorsement Fees', currencyFormat.format(invoice.hypothecationCharges), isDark, accentColor),
                                const Divider(thickness: 1.5, height: 24),
                                _buildPriceRow(
                                  'TOTAL ON-ROAD PRICE (INR)',
                                  currencyFormat.format(invoice.totalOnRoadPrice),
                                  isDark,
                                  accentColor,
                                  isTotal: true,
                                ),
                                const SizedBox(height: 24),

                                // ─── Settlement / Payment Summary ───
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PAYMENT & SETTLEMENT SUMMARY',
                                        style: AppTypography.captionSmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Booking Advance Adjusted: ${currencyFormat.format(invoice.bookingAdvanceAdjusted)}'),
                                          Text('Amount Paid: ${currencyFormat.format(invoice.amountPaid)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      if (invoice.financeAmount > 0)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Finance / Loan (${invoice.financeBank ?? "Financier"}): ${currencyFormat.format(invoice.financeAmount)}'),
                                            Text(
                                              'Balance Due: ${currencyFormat.format(invoice.balanceAmount)}',
                                              style: TextStyle(
                                                color: invoice.isPaid ? AppColors.success : AppColors.warning,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // ─── Delivery Status ───
                                if (state.challan != null)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Vehicle Delivered under Challan ${state.challan!.challanNumber}',
                                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Handed over to ${state.challan!.receivedByName} on ${dateFormat.format(state.challan!.challanDate)}',
                                              style: AppTypography.captionSmall,
                                            ),
                                          ],
                                        ),
                                      ],
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

  Widget _buildPriceRow(
    String label,
    String value,
    bool isDark,
    Color accentColor, {
    bool isTotal = false,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)
                : AppTypography.bodyMedium.copyWith(
                    color: isHighlight
                        ? AppColors.error
                        : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                  ),
          ),
          Text(
            value,
            style: isTotal
                ? AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  )
                : AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isHighlight ? AppColors.error : null,
                  ),
          ),
        ],
      ),
    );
  }

  void _showPrintOptions(BuildContext context, SalesInvoiceEntity invoice) {
    const exportService = DocumentExportService();
    ExportActionModal.show(
      context,
      title: 'Tax Invoice: ${invoice.invoiceNumber}',
      subtitle: '${invoice.modelName ?? "Vehicle"} • ₹ ${invoice.totalOnRoadPrice.toStringAsFixed(2)}',
      onGeneratePdf: () => exportService.generateInvoicePdf(invoice: invoice),
      onPreviewPdf: (bytes) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DocumentPreviewScreen(
              title: 'Invoice ${invoice.invoiceNumber}',
              pdfBytes: bytes,
            ),
          ),
        );
      },
      onPrint: () async {
        final bytes = await exportService.generateInvoicePdf(invoice: invoice);
        await exportService.printDocument(
          bytes: bytes,
          name: 'Invoice-${invoice.invoiceNumber}',
        );
      },
    );
  }
}

