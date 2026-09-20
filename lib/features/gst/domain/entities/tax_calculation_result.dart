import 'package:equatable/equatable.dart';

/// Tax Calculation Result Entity
///
/// Encapsulates the complete, mathematically verified GST tax breakdown
/// for any automotive invoice, service bill, or spare parts transaction.
class TaxCalculationResult extends Equatable {
  final double baseAmount;
  final double discountAmount;
  final double taxableAmount;
  final String hsnSacCode;
  final bool isInterstate;
  final double gstRate;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final double cessRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final double totalGstAmount;
  final double tcsRate;
  final double tcsAmount;
  final double subtotalBeforeRoundOff;
  final double roundOff;
  final double finalTotal;

  const TaxCalculationResult({
    required this.baseAmount,
    this.discountAmount = 0.0,
    required this.taxableAmount,
    required this.hsnSacCode,
    this.isInterstate = false,
    required this.gstRate,
    this.cgstRate = 0.0,
    this.sgstRate = 0.0,
    this.igstRate = 0.0,
    this.cessRate = 0.0,
    this.cgstAmount = 0.0,
    this.sgstAmount = 0.0,
    this.igstAmount = 0.0,
    this.cessAmount = 0.0,
    required this.totalGstAmount,
    this.tcsRate = 0.0,
    this.tcsAmount = 0.0,
    required this.subtotalBeforeRoundOff,
    required this.roundOff,
    required this.finalTotal,
  });

  /// Factory calculator with precise mathematical rounding
  factory TaxCalculationResult.compute({
    required double baseAmount,
    double discountAmount = 0.0,
    required String hsnSacCode,
    required double gstRate,
    double cessRate = 0.0,
    bool isInterstate = false,
    double tcsRate = 0.0,
  }) {
    final effectiveDiscount = discountAmount > baseAmount ? baseAmount : discountAmount;
    final taxable = double.parse((baseAmount - effectiveDiscount).toStringAsFixed(2));

    double cgstR = 0.0;
    double sgstR = 0.0;
    double igstR = 0.0;

    double cgst = 0.0;
    double sgst = 0.0;
    double igst = 0.0;

    if (isInterstate) {
      igstR = gstRate;
      igst = double.parse((taxable * (igstR / 100.0)).toStringAsFixed(2));
    } else {
      cgstR = double.parse((gstRate / 2.0).toStringAsFixed(2));
      sgstR = double.parse((gstRate / 2.0).toStringAsFixed(2));
      cgst = double.parse((taxable * (cgstR / 100.0)).toStringAsFixed(2));
      sgst = double.parse((taxable * (sgstR / 100.0)).toStringAsFixed(2));
    }

    final cess = cessRate > 0
        ? double.parse((taxable * (cessRate / 100.0)).toStringAsFixed(2))
        : 0.0;

    final totalGst = double.parse((cgst + sgst + igst + cess).toStringAsFixed(2));

    // TCS is calculated on the (Taxable + GST) amount under Sec 206C
    final totalWithGst = taxable + totalGst;
    final tcs = tcsRate > 0
        ? double.parse((totalWithGst * (tcsRate / 100.0)).toStringAsFixed(2))
        : 0.0;

    final subtotal = double.parse((totalWithGst + tcs).toStringAsFixed(2));
    final roundedTotal = subtotal.roundToDouble();
    final roundOffDiff = double.parse((roundedTotal - subtotal).toStringAsFixed(2));

    return TaxCalculationResult(
      baseAmount: baseAmount,
      discountAmount: effectiveDiscount,
      taxableAmount: taxable,
      hsnSacCode: hsnSacCode,
      isInterstate: isInterstate,
      gstRate: gstRate,
      cgstRate: cgstR,
      sgstRate: sgstR,
      igstRate: igstR,
      cessRate: cessRate,
      cgstAmount: cgst,
      sgstAmount: sgst,
      igstAmount: igst,
      cessAmount: cess,
      totalGstAmount: totalGst,
      tcsRate: tcsRate,
      tcsAmount: tcs,
      subtotalBeforeRoundOff: subtotal,
      roundOff: roundOffDiff,
      finalTotal: roundedTotal,
    );
  }

  @override
  List<Object?> get props => [
        baseAmount,
        discountAmount,
        taxableAmount,
        hsnSacCode,
        isInterstate,
        gstRate,
        cgstRate,
        sgstRate,
        igstRate,
        cessRate,
        cgstAmount,
        sgstAmount,
        igstAmount,
        cessAmount,
        totalGstAmount,
        tcsRate,
        tcsAmount,
        subtotalBeforeRoundOff,
        roundOff,
        finalTotal,
      ];
}
