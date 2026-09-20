import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/sales/domain/entities/payment_receipt_entity.dart';
import '../../features/showroom/domain/entities/showroom_entity.dart';
import '../utils/indian_currency_formatter.dart';

/// Builder for Official Payment Receipts and 80mm Thermal POS Slips
class PdfReceiptBuilder {
  PdfReceiptBuilder._();

  static final DateFormat _dateFormat = DateFormat('dd-MMM-yyyy hh:mm a');

  /// Generates A4 or 80mm Thermal POS Receipt PDF bytes
  static Future<Uint8List> build({
    required PaymentReceiptEntity receipt,
    ShowroomEntity? showroom,
    bool isThermal = false,
    String? invoiceNumber,
    String? vehicleModel,
  }) async {
    final pw.Document pdf = pw.Document(
      title: 'Receipt - ${receipt.receiptNumber}',
      author: 'MYBIKE ERP',
    );

    if (isThermal) {
      _buildThermalReceipt(
        pdf: pdf,
        receipt: receipt,
        showroom: showroom,
        invoiceNumber: invoiceNumber,
        vehicleModel: vehicleModel,
      );
    } else {
      _buildStandardA4Receipt(
        pdf: pdf,
        receipt: receipt,
        showroom: showroom,
        invoiceNumber: invoiceNumber,
        vehicleModel: vehicleModel,
      );
    }

    return pdf.save();
  }

