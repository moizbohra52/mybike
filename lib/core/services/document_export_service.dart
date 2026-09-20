import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../features/reports/domain/entities/report_row_item.dart';
import '../../features/sales/domain/entities/invoice_item_entity.dart';
import '../../features/sales/domain/entities/payment_receipt_entity.dart';
import '../../features/sales/domain/entities/sales_invoice_entity.dart';
import '../../features/showroom/domain/entities/showroom_entity.dart';
import 'pdf_invoice_builder.dart';
import 'pdf_receipt_builder.dart';
import 'pdf_report_builder.dart';
import 'spreadsheet_export_builder.dart';

/// Central Facade Orchestrating All PDF, Excel, CSV, and Print Operations
class DocumentExportService {
  final ShowroomEntity? defaultShowroom;

  const DocumentExportService({this.defaultShowroom});

  // ─────────────────────────────────────────────────────────
  // INVOICE EXPORTS
  // ─────────────────────────────────────────────────────────

  /// Generates GST Tax Invoice PDF document bytes
  Future<Uint8List> generateInvoicePdf({
    required SalesInvoiceEntity invoice,
    ShowroomEntity? showroom,
    List<InvoiceItemEntity> items = const [],
    String copyType = 'ORIGINAL FOR RECIPIENT',
  }) {
    return PdfInvoiceBuilder.build(
      invoice: invoice,
      showroom: showroom ?? defaultShowroom,
      items: items,
      copyType: copyType,
    );
  }

  // ─────────────────────────────────────────────────────────
  // RECEIPT EXPORTS
  // ─────────────────────────────────────────────────────────

  /// Generates Payment Receipt PDF document bytes (A4 or 80mm POS Thermal)
  Future<Uint8List> generateReceiptPdf({
    required PaymentReceiptEntity receipt,
    ShowroomEntity? showroom,
    bool isThermal = false,
    String? invoiceNumber,
    String? vehicleModel,
  }) {
    return PdfReceiptBuilder.build(
      receipt: receipt,
      showroom: showroom ?? defaultShowroom,
      isThermal: isThermal,
      invoiceNumber: invoiceNumber,
      vehicleModel: vehicleModel,
    );
  }

  // ─────────────────────────────────────────────────────────
  // REPORT EXPORTS (PDF, EXCEL, CSV)
  // ─────────────────────────────────────────────────────────

  /// Generates Multi-Page Tabular Report PDF
  Future<Uint8List> generateReportPdf({
    required String title,
    required String subtitle,
    required List<ReportColumnDef> columns,
    required List<ReportRowItem> rows,
    ShowroomEntity? showroom,
    bool isLandscape = true,
  }) {
    return PdfReportBuilder.build(
      title: title,
      subtitle: subtitle,
      columns: columns,
      rows: rows,
      showroom: showroom ?? defaultShowroom,
      isLandscape: isLandscape,
    );
  }

  /// Generates RFC 4180 CSV bytes (with UTF-8 BOM)
  Uint8List generateReportCsv({
    required List<ReportColumnDef> columns,
    required List<ReportRowItem> rows,
    bool includeBom = true,
  }) {
    return SpreadsheetExportBuilder.buildCsvBytes(
      columns: columns,
      rows: rows,
      includeBom: includeBom,
    );
  }

  /// Generates RFC 4180 CSV string
  String generateReportCsvString({
    required List<ReportColumnDef> columns,
    required List<ReportRowItem> rows,
  }) {
    return SpreadsheetExportBuilder.buildCsvString(
      columns: columns,
      rows: rows,
    );
  }

  /// Generates Microsoft Excel SpreadsheetML (.xls/.xml) bytes
  Uint8List generateReportExcelXml({
    required String sheetName,
    required String title,
    required List<ReportColumnDef> columns,
    required List<ReportRowItem> rows,
    String? subtitle,
  }) {
    return SpreadsheetExportBuilder.buildExcelXmlBytes(
      sheetName: sheetName,
      title: title,
      columns: columns,
      rows: rows,
      subtitle: subtitle,
    );
  }

  // ─────────────────────────────────────────────────────────
  // PRINT & SYSTEM INTEGRATION
  // ─────────────────────────────────────────────────────────

  /// Sends PDF bytes to the platform print dialog or direct spooler
  Future<bool> printDocument({
    required Uint8List bytes,
    required String name,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    return Printing.layoutPdf(
      onLayout: (PdfPageFormat _) async => bytes,
      name: name,
      format: format,
    );
  }

  /// Shares PDF bytes using the native system share sheet
  Future<bool> shareDocument({
    required Uint8List bytes,
    required String filename,
  }) async {
    return Printing.sharePdf(
      bytes: bytes,
      filename: filename,
    );
  }
}
