import 'package:equatable/equatable.dart';

/// Single item in GSTR-1 B2B / B2C tables
class Gstr1InvoiceItem extends Equatable {
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String customerName;
  final String? customerGstin;
  final String placeOfSupply; // State Code e.g. "27-Maharashtra"
  final bool isInterstate;
  final double invoiceValue;
  final double taxableAmount;
  final double gstRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;

  const Gstr1InvoiceItem({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerName,
    this.customerGstin,
    required this.placeOfSupply,
    required this.isInterstate,
    required this.invoiceValue,
    required this.taxableAmount,
    required this.gstRate,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    this.cessAmount = 0.0,
  });

  @override
  List<Object?> get props => [
        invoiceNumber,
        invoiceDate,
        customerName,
        customerGstin,
        placeOfSupply,
        isInterstate,
        invoiceValue,
        taxableAmount,
        gstRate,
        cgstAmount,
        sgstAmount,
        igstAmount,
        cessAmount,
      ];
}

/// GSTR-1 Table 12: HSN Summary of Outward Supplies
class Gstr1HsnSummaryItem extends Equatable {
  final String hsnSacCode;
  final String description;
  final String uqc; // Unit Quantity Code e.g. "NOS" (Numbers)
  final int totalQuantity;
  final double totalValue;
  final double taxableValue;
  final double igstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double cessAmount;

  const Gstr1HsnSummaryItem({
    required this.hsnSacCode,
    required this.description,
    this.uqc = 'NOS',
    required this.totalQuantity,
    required this.totalValue,
    required this.taxableValue,
    required this.igstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    this.cessAmount = 0.0,
  });

  @override
  List<Object?> get props => [
        hsnSacCode,
        description,
        uqc,
        totalQuantity,
        totalValue,
        taxableValue,
        igstAmount,
        cgstAmount,
        sgstAmount,
        cessAmount,
      ];
}

/// GSTR-1 Table 13: Documents Issued during the tax period
class Gstr1DocSummaryItem extends Equatable {
  final String docType; // "Tax Invoices", "Credit Notes", "Debit Notes", "Receipt Vouchers"
  final String fromSerial;
  final String toSerial;
  final int totalCount;
  final int cancelledCount;
  final int netIssuedCount;

  const Gstr1DocSummaryItem({
    required this.docType,
    required this.fromSerial,
    required this.toSerial,
    required this.totalCount,
    required this.cancelledCount,
    required this.netIssuedCount,
  });

  @override
  List<Object?> get props => [
        docType,
        fromSerial,
        toSerial,
        totalCount,
        cancelledCount,
        netIssuedCount,
      ];
}

/// Complete GSTR-1 Statutory Return Entity
class Gstr1ReportEntity extends Equatable {
  final String filingPeriod; // e.g. "2026-09"
  final String showroomId;
  final String showroomName;
  final String gstin;
  final DateTime generatedAt;

  // Table 4: B2B Invoices
  final List<Gstr1InvoiceItem> b2bInvoices;

  // Table 5: B2C Large (> 2.5 Lakhs inter-state)
  final List<Gstr1InvoiceItem> b2cLargeInvoices;

  // Table 7: B2C Small (intra-state and inter-state <= 2.5L)
  final List<Gstr1InvoiceItem> b2cSmallInvoices;

  // Table 9: Credit & Debit Notes
  final List<Gstr1InvoiceItem> creditDebitNotes;

  // Table 12: HSN Summary
  final List<Gstr1HsnSummaryItem> hsnSummary;

  // Table 13: Documents Issued
  final List<Gstr1DocSummaryItem> docSummary;

  // Aggregate Totals
  final double totalTaxableValue;
  final double totalCgstAmount;
  final double totalSgstAmount;
  final double totalIgstAmount;
  final double totalCessAmount;
  final double totalInvoiceValue;

  const Gstr1ReportEntity({
    required this.filingPeriod,
    required this.showroomId,
    required this.showroomName,
    required this.gstin,
    required this.generatedAt,
    required this.b2bInvoices,
    required this.b2cLargeInvoices,
    required this.b2cSmallInvoices,
    required this.creditDebitNotes,
    required this.hsnSummary,
    required this.docSummary,
    required this.totalTaxableValue,
    required this.totalCgstAmount,
    required this.totalSgstAmount,
    required this.totalIgstAmount,
    this.totalCessAmount = 0.0,
    required this.totalInvoiceValue,
  });

  double get totalTaxAmount =>
      totalCgstAmount + totalSgstAmount + totalIgstAmount + totalCessAmount;

  @override
  List<Object?> get props => [
        filingPeriod,
        showroomId,
        showroomName,
        gstin,
        generatedAt,
        b2bInvoices,
        b2cLargeInvoices,
        b2cSmallInvoices,
        creditDebitNotes,
        hsnSummary,
        docSummary,
        totalTaxableValue,
        totalCgstAmount,
        totalSgstAmount,
        totalIgstAmount,
        totalCessAmount,
        totalInvoiceValue,
      ];
}
