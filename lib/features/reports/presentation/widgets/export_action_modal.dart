import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';

/// Modal Bottom Sheet offering multi-format export and print actions
class ExportActionModal extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Future<Uint8List> Function()? onGeneratePdf;
  final Future<void> Function()? onExportExcel;
  final Future<void> Function()? onExportCsv;
  final Future<void> Function()? onPrint;
  final void Function(Uint8List pdfBytes)? onPreviewPdf;

  const ExportActionModal({
    super.key,
    required this.title,
    this.subtitle,
    this.onGeneratePdf,
    this.onExportExcel,
    this.onExportCsv,
    this.onPrint,
    this.onPreviewPdf,
  });

  /// Static helper to display the modal
  static Future<void> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    Future<Uint8List> Function()? onGeneratePdf,
    Future<void> Function()? onExportExcel,
    Future<void> Function()? onExportCsv,
    Future<void> Function()? onPrint,
    void Function(Uint8List pdfBytes)? onPreviewPdf,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportActionModal(
        title: title,
        subtitle: subtitle,
        onGeneratePdf: onGeneratePdf,
        onExportExcel: onExportExcel,
        onExportCsv: onExportCsv,
        onPrint: onPrint,
        onPreviewPdf: onPreviewPdf,
      ),
    );
  }

  @override
  State<ExportActionModal> createState() => _ExportActionModalState();
}

class _ExportActionModalState extends State<ExportActionModal> {
  bool _isLoading = false;
  String _loadingMessage = '';

  Future<void> _handleAction(String label, Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Generating $label...';
    });

    try {
      await action();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTypography.headlineMedium.copyWith(
                            color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: AppTypography.captionLarge.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),
              const Divider(),
              const SizedBox(height: AppDimensions.spacing16),

              if (_isLoading) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          _loadingMessage,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Option 1: PDF Document & Preview
                if (widget.onGeneratePdf != null)
                  _buildExportOption(
                    context: context,
                    icon: Icons.picture_as_pdf_rounded,
                    iconColor: Colors.redAccent,
                    title: 'PDF Document',
                    description: 'Preview, download, or print official formatted A4 statement',
                    onTap: () async {
                      await _handleAction('PDF Document', () async {
                        final bytes = await widget.onGeneratePdf!();
                        if (widget.onPreviewPdf != null && mounted) {
                          widget.onPreviewPdf!(bytes);
                        }
                      });
                    },
                  ),

                // Option 2: Excel Spreadsheet
                if (widget.onExportExcel != null) ...[
                  const SizedBox(height: AppDimensions.spacing12),
                  _buildExportOption(
                    context: context,
                    icon: Icons.table_chart_rounded,
                    iconColor: Colors.green,
                    title: 'Microsoft Excel (.xls / SpreadsheetML)',
                    description: 'Structured workbook with styled headers and calculations',
                    onTap: () => _handleAction('Excel Spreadsheet', widget.onExportExcel!),
                  ),
                ],

                // Option 3: CSV Format
                if (widget.onExportCsv != null) ...[
                  const SizedBox(height: AppDimensions.spacing12),
                  _buildExportOption(
                    context: context,
                    icon: Icons.grid_on_rounded,
                    iconColor: Colors.blueAccent,
                    title: 'CSV Data File',
                    description: 'Universal raw data table for external accounting systems',
                    onTap: () => _handleAction('CSV Data', widget.onExportCsv!),
                  ),
                ],

                // Option 4: Direct Print
                if (widget.onPrint != null) ...[
                  const SizedBox(height: AppDimensions.spacing12),
                  _buildExportOption(
                    context: context,
                    icon: Icons.print_rounded,
                    iconColor: AppColors.primaryYellowDark,
                    title: 'Direct Print Spooler',
                    description: 'Send directly to connected laser or thermal printer',
                    onTap: () => _handleAction('Print Spooler', widget.onPrint!),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacing12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: AppDimensions.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headlineSmall.copyWith(
                        color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTypography.captionMedium.copyWith(
                        color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