  // ─────────────────────────────────────────────────────────
  // Standard A4 Official Money Receipt
  // ─────────────────────────────────────────────────────────
  static void _buildStandardA4Receipt({
    required pw.Document pdf,
    required PaymentReceiptEntity receipt,
    ShowroomEntity? showroom,
    String? invoiceNumber,
    String? vehicleModel,
  }) {
    const PdfColor primaryColor = PdfColor.fromInt(0xFF0F172A);
    const PdfColor tealColor = PdfColor.fromInt(0xFF0F766E);
    const PdfColor lightGrey = PdfColor.fromInt(0xFFF8FAFC);
    const PdfColor borderGrey = PdfColor.fromInt(0xFFCBD5E1);

    final String showroomName = showroom?.name ?? 'MYBIKE DEALERSHIP';
    final String showroomAddress = showroom?.fullAddress ?? 'Main Dealership Avenue, Auto Cluster';
    final String showroomGstin = showroom?.gstin ?? '27AABCM1234F1Z5';
    final String showroomPhone = showroom?.phone ?? '9876543210';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Outer border container
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderGrey, width: 1.5),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              showroomName.toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(showroomAddress, style: const pw.TextStyle(fontSize: 8.5)),
                            pw.Text('Phone: $showroomPhone  |  GSTIN: $showroomGstin', style: const pw.TextStyle(fontSize: 8.5)),
                          ],
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: tealColor,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            'OFFICIAL RECEIPT',
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 12),
                    pw.Divider(color: borderGrey, thickness: 1),
                    pw.SizedBox(height: 8),

                    // Receipt Info Strip
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        _receiptMetaItem('Receipt Number', receipt.receiptNumber, isBold: true),
                        _receiptMetaItem('Date & Time', _dateFormat.format(receipt.createdAt)),
                        if (receipt.invoiceId != null || invoiceNumber != null)
                          _receiptMetaItem('Against Invoice', invoiceNumber ?? receipt.invoiceId ?? 'N/A')
                        else if (receipt.bookingId != null)
                          _receiptMetaItem('Booking ID', receipt.bookingId!)
                        else
                          _receiptMetaItem('Category', 'Customer Settlement'),
                      ],
                    ),

                    pw.SizedBox(height: 16),

                    // Main Receipt Body
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(14),
                      decoration: pw.BoxDecoration(
                        color: lightGrey,
                        border: pw.Border.all(color: borderGrey, width: 0.5),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'RECEIVED WITH THANKS FROM:',
                            style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: tealColor),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            receipt.customerName ?? 'Valued Customer',
                            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: primaryColor),
                          ),
                          pw.SizedBox(height: 10),

                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Expanded(
                                flex: 3,
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    _infoRow('Payment Mode:', receipt.paymentModeLabel),
                                    if (receipt.paymentReference != null && receipt.paymentReference!.isNotEmpty)
                                      _infoRow('Ref / UTR / Chq No:', receipt.paymentReference!),
                                    if (receipt.bankName != null && receipt.bankName!.isNotEmpty)
                                      _infoRow('Drawn On Bank:', receipt.bankName!),
                                    if (vehicleModel != null)
                                      _infoRow('Particulars:', 'Vehicle: $vehicleModel'),
                                    if (receipt.notes != null && receipt.notes!.isNotEmpty)
                                      _infoRow('Remarks:', receipt.notes!),
                                    _infoRow('Collected By:', receipt.collectedBy ?? 'Accounts Desk'),
                                  ],
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.all(12),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.white,
                                    border: pw.Border.all(color: tealColor, width: 1.5),
                                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                                  ),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                                    children: [
                                      pw.Text('AMOUNT RECEIVED', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: tealColor)),
                                      pw.SizedBox(height: 4),
                                      pw.Text(
                                        IndianCurrencyFormatter.formatIndianCurrency(receipt.amount, symbol: 'Rs. '),
                                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          pw.SizedBox(height: 12),
                          pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(
                                  text: 'Amount in words: ',
                                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.TextSpan(
                                  text: IndianCurrencyFormatter.toWords(receipt.amount),
                                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 40),

                    // Footer Signatures
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Terms & Conditions:', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                            pw.Text('1. Cheques subject to realization.', style: const pw.TextStyle(fontSize: 6.5)),
                            pw.Text('2. This receipt is computer generated and valid with authorized cashier stamp.', style: const pw.TextStyle(fontSize: 6.5)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text('For $showroomName', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 35),
                            pw.Container(width: 140, height: 0.5, color: PdfColors.black),
                            pw.SizedBox(height: 3),
                            pw.Text('Cashier / Authorized Signatory', style: const pw.TextStyle(fontSize: 7.5)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // 80mm POS Thermal Slip (Roll80)
  // ─────────────────────────────────────────────────────────
  static void _buildThermalReceipt({
    required pw.Document pdf,
    required PaymentReceiptEntity receipt,
    ShowroomEntity? showroom,
    String? invoiceNumber,
    String? vehicleModel,
  }) {
    final String showroomName = showroom?.name ?? 'MYBIKE DEALERSHIP';
    final String showroomAddress = showroom?.city ?? 'Dealership Branch';
    final String showroomPhone = showroom?.phone ?? '9876543210';
    final String showroomGstin = showroom?.gstin ?? '27AABCM1234F1Z5';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                showroomName.toUpperCase(),
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(showroomAddress, style: const pw.TextStyle(fontSize: 7), textAlign: pw.TextAlign.center),
              pw.Text('Phone: $showroomPhone', style: const pw.TextStyle(fontSize: 7), textAlign: pw.TextAlign.center),
              pw.Text('GSTIN: $showroomGstin', style: const pw.TextStyle(fontSize: 7), textAlign: pw.TextAlign.center),

              pw.SizedBox(height: 4),
              _dashedLine(),
              pw.SizedBox(height: 4),

              pw.Text(
                'PAYMENT RECEIPT',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),

              pw.SizedBox(height: 4),
              _dashedLine(),
              pw.SizedBox(height: 4),

              _thermalRow('Receipt No:', receipt.receiptNumber),
              _thermalRow('Date:', _dateFormat.format(receipt.createdAt)),
              if (invoiceNumber != null)
                _thermalRow('Invoice:', invoiceNumber)
              else if (receipt.bookingId != null)
                _thermalRow('Booking ID:', receipt.bookingId!),

              pw.SizedBox(height: 3),
              _dashedLine(),
              pw.SizedBox(height: 3),

              _thermalRow('Customer:', receipt.customerName ?? 'Customer'),
              _thermalRow('Mode:', receipt.paymentModeLabel),
              if (receipt.paymentReference != null && receipt.paymentReference!.isNotEmpty)
                _thermalRow('Ref / UTR:', receipt.paymentReference!),
              if (vehicleModel != null)
                _thermalRow('Vehicle:', vehicleModel),

              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF1F5F9),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('AMOUNT RECEIVED', style: const pw.TextStyle(fontSize: 7)),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      IndianCurrencyFormatter.formatIndianCurrency(receipt.amount, symbol: 'Rs. '),
                      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),

              pw.Text(
                IndianCurrencyFormatter.toWords(receipt.amount),
                style: const pw.TextStyle(fontSize: 6.5),
                textAlign: pw.TextAlign.center,
              ),

              pw.SizedBox(height: 8),
              _dashedLine(),
              pw.SizedBox(height: 6),

              _thermalRow('Cashier:', receipt.collectedBy ?? 'Admin'),
              pw.SizedBox(height: 12),
              pw.Text('*** THANK YOU ***', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
              pw.Text('Subject to realization of payment.', style: const pw.TextStyle(fontSize: 6)),
            ],
          );
        },
      ),
    );
  }

  static pw.Widget _receiptMetaItem(String title, String value, {bool isBold = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 7.5, color: PdfColor.fromInt(0xFF64748B))),
        pw.SizedBox(height: 1.5),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 95,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF475569))),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _thermalRow(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(key, style: const pw.TextStyle(fontSize: 6.5)),
          pw.Text(value, style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _dashedLine() {
    return pw.Text(
      '------------------------------------------------',
      style: const pw.TextStyle(fontSize: 7, color: PdfColor.fromInt(0xFF94A3B8)),
      maxLines: 1,
    );
  }
}
