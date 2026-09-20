import 'dart:typed_data';
import 'package:flutter/material.dart' as material;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/reports/domain/entities/report_row_item.dart';
import '../../features/showroom/domain/entities/showroom_entity.dart';

/// Builder for Multi-Page Tabular Reports & Financial Statements
class PdfReportBuilder {
  PdfReportBuilder._();

  static final DateFormat _dateFormat = DateFormat('dd-MMM-yyyy hh:mm a');

  /// Generates a PDF byte array for any tabular report
  static Future<Uint8List> build({
    required String title,
    required String subtitle,
    required List<ReportColumnDef> columns,
    required List<ReportRowItem> rows,
    ShowroomEntity? showroom,
    bool isLandscape = true,
  }) async {
    final pw.Document pdf = pw.Document(
      title: title,
      author: 'MYBIKE ERP',
    );

    const PdfColor primaryColor = PdfColor.fromInt(0xFF0F172A); // Slate 900
    const PdfColor tealColor = PdfColor.fromInt(0xFF0F766E);
    const PdfColor lightGrey = PdfColor.fromInt(0xFFF8FAFC);
    const PdfColor altRowColor = PdfColor.fromInt(0xFFF1F5F9);
    const PdfColor borderGrey = PdfColor.fromInt(0xFFCBD5E1);

    final String showroomName = showroom?.name ?? 'MYBIKE MOTORCYCLES DEALERSHIP';
    final String printTimestamp = _dateFormat.format(DateTime.now());

    // Compute column widths
    final Map<int, pw.TableColumnWidth> columnWidths = {};
    for (int i = 0; i < columns.length; i++) {
      final col = columns[i];
      if (col.width != null && col.width! > 0) {
        columnWidths[i] = pw.FixedColumnWidth(col.width!);
      } else {
        columnWidths[i] = pw.FlexColumnWidth(col.flex.toDouble());
      }
    }

    final PdfPageFormat pageFormat = isLandscape
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4;

    final String safeTitle = title.replaceAll('—', '-').replaceAll('•', '|');
    final String safeSubtitle = subtitle.replaceAll('—', '-').replaceAll('•', '|');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(20),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        showroomName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        safeTitle.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: tealColor,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        safeSubtitle,
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColor.fromInt(0xFF475569),
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Generated: $printTimestamp',
                        style: const pw.TextStyle(
                          fontSize: 7,
                          color: PdfColor.fromInt(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(color: tealColor, thickness: 1.5),
              pw.SizedBox(height: 6),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(color: borderGrey, thickness: 0.5),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'MYBIKE ERP - Confidential & Proprietary',
                    style: const pw.TextStyle(fontSize: 7, color: PdfColor.fromInt(0xFF94A3B8)),
                  ),
                  pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: primaryColor),
                  ),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            pw.Table(
              border: pw.TableBorder.all(color: borderGrey, width: 0.5),
              columnWidths: columnWidths,
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: primaryColor),
                  repeat: true,
                  children: columns.map((col) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4.5),
                      child: pw.Text(
                        col.title,
                        style: pw.TextStyle(
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                        textAlign: _mapTextAlign(col.align),
                      ),
                    );
                  }).toList(),
                ),

                // Data rows
                ...rows.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final ReportRowItem row = entry.value;

                  PdfColor rowBg = lightGrey;
                  if (row.isTotalRow) {
                    rowBg = const PdfColor.fromInt(0xFFE2E8F0);
                  } else if (row.isSubtotalRow) {
                    rowBg = const PdfColor.fromInt(0xFFEDF2F7);
                  } else if (index % 2 == 1) {
                    rowBg = altRowColor;
                  }

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: rowBg),
                    children: List.generate(columns.length, (colIdx) {
                      final ReportCell? cell = colIdx < row.cells.length ? row.cells[colIdx] : null;
                      final ReportColumnDef col = columns[colIdx];

                      final String text = cell?.text ?? '';
                      final bool isBold = row.isTotalRow || row.isSubtotalRow || (cell?.isBold ?? false);
                      final pw.TextAlign align = cell != null ? _mapTextAlign(cell.align) : _mapTextAlign(col.align);

                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 4.5, vertical: 3.5),
                        child: pw.Text(
                          text,
                          style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                            color: row.isTotalRow
                                ? primaryColor
                                : const PdfColor.fromInt(0xFF1E293B),
                          ),
                          textAlign: align,
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.TextAlign _mapTextAlign(material.TextAlign align) {
    switch (align) {
      case material.TextAlign.right:
        return pw.TextAlign.right;
      case material.TextAlign.center:
        return pw.TextAlign.center;
      case material.TextAlign.justify:
        return pw.TextAlign.justify;
      case material.TextAlign.left:
      default:
        return pw.TextAlign.left;
    }
  }
}
