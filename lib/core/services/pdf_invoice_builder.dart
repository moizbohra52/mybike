import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/sales/domain/entities/invoice_item_entity.dart';
import '../../features/sales/domain/entities/sales_invoice_entity.dart';
import '../../features/showroom/domain/entities/showroom_entity.dart';
import '../utils/indian_currency_formatter.dart';

/// Builder for Official Statutory GST Tax Invoices (Automotive HSN 8711)
class PdfInvoiceBuilder {
  PdfInvoiceBuilder._();

  static final DateFormat _dateFormat = DateFormat('dd-MMM-yyyy');

  /// Generates a PDF byte array for a Sales GST Tax Invoice
  static Future<Uint8List> build({
    required SalesInvoiceEntity invoice,
    ShowroomEntity? showroom,
    List<InvoiceItemEntity> items = const [],
    String copyType = 'ORIGINAL FOR RECIPIENT',
  }) async {
    final pw.Document pdf = pw.Document(
      title: 'Tax Invoice - ${invoice.invoiceNumber}',
      author: 'MYBIKE ERP',
    );

    // Theme & styling
    const PdfColor primaryColor = PdfColor.fromInt(0xFF1E293B); // Dark slate
    const PdfColor accentColor = PdfColor.fromInt(0xFF0F766E); // Deep teal
    const PdfColor lightGrey = PdfColor.fromInt(0xFFF1F5F9);
    const PdfColor borderGrey = PdfColor.fromInt(0xFFCBD5E1);

    final pw.TextStyle regularStyle = pw.TextStyle(
      fontSize: 8.5,
      color: PdfColors.black,
    );
    final pw.TextStyle boldStyle = pw.TextStyle(
      fontSize: 8.5,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );
    final pw.TextStyle headerStyle = pw.TextStyle(
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    // Default showroom fallback if not provided
    final String showroomName = showroom?.name ?? invoice.showroomName ?? 'MYBIKE DEALERSHIP';
    final String showroomAddress = showroom?.fullAddress ?? 'Main Dealership Avenue, Auto Cluster';
    final String showroomPhone = showroom?.phone ?? '9876543210';
    final String showroomGstin = showroom?.gstin ?? '27AABCM1234F1Z5';
    final String showroomPan = showroom?.pan ?? 'AABCM1234F';
    final String showroomState = showroom?.state ?? 'Maharashtra (27)';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // ─── Header: Dealership & Tax Invoice Title ───
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: borderGrey, width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                children: [
                  pw.Container(
                    color: primaryColor,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              showroomName.toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.Text(
                              'Authorized Two-Wheeler Dealership & Service Center',
                              style: pw.TextStyle(
                                fontSize: 7.5,
                                color: const PdfColor.fromInt(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: pw.BoxDecoration(
                                color: accentColor,
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                              ),
                              child: pw.Text(
                                'TAX INVOICE',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              copyType,
                              style: pw.TextStyle(
                                fontSize: 6.5,
                                fontWeight: pw.FontWeight.bold,
                                color: const PdfColor.fromInt(0xFFE2E8F0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Dealership GST & Contact details
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(showroomAddress, style: regularStyle),
                              pw.SizedBox(height: 2),
                              pw.Text('Phone: $showroomPhone | State: $showroomState', style: regularStyle),
                              pw.SizedBox(height: 2),
                              pw.RichText(
                                text: pw.TextSpan(
                                  children: [
                                    pw.TextSpan(text: 'GSTIN: ', style: boldStyle),
                                    pw.TextSpan(text: '$showroomGstin  |  ', style: regularStyle),
                                    pw.TextSpan(text: 'PAN: ', style: boldStyle),
                                    pw.TextSpan(text: showroomPan, style: regularStyle),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(width: 1, height: 45, color: borderGrey),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _keyValueRow('Invoice No:', invoice.invoiceNumber, isBoldValue: true),
                              _keyValueRow('Invoice Date:', _dateFormat.format(invoice.invoiceDate)),
                              _keyValueRow('Place of Supply:', showroomState),
                              _keyValueRow('Reverse Charge:', 'No'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 8),

            // ─── Customer & Delivery Particulars ───
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: borderGrey, width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('BILLED TO / CUSTOMER DETAILS', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: accentColor)),
                          pw.SizedBox(height: 3),
                          pw.Text(invoice.customerName ?? 'Customer', style: boldStyle),
                          pw.SizedBox(height: 2),
                          pw.Text('Phone: ${invoice.customerMobile ?? 'N/A'}', style: regularStyle),
                          pw.Text('Status: ${invoice.paymentStatus.toUpperCase()} (${invoice.status.toUpperCase()})', style: regularStyle),
                        ],
                      ),
                    ),
                  ),
                  pw.Container(width: 1, height: 50, color: borderGrey),
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('VEHICLE REGISTRATION & IDENTIFIERS', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: accentColor)),
                          pw.SizedBox(height: 3),
                          _keyValueRow('VIN / Chassis:', invoice.vin, isBoldValue: true),
                          if (invoice.engineNumber != null && invoice.engineNumber!.isNotEmpty)
                            _keyValueRow('Engine No:', invoice.engineNumber!),
                          if (invoice.motorNumber != null && invoice.motorNumber!.isNotEmpty)
                            _keyValueRow('Motor No:', invoice.motorNumber!),
                          if (invoice.batterySerialNumber != null && invoice.batterySerialNumber!.isNotEmpty)
                            _keyValueRow('Battery No:', invoice.batterySerialNumber!),
                          if (invoice.keyNumber != null && invoice.keyNumber!.isNotEmpty)
                            _keyValueRow('Key No:', invoice.keyNumber!),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 8),

            // ─── Vehicle & Line Items Table ───
            pw.Table(
              border: pw.TableBorder.all(color: borderGrey, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3.5),
                1: const pw.FlexColumnWidth(1.2),
                2: const pw.FlexColumnWidth(0.8),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
                5: const pw.FlexColumnWidth(1.2),
                6: const pw.FlexColumnWidth(1.2),
                7: const pw.FlexColumnWidth(1.6),
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: primaryColor),
                  children: [
                    _tableCell('Description of Goods / Services', headerStyle, align: pw.TextAlign.left),
                    _tableCell('HSN/SAC', headerStyle, align: pw.TextAlign.center),
                    _tableCell('Qty', headerStyle, align: pw.TextAlign.center),
                    _tableCell('Rate (INR)', headerStyle, align: pw.TextAlign.right),
                    _tableCell('Taxable Val', headerStyle, align: pw.TextAlign.right),
                    _tableCell(invoice.isInterstate ? 'IGST %' : 'CGST %', headerStyle, align: pw.TextAlign.center),
                    _tableCell(invoice.isInterstate ? 'IGST Amt' : 'SGST Amt', headerStyle, align: pw.TextAlign.right),
                    _tableCell('Total (INR)', headerStyle, align: pw.TextAlign.right),
                  ],
                ),

                // Vehicle Main Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: lightGrey),
                  children: [
                    _tableCell(
                      '${invoice.modelName ?? 'Vehicle'} - ${invoice.variantName ?? ''}\nColor: ${invoice.colorName ?? 'Standard'}',
                      boldStyle,
                    ),
                    _tableCell(invoice.hsnCode, regularStyle, align: pw.TextAlign.center),
                    _tableCell('1', regularStyle, align: pw.TextAlign.center),
                    _tableCell(IndianCurrencyFormatter.formatIndianCurrency(invoice.exShowroomPrice, showSymbol: false), regularStyle, align: pw.TextAlign.right),
                    _tableCell(IndianCurrencyFormatter.formatIndianCurrency(invoice.taxableAmount, showSymbol: false), boldStyle, align: pw.TextAlign.right),
                    _tableCell(
                      invoice.isInterstate ? '${invoice.gstRate.toStringAsFixed(1)}%' : '${(invoice.gstRate / 2).toStringAsFixed(1)}%',
                      regularStyle,
                      align: pw.TextAlign.center,
                    ),
                    _tableCell(
                      invoice.isInterstate
                          ? IndianCurrencyFormatter.formatIndianCurrency(invoice.igstAmount, showSymbol: false)
                          : IndianCurrencyFormatter.formatIndianCurrency(invoice.sgstAmount, showSymbol: false),
                      regularStyle,
                      align: pw.TextAlign.right,
                    ),
                    _tableCell(
                      IndianCurrencyFormatter.formatIndianCurrency(
                        invoice.taxableAmount + invoice.cgstAmount + invoice.sgstAmount + invoice.igstAmount,
                        showSymbol: false,
                      ),
                      boldStyle,
                      align: pw.TextAlign.right,
                    ),
                  ],
                ),

                // Additional Line Items (Accessories, Services, etc.)
                ...items.map((item) {
                  return pw.TableRow(
                    children: [
                      _tableCell(item.description, regularStyle),
                      _tableCell(item.hsnSacCode ?? '8714', regularStyle, align: pw.TextAlign.center),
                      _tableCell('${item.quantity}', regularStyle, align: pw.TextAlign.center),
                      _tableCell(IndianCurrencyFormatter.formatIndianCurrency(item.unitPrice, showSymbol: false), regularStyle, align: pw.TextAlign.right),
                      _tableCell(IndianCurrencyFormatter.formatIndianCurrency(item.taxableAmount, showSymbol: false), regularStyle, align: pw.TextAlign.right),
                      _tableCell('${item.gstRate.toStringAsFixed(1)}%', regularStyle, align: pw.TextAlign.center),
                      _tableCell(IndianCurrencyFormatter.formatIndianCurrency(item.taxAmount, showSymbol: false), regularStyle, align: pw.TextAlign.right),
                      _tableCell(IndianCurrencyFormatter.formatIndianCurrency(item.totalAmount, showSymbol: false), regularStyle, align: pw.TextAlign.right),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 6),

            // ─── Additional Charges & Statutory Breakdown ───
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left Column: Settlement & Remittance Details
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: borderGrey, width: 0.5),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                          color: lightGrey,
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('SETTLEMENT & PAYMENT SCHEDULE', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                            pw.SizedBox(height: 3),
                            _keyValueRow('Advance / Booking Paid:', IndianCurrencyFormatter.formatIndianCurrency(invoice.bookingAdvanceAdjusted, symbol: 'Rs. ')),
                            if (invoice.financeAmount > 0)
                              _keyValueRow('Financed Amount (${invoice.financeBank ?? 'Bank'}):', IndianCurrencyFormatter.formatIndianCurrency(invoice.financeAmount, symbol: 'Rs. ')),
                            if (invoice.exchangeAllowance > 0)
                              _keyValueRow('Exchange Vehicle Credit:', IndianCurrencyFormatter.formatIndianCurrency(invoice.exchangeAllowance, symbol: 'Rs. ')),
                            _keyValueRow('Total Amount Paid to Date:', IndianCurrencyFormatter.formatIndianCurrency(invoice.amountPaid, symbol: 'Rs. '), isBoldValue: true),
                            _keyValueRow('Balance Amount Payable:', IndianCurrencyFormatter.formatIndianCurrency(invoice.balanceAmount, symbol: 'Rs. '), isBoldValue: true),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      // Bank Remittance
                      if (showroom?.bankAccountNumber != null && showroom!.bankAccountNumber!.isNotEmpty)
                        pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: borderGrey, width: 0.5),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('BANK REMITTANCE DETAILS', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: accentColor)),
                              pw.SizedBox(height: 2),
                              pw.Text('Bank: ${showroom.bankName ?? 'Nationalized Bank'} | A/C: ${showroom.bankAccountNumber}', style: regularStyle),
                              pw.Text('IFSC: ${showroom.bankIfsc ?? 'N/A'} | Branch: ${showroom.bankBranch ?? showroom.city}', style: regularStyle),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                pw.SizedBox(width: 8),

                // Right Column: Comprehensive Price Summary
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: borderGrey, width: 0.5),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                    ),
                    child: pw.Column(
                      children: [
                        _priceSummaryRow('Ex-Showroom Price:', invoice.exShowroomPrice),
                        if (invoice.discountAmount > 0)
                          _priceSummaryRow('Less: Dealer Discount:', -invoice.discountAmount),
                        _priceSummaryRow('Total Taxable Value:', invoice.taxableAmount, isBold: true),
                        if (!invoice.isInterstate) ...[
                          _priceSummaryRow('CGST (${(invoice.gstRate / 2).toStringAsFixed(1)}%):', invoice.cgstAmount),
                          _priceSummaryRow('SGST (${(invoice.gstRate / 2).toStringAsFixed(1)}%):', invoice.sgstAmount),
                        ] else ...[
                          _priceSummaryRow('IGST (${invoice.gstRate.toStringAsFixed(1)}%):', invoice.igstAmount),
                        ],
                        if (invoice.rtoCharges > 0)
                          _priceSummaryRow('RTO Registration & Road Tax:', invoice.rtoCharges),
                        if (invoice.insuranceCharges > 0)
                          _priceSummaryRow('Comprehensive Insurance:', invoice.insuranceCharges),
                        if (invoice.accessoriesTotal > 0)
                          _priceSummaryRow('Accessories Package:', invoice.accessoriesTotal),
                        if (invoice.extendedWarrantyAmount > 0)
                          _priceSummaryRow('Extended Warranty (RSA):', invoice.extendedWarrantyAmount),
                        if (invoice.fastagCharges > 0)
                          _priceSummaryRow('FASTag / Logistics:', invoice.fastagCharges),
                        if (invoice.tcsAmount > 0)
                          _priceSummaryRow('TCS (1% under Sec 206C):', invoice.tcsAmount),
                        if (invoice.roundOff != 0.0)
                          _priceSummaryRow('Round Off:', invoice.roundOff),
                        pw.Divider(color: primaryColor, thickness: 1),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('TOTAL ON-ROAD:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentColor)),
                            pw.Text(
                              IndianCurrencyFormatter.formatIndianCurrency(invoice.totalOnRoadPrice, symbol: 'Rs. '),
                              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: accentColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 6),

            // ─── Amount in Words ───
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: pw.BoxDecoration(
                color: lightGrey,
                border: pw.Border.all(color: borderGrey, width: 0.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
              ),
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: 'Amount Chargeable (in words): ', style: boldStyle),
                    pw.TextSpan(text: IndianCurrencyFormatter.toWords(invoice.totalOnRoadPrice), style: regularStyle),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 10),

            // ─── Terms & Signatures ───
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('TERMS & CONDITIONS:', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                      pw.Text('1. Goods once sold will not be taken back or exchanged.', style: pw.TextStyle(fontSize: 6.5)),
                      pw.Text('2. Warranty is provided strictly as per vehicle manufacturer warranty policy.', style: pw.TextStyle(fontSize: 6.5)),
                      pw.Text('3. Subject to jurisdiction of local courts only.', style: pw.TextStyle(fontSize: 6.5)),
                      pw.SizedBox(height: 14),
                      pw.Text('Customer Signature', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('For $showroomName', style: boldStyle),
                      pw.SizedBox(height: 26),
                      pw.Container(width: 120, height: 0.5, color: PdfColors.black),
                      pw.SizedBox(height: 2),
                      pw.Text('Authorized Signatory & Seal', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _keyValueRow(String key, String value, {bool isBoldValue = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(key, style: pw.TextStyle(fontSize: 7.5, color: const PdfColor.fromInt(0xFF475569))),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: isBoldValue ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _priceSummaryRow(String title, double amount, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 7.5, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(
            IndianCurrencyFormatter.formatIndianCurrency(amount, showSymbol: false),
            style: pw.TextStyle(fontSize: 7.5, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        ],
      ),
    );
  }

  static pw.Widget _tableCell(String text, pw.TextStyle style, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3.5),
      child: pw.Text(text, style: style, textAlign: align),
    );
  }
}
