import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/document_export_service.dart';
import 'package:mybike/core/utils/responsive_utils.dart';
import 'package:mybike/features/reports/domain/entities/report_row_item.dart';
import 'package:mybike/features/sales/domain/entities/sales_invoice_entity.dart';
import 'package:mybike/features/sales/domain/entities/payment_receipt_entity.dart';
import 'package:mybike/features/showroom/domain/entities/showroom_entity.dart';
import 'package:mybike/core/theme/app_dimensions.dart';

void main() {
  group('Phase 26 — Cross Platform QA: Platform Engines & Export Services', () {
    const exportService = DocumentExportService();

    final testShowroom = ShowroomEntity(
      id: 'sr-mum-01',
      name: 'MYBIKE Mumbai Central Flagship',
      code: 'IND-MUM-01',
      phone: '+91 22 2490 1100',
      email: 'mumbai@mybike.in',
      address: 'Unit 101, Peninsula Corporate Park',
      city: 'Mumbai',
      state: 'Maharashtra',
      pincode: '400013',
      gstin: '27AABCU9603R1ZM',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('1. Universal PDF Tax Invoice Generator produces valid PDF binary buffer', () async {
      final invoice = SalesInvoiceEntity(
        id: 'inv-qa-001',
        showroomId: testShowroom.id,
        customerId: 'cust-001',
        invoiceNumber: 'IND-MUM-INV-0099',
        invoiceDate: DateTime.now(),
        variantId: 'v-002',
        colorId: 'c-001',
        vin: 'ME4NC5800N8000999',
        engineNumber: 'NC58E-1009999',
        keyNumber: 'KEY-01',
        hsnCode: '8711',
        gstRate: 28.0,
        isInterstate: false,
        exShowroomPrice: 200000.0,
        discountAmount: 5000.0,
        taxableAmount: 152343.75,
        cgstAmount: 21328.12,
        sgstAmount: 21328.13,
        rtoCharges: 20000.0,
        insuranceCharges: 12000.0,
        accessoriesTotal: 5000.0,
        extendedWarrantyAmount: 3000.0,
        fastagCharges: 500.0,
        hypothecationCharges: 0.0,
        roundOff: 0.0,
        totalOnRoadPrice: 235500.0,
        bookingAdvanceAdjusted: 10000.0,
        amountPaid: 235500.0,
        balanceAmount: 0.0,
        paymentStatus: 'paid',
        status: 'delivered',
        issuedBy: 'staff-01',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        customerName: 'Rajesh Sharma',
        customerMobile: '9876543210',
        modelName: 'Honda CB350 H\'ness',
        variantName: 'DLX Pro',
        colorName: 'Precious Red Metallic',
        showroomName: testShowroom.name,
      );

      final pdfBytes = await exportService.generateInvoicePdf(
        invoice: invoice,
        showroom: testShowroom,
      );

      expect(pdfBytes.isNotEmpty, isTrue);
      // Valid PDF magic header bytes: "%PDF-"
      expect(pdfBytes.length, greaterThan(100));
      expect(String.fromCharCodes(pdfBytes.sublist(0, 5)), equals('%PDF-'));
    });

    test('2. Universal Payment Receipt PDF (A4 & POS Thermal 80mm) byte generation', () async {
      final receipt = PaymentReceiptEntity(
        id: 'rec-qa-001',
        showroomId: testShowroom.id,
        customerId: 'cust-001',
        invoiceId: 'inv-qa-001',
        receiptNumber: 'RCP-MUM-2026-0099',
        receiptDate: DateTime.now(),
        amount: 50000.0,
        paymentMode: 'upi',
        paymentReference: 'UPI/HDFC/88997766',
        collectedBy: 'Rahul Verma',
        createdAt: DateTime.now(),
        customerName: 'Rajesh Sharma',
      );

      final a4ReceiptBytes = await exportService.generateReceiptPdf(
        receipt: receipt,
        showroom: testShowroom,
        isThermal: false,
      );
      expect(a4ReceiptBytes.isNotEmpty, isTrue);
      expect(String.fromCharCodes(a4ReceiptBytes.sublist(0, 5)), equals('%PDF-'));

      final thermalReceiptBytes = await exportService.generateReceiptPdf(
        receipt: receipt,
        showroom: testShowroom,
        isThermal: true,
      );
      expect(thermalReceiptBytes.isNotEmpty, isTrue);
      expect(String.fromCharCodes(thermalReceiptBytes.sublist(0, 5)), equals('%PDF-'));
    });

    test('3. Tabular Multi-Format Export: CSV, Excel XML, and Multi-Page PDF', () async {
      const columns = [
        ReportColumnDef(title: 'Showroom', flex: 2),
        ReportColumnDef(title: 'Vehicle Model', flex: 3),
        ReportColumnDef(title: 'Units Sold', align: TextAlign.right),
        ReportColumnDef(title: 'Total Value', align: TextAlign.right),
      ];

      final rows = [
        const ReportRowItem(
          id: 'r1',
          cells: [
            ReportCell(text: 'Mumbai Central'),
            ReportCell(text: 'Honda CB350 DLX Pro'),
            ReportCell(text: '12', align: TextAlign.right),
            ReportCell(text: 'INR 28,20,000', align: TextAlign.right),
          ],
        ),
        const ReportRowItem(
          id: 'r2',
          cells: [
            ReportCell(text: 'Pune West Hub'),
            ReportCell(text: 'Ather 450X Pro'),
            ReportCell(text: '18', align: TextAlign.right),
            ReportCell(text: 'INR 26,10,000', align: TextAlign.right),
          ],
        ),
        const ReportRowItem(
          id: 'r3',
          cells: [
            ReportCell(text: 'Bangalore Metro'),
            ReportCell(text: 'TVS Apache RTR 310'),
            ReportCell(text: '9', align: TextAlign.right),
            ReportCell(text: 'INR 21,15,000', align: TextAlign.right),
          ],
        ),
      ];

      // 1. CSV
      final csvBytes = exportService.generateReportCsv(columns: columns, rows: rows);
      expect(csvBytes.isNotEmpty, isTrue);
      final csvString = exportService.generateReportCsvString(columns: columns, rows: rows);
      expect(csvString, contains('Mumbai Central'));
      expect(csvString, contains('Ather 450X Pro'));

      // 2. Excel XML (.xls)
      final excelBytes = exportService.generateReportExcelXml(
        sheetName: 'Sales Summary',
        title: 'Monthly Sales Analytics',
        columns: columns,
        rows: rows,
      );
      expect(excelBytes.isNotEmpty, isTrue);
      final excelText = String.fromCharCodes(excelBytes);
      expect(excelText, contains('urn:schemas-microsoft-com:office:spreadsheet'));
      expect(excelText, contains('Sales Summary'));

      // 3. PDF Report
      final reportPdf = await exportService.generateReportPdf(
        title: 'Executive Sales Report',
        subtitle: 'FY 2026-27 Multi-Branch Performance',
        columns: columns,
        rows: rows,
        showroom: testShowroom,
      );
      expect(reportPdf.isNotEmpty, isTrue);
      expect(String.fromCharCodes(reportPdf.sublist(0, 5)), equals('%PDF-'));
    });

    testWidgets('4. ResponsiveUtils device type detection across all screen sizes', (WidgetTester tester) async {
      Widget buildSizedWidget(Size size) {
        return MediaQuery(
          data: MediaQueryData(size: size),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Column(
                  children: [
                    Text('Mobile: ${ResponsiveUtils.isMobile(context)}'),
                    Text('Tablet: ${ResponsiveUtils.isTablet(context)}'),
                    Text('Desktop: ${ResponsiveUtils.isDesktop(context)}'),
                  ],
                );
              },
            ),
          ),
        );
      }

      // 1. Mobile screen (< 600)
      await tester.pumpWidget(buildSizedWidget(const Size(375, 812)));
      await tester.pumpAndSettle();
      expect(find.text('Mobile: true'), findsOneWidget);
      expect(find.text('Desktop: false'), findsOneWidget);

      // 2. Tablet screen (600 - 1024)
      await tester.pumpWidget(buildSizedWidget(const Size(800, 1024)));
      await tester.pumpAndSettle();
      expect(find.text('Tablet: true'), findsOneWidget);
      expect(find.text('Mobile: false'), findsOneWidget);

      // 3. Desktop screen (> 1024)
      await tester.pumpWidget(buildSizedWidget(const Size(1440, 900)));
      await tester.pumpAndSettle();
      expect(find.text('Desktop: true'), findsOneWidget);
      expect(find.text('Mobile: false'), findsOneWidget);
    });

    test('5. AppDimensions responsive breakpoints definition', () {
      expect(AppDimensions.breakpointMobile, equals(600.0));
      expect(AppDimensions.breakpointTablet, equals(1024.0));
      expect(AppDimensions.breakpointDesktop, equals(1440.0));
    });
  });
}
