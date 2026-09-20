import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/document_export_service.dart';
import 'package:mybike/core/services/pdf_invoice_builder.dart';
import 'package:mybike/core/services/pdf_receipt_builder.dart';
import 'package:mybike/core/services/pdf_report_builder.dart';
import 'package:mybike/core/services/spreadsheet_export_builder.dart';
import 'package:mybike/core/utils/indian_currency_formatter.dart';
import 'package:mybike/features/reports/domain/entities/report_row_item.dart';
import 'package:mybike/features/sales/domain/entities/invoice_item_entity.dart';
import 'package:mybike/features/sales/domain/entities/payment_receipt_entity.dart';
import 'package:mybike/features/sales/domain/entities/sales_invoice_entity.dart';
import 'package:mybike/features/showroom/domain/entities/showroom_entity.dart';

void main() {
  group('Phase 17 — Indian Currency Formatter Tests', () {
    test('converts amounts to Indian numbering system words accurately', () {
      final zeroWords = IndianCurrencyFormatter.toWords(0.0);
      expect(zeroWords, 'Rupees Zero Only');

      final simpleWords = IndianCurrencyFormatter.toWords(1500.0);
      expect(simpleWords, contains('Rupees One Thousand Five Hundred Only'));

      final lakhsWords = IndianCurrencyFormatter.toWords(154500.50);
      expect(lakhsWords, contains('One Lakh Fifty Four Thousand Five Hundred'));
      expect(lakhsWords, contains('Fifty Paise Only'));

      final croreWords = IndianCurrencyFormatter.toWords(25000000.0);
      expect(croreWords, contains('Rupees Two Crore Fifty Lakh Only'));
    });

    test('formats Indian comma currency string properly', () {
      final formatted = IndianCurrencyFormatter.formatIndianCurrency(154500.50, showSymbol: true);
      expect(formatted, '₹ 1,54,500.50');

      final croreFormatted = IndianCurrencyFormatter.formatIndianCurrency(12345678.90, showSymbol: false);
      expect(croreFormatted, '1,23,45,678.90');

      final smallFormatted = IndianCurrencyFormatter.formatIndianCurrency(500.0, showSymbol: false);
      expect(smallFormatted, '500.00');
    });
  });

  group('Phase 17 — PDF Tax Invoice Builder Tests', () {
    final sampleShowroom = ShowroomEntity(
      id: 'show-01',
      name: 'MYBIKE Mumbai Central',
      code: 'MUM01',
      address: 'Plot 42, Automobile Hub, Andheri East',
      city: 'Mumbai',
      state: 'Maharashtra',
      pincode: '400069',
      phone: '9820011223',
      email: 'mumbai@mybike.com',
      gstin: '27AABCM1234F1Z5',
      pan: 'AABCM1234F',
      bankName: 'HDFC Bank',
      bankAccountNumber: '50200012345678',
      bankIfsc: 'HDFC0001234',
      bankBranch: 'Andheri East',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final sampleInvoice = SalesInvoiceEntity(
      id: 'inv-01',
      showroomId: 'show-01',
      customerId: 'cust-01',
      invoiceNumber: 'IND-MUM-INV-00101',
      invoiceDate: DateTime(2026, 3, 15),
      variantId: 'var-01',
      colorId: 'col-01',
      vin: 'MD2A12345E6789012',
      engineNumber: 'ENG-987654',
      motorNumber: 'MOT-123456',
      batterySerialNumber: 'BAT-456789',
      keyNumber: 'K-9901',
      hsnCode: '8711',
      gstRate: 28.0,
      isInterstate: false,
      exShowroomPrice: 120000.0,
      discountAmount: 2000.0,
      taxableAmount: 118000.0,
      cgstAmount: 16520.0,
      sgstAmount: 16520.0,
      igstAmount: 0.0,
      rtoCharges: 12000.0,
      insuranceCharges: 6500.0,
      accessoriesTotal: 3500.0,
      extendedWarrantyAmount: 2500.0,
      fastagCharges: 500.0,
      totalOnRoadPrice: 175540.0,
      bookingAdvanceAdjusted: 10000.0,
      financeAmount: 120000.0,
      financeBank: 'HDFC Bank',
      amountPaid: 35540.0,
      balanceAmount: 20000.0,
      paymentStatus: 'partial',
      status: 'issued',
      customerName: 'Moiz Bohra',
      customerMobile: '9876543210',
      modelName: 'Speedster 250',
      variantName: 'DLX Bluetooth',
      colorName: 'Matte Obsidian Black',
      showroomName: 'MYBIKE Mumbai Central',
      createdAt: DateTime(2026, 3, 15),
      updatedAt: DateTime(2026, 3, 15),
    );

    final sampleItems = [
      InvoiceItemEntity(
        id: 'item-01',
        invoiceId: 'inv-01',
        itemType: 'accessory',
        description: 'Aerodynamic Touring Windscreen',
        hsnSacCode: '8714',
        quantity: 1,
        unitPrice: 2000.0,
        taxableAmount: 1694.92,
        taxAmount: 305.08,
        totalAmount: 2000.0,
        createdAt: DateTime.now(),
      ),
      InvoiceItemEntity(
        id: 'item-02',
        invoiceId: 'inv-01',
        itemType: 'accessory',
        description: 'Heavy Duty Engine Crash Guard',
        hsnSacCode: '8714',
        quantity: 1,
        unitPrice: 1500.0,
        taxableAmount: 1271.19,
        taxAmount: 228.81,
        totalAmount: 1500.0,
        createdAt: DateTime.now(),
      ),
    ];

    test('generates valid PDF byte array for GST Tax Invoice', () async {
      final Uint8List pdfBytes = await PdfInvoiceBuilder.build(
        invoice: sampleInvoice,
        showroom: sampleShowroom,
        items: sampleItems,
      );

      expect(pdfBytes, isNotEmpty);
      // Valid PDF document begins with "%PDF-"
      final String header = utf8.decode(pdfBytes.sublist(0, 5));
      expect(header, '%PDF-');
    });

    test('generates valid interstate IGST Tax Invoice', () async {
      final interstateInvoice = SalesInvoiceEntity(
        id: 'inv-02',
        showroomId: 'show-01',
        customerId: 'cust-02',
        invoiceNumber: 'IND-MUM-INV-00102',
        invoiceDate: DateTime(2026, 3, 16),
        variantId: 'var-01',
        colorId: 'col-01',
        vin: 'MD2A12345E6789099',
        isInterstate: true,
        exShowroomPrice: 100000.0,
        taxableAmount: 100000.0,
        cgstAmount: 0.0,
        sgstAmount: 0.0,
        igstAmount: 28000.0,
        totalOnRoadPrice: 128000.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final Uint8List pdfBytes = await PdfInvoiceBuilder.build(
        invoice: interstateInvoice,
        showroom: sampleShowroom,
      );

      expect(pdfBytes, isNotEmpty);
      expect(utf8.decode(pdfBytes.sublist(0, 5)), '%PDF-');
    });
  });

  group('Phase 17 — PDF Receipt Builder Tests', () {
    final sampleReceipt = PaymentReceiptEntity(
      id: 'rcp-01',
      showroomId: 'show-01',
      customerId: 'cust-01',
      invoiceId: 'IND-MUM-INV-00101',
      receiptNumber: 'IND-MUM-RCP-00042',
      receiptDate: DateTime(2026, 3, 15),
      amount: 25000.0,
      paymentMode: 'upi',
      paymentReference: 'UPI/607512349876',
      bankName: 'Axis Bank',
      collectedBy: 'Ramesh Accounts',
      customerName: 'Moiz Bohra',
      createdAt: DateTime(2026, 3, 15, 14, 30),
    );

    test('generates valid A4 Official Payment Receipt PDF', () async {
      final Uint8List pdfBytes = await PdfReceiptBuilder.build(
        receipt: sampleReceipt,
        isThermal: false,
        invoiceNumber: 'IND-MUM-INV-00101',
        vehicleModel: 'Speedster 250 DLX',
      );

      expect(pdfBytes, isNotEmpty);
      expect(utf8.decode(pdfBytes.sublist(0, 5)), '%PDF-');
    });

    test('generates valid 80mm POS Thermal Slip PDF', () async {
      final Uint8List thermalBytes = await PdfReceiptBuilder.build(
        receipt: sampleReceipt,
        isThermal: true,
        invoiceNumber: 'IND-MUM-INV-00101',
        vehicleModel: 'Speedster 250 DLX',
      );

      expect(thermalBytes, isNotEmpty);
      expect(utf8.decode(thermalBytes.sublist(0, 5)), '%PDF-');
    });
  });

  group('Phase 17 — PDF Multi-Page Tabular Report Builder Tests', () {
    final columns = [
      const ReportColumnDef(title: 'Account Code', width: 90),
      const ReportColumnDef(title: 'Account Description', flex: 3),
      const ReportColumnDef(title: 'Type', width: 80),
      const ReportColumnDef(title: 'Debit (INR)', align: TextAlign.right, width: 100),
      const ReportColumnDef(title: 'Credit (INR)', align: TextAlign.right, width: 100),
    ];

    final rows = [
      const ReportRowItem(
        id: 'r1',
        cells: [
          ReportCell(text: '1001'),
          ReportCell(text: 'Cash on Hand - Main Safe'),
          ReportCell(text: 'Asset'),
          ReportCell(text: '1,50,000.00', align: TextAlign.right, numericValue: 150000.0),
          ReportCell(text: '0.00', align: TextAlign.right, numericValue: 0.0),
        ],
      ),
      const ReportRowItem(
        id: 'r2',
        cells: [
          ReportCell(text: '1002'),
          ReportCell(text: 'HDFC Current Account'),
          ReportCell(text: 'Asset'),
          ReportCell(text: '8,25,000.00', align: TextAlign.right, numericValue: 825000.0),
          ReportCell(text: '0.00', align: TextAlign.right, numericValue: 0.0),
        ],
      ),
      const ReportRowItem(
        id: 'tot',
        isTotalRow: true,
        cells: [
          ReportCell(text: 'TOTAL', isBold: true),
          ReportCell(text: 'Trial Balance Balance Check', isBold: true),
          ReportCell(text: 'BALANCED', isBold: true),
          ReportCell(text: '9,75,000.00', align: TextAlign.right, isBold: true, numericValue: 975000.0),
          ReportCell(text: '9,75,000.00', align: TextAlign.right, isBold: true, numericValue: 975000.0),
        ],
      ),
    ];

    test('generates valid multi-page PDF report in landscape and portrait', () async {
      final landscapeBytes = await PdfReportBuilder.build(
        title: 'Trial Balance Statement',
        subtitle: 'FY 2025-2026 • All Branches',
        columns: columns,
        rows: rows,
        isLandscape: true,
      );
      expect(landscapeBytes, isNotEmpty);
      expect(utf8.decode(landscapeBytes.sublist(0, 5)), '%PDF-');

      final portraitBytes = await PdfReportBuilder.build(
        title: 'Trial Balance Statement',
        subtitle: 'FY 2025-2026 • All Branches',
        columns: columns,
        rows: rows,
        isLandscape: false,
      );
      expect(portraitBytes, isNotEmpty);
      expect(utf8.decode(portraitBytes.sublist(0, 5)), '%PDF-');
    });
  });

  group('Phase 17 — Spreadsheet Export Builder (CSV & Excel XML)', () {
    final columns = [
      const ReportColumnDef(title: 'Invoice No'),
      const ReportColumnDef(title: 'Customer Name'),
      const ReportColumnDef(title: 'Vehicle'),
      const ReportColumnDef(title: 'Amount', align: TextAlign.right),
    ];

    final rows = [
      const ReportRowItem(
        id: 'r1',
        cells: [
          ReportCell(text: 'INV-001'),
          ReportCell(text: 'Rohan Sharma'),
          ReportCell(text: 'Activa 6G'),
          ReportCell(text: '95000', numericValue: 95000.0),
        ],
      ),
      const ReportRowItem(
        id: 'tot',
        isTotalRow: true,
        cells: [
          ReportCell(text: 'TOTAL'),
          ReportCell(text: ''),
          ReportCell(text: ''),
          ReportCell(text: '95000', numericValue: 95000.0),
        ],
      ),
    ];

    test('generates valid RFC 4180 CSV string and bytes with BOM', () {
      final csvString = SpreadsheetExportBuilder.buildCsvString(
        columns: columns,
        rows: rows,
      );

      expect(csvString, contains('Invoice No,Customer Name,Vehicle,Amount'));
      expect(csvString, contains('INV-001,Rohan Sharma,Activa 6G,95000'));

      final csvBytes = SpreadsheetExportBuilder.buildCsvBytes(
        columns: columns,
        rows: rows,
        includeBom: true,
      );
      expect(csvBytes.length, greaterThan(csvString.length));
      // First 3 bytes are UTF-8 BOM: 0xEF, 0xBB, 0xBF
      expect(csvBytes[0], 0xEF);
      expect(csvBytes[1], 0xBB);
      expect(csvBytes[2], 0xBF);
    });

    test('generates valid Microsoft Excel SpreadsheetML XML', () {
      final xmlString = SpreadsheetExportBuilder.buildExcelXml(
        sheetName: 'Sales Register',
        title: 'Monthly Sales Register',
        subtitle: 'March 2026',
        columns: columns,
        rows: rows,
      );

      expect(xmlString, contains('<?xml version="1.0"?>'));
      expect(xmlString, contains('<Workbook'));
      expect(xmlString, contains('<Worksheet ss:Name="Sales Register">'));
      expect(xmlString, contains('<Table'));
      expect(xmlString, contains('Monthly Sales Register'));
      expect(xmlString, contains('Rohan Sharma'));
      expect(xmlString, contains('<Data ss:Type="Number">95000.0</Data>'));
    });
  });

  group('Phase 17 — DocumentExportService Facade Integration Tests', () {
    const service = DocumentExportService();

    final testInvoice = SalesInvoiceEntity(
      id: 'inv-facade',
      showroomId: 'show-01',
      customerId: 'cust-01',
      invoiceNumber: 'INV-F-001',
      invoiceDate: DateTime.now(),
      variantId: 'v1',
      colorId: 'c1',
      vin: 'VIN12345678901234',
      exShowroomPrice: 100000.0,
      taxableAmount: 100000.0,
      totalOnRoadPrice: 128000.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final testReceipt = PaymentReceiptEntity(
      id: 'rcp-facade',
      showroomId: 'show-01',
      customerId: 'cust-01',
      receiptNumber: 'RCP-F-001',
      receiptDate: DateTime.now(),
      amount: 15000.0,
      paymentMode: 'cash',
      createdAt: DateTime.now(),
    );

    final columns = [
      const ReportColumnDef(title: 'Particulars'),
      const ReportColumnDef(title: 'Amount (INR)', align: TextAlign.right),
    ];

    final rows = [
      const ReportRowItem(
        id: 'r1',
        cells: [
          ReportCell(text: 'Net Revenue'),
          ReportCell(text: '5,00,000.00', numericValue: 500000.0),
        ],
      ),
    ];

    test('orchestrates all export formats seamlessly', () async {
      // 1. Invoice PDF
      final invPdf = await service.generateInvoicePdf(invoice: testInvoice);
      expect(invPdf, isNotEmpty);
      expect(utf8.decode(invPdf.sublist(0, 5)), '%PDF-');

      // 2. Receipt PDF (A4 & Thermal)
      final rcpA4 = await service.generateReceiptPdf(receipt: testReceipt, isThermal: false);
      expect(rcpA4, isNotEmpty);
      expect(utf8.decode(rcpA4.sublist(0, 5)), '%PDF-');

      final rcpThermal = await service.generateReceiptPdf(receipt: testReceipt, isThermal: true);
      expect(rcpThermal, isNotEmpty);
      expect(utf8.decode(rcpThermal.sublist(0, 5)), '%PDF-');

      // 3. Report PDF
      final rptPdf = await service.generateReportPdf(
        title: 'Executive Financial Summary',
        subtitle: 'All Showrooms',
        columns: columns,
        rows: rows,
      );
      expect(rptPdf, isNotEmpty);
      expect(utf8.decode(rptPdf.sublist(0, 5)), '%PDF-');

      // 4. Report CSV
      final rptCsv = service.generateReportCsv(columns: columns, rows: rows);
      expect(rptCsv, isNotEmpty);

      // 5. Report Excel XML
      final rptXls = service.generateReportExcelXml(
        sheetName: 'Summary',
        title: 'Executive Financial Summary',
        columns: columns,
        rows: rows,
      );
      expect(rptXls, isNotEmpty);
      final decodedXml = utf8.decode(rptXls);
      expect(decodedXml, contains('<Workbook'));
      expect(decodedXml, contains('Executive Financial Summary'));
    });
  });
}
