import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../common/common.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// Interactive PDF Preview Screen with Zoom, Print, and Share features
class DocumentPreviewScreen extends StatelessWidget {
  final String title;
  final String? filename;
  final Uint8List? pdfBytes;
  final Future<Uint8List> Function(PdfPageFormat format)? pdfBuilder;

  const DocumentPreviewScreen({
    super.key,
    required this.title,
    this.filename,
    this.pdfBytes,
    this.pdfBuilder,
  }) : assert(pdfBytes != null || pdfBuilder != null, 'Either pdfBytes or pdfBuilder must be provided');

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final String effectiveFilename = filename ?? '${title.replaceAll(' ', '_').toLowerCase()}.pdf';

    return AppScaffold(
      title: title,
      activeNavigationId: 'reports',
      body: Container(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        child: PdfPreview(
          build: (format) async {
            if (pdfBytes != null) {
              return pdfBytes!;
            }
            return await pdfBuilder!(format);
          },
          pdfFileName: effectiveFilename,
          canChangeOrientation: true,
          canChangePageFormat: true,
          canDebug: false,
          maxPageWidth: 700,
          previewPageMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          loadingWidget: const Center(
            child: AppLoading(message: 'Rendering document...'),
          ),
          actions: [
            PdfPreviewAction(
              icon: const Icon(Icons.close_rounded),
              onPressed: (context, build, pageFormat) {
                Navigator.of(context).maybePop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
