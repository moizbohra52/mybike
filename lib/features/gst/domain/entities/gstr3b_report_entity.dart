import 'package:equatable/equatable.dart';

/// Single row in GSTR-3B Table 3.1 (Outward Supplies)
class Gstr3bSupplyRow extends Equatable {
  final String natureOfSupplies;
  final double totalTaxableValue;
  final double integratedTax;
  final double centralTax;
  final double stateTax;
  final double cess;

  const Gstr3bSupplyRow({
    required this.natureOfSupplies,
    required this.totalTaxableValue,
    required this.integratedTax,
    required this.centralTax,
    required this.stateTax,
    this.cess = 0.0,
  });

  @override
  List<Object?> get props => [
        natureOfSupplies,
        totalTaxableValue,
        integratedTax,
        centralTax,
        stateTax,
        cess,
      ];
}

/// Single row in GSTR-3B Table 4 (Eligible ITC)
class Gstr3bItcRow extends Equatable {
  final String details;
  final double integratedTax;
  final double centralTax;
  final double stateTax;
  final double cess;

  const Gstr3bItcRow({
    required this.details,
    required this.integratedTax,
    required this.centralTax,
    required this.stateTax,
    this.cess = 0.0,
  });

  double get totalItc => integratedTax + centralTax + stateTax + cess;

  @override
  List<Object?> get props => [
        details,
        integratedTax,
        centralTax,
        stateTax,
        cess,
      ];
}

/// Single row in GSTR-3B Table 6.1 (Payment of Tax)
class Gstr3bTaxPaymentRow extends Equatable {
  final String description; // "Integrated Tax", "Central Tax", "State Tax", "Cess"
  final double taxPayable;
  final double paidThroughItc;
  final double taxPaidCash;
  final double interest;
  final double lateFee;

  const Gstr3bTaxPaymentRow({
    required this.description,
    required this.taxPayable,
    required this.paidThroughItc,
    required this.taxPaidCash,
    this.interest = 0.0,
    this.lateFee = 0.0,
  });

  @override
  List<Object?> get props => [
        description,
        taxPayable,
        paidThroughItc,
        taxPaidCash,
        interest,
        lateFee,
      ];
}

/// Complete GSTR-3B Return Entity
class Gstr3bReportEntity extends Equatable {
  final String filingPeriod; // e.g. "2026-09"
  final String showroomId;
  final String showroomName;
  final String gstin;
  final String status; // 'open', 'computed', 'filed'
  final DateTime generatedAt;

  // Table 3.1: Details of Outward Supplies
  final List<Gstr3bSupplyRow> outwardSupplies;

  // Table 4: Eligible Input Tax Credit (ITC)
  final List<Gstr3bItcRow> eligibleItc;

  // Table 6.1: Payment of Tax
  final List<Gstr3bTaxPaymentRow> taxPayments;

  // Summaries
  final double totalOutwardTax;
  final double totalEligibleItc;
  final double netCashPayable;

  const Gstr3bReportEntity({
    required this.filingPeriod,
    required this.showroomId,
    required this.showroomName,
    required this.gstin,
    required this.status,
    required this.generatedAt,
    required this.outwardSupplies,
    required this.eligibleItc,
    required this.taxPayments,
    required this.totalOutwardTax,
    required this.totalEligibleItc,
    required this.netCashPayable,
  });

  @override
  List<Object?> get props => [
        filingPeriod,
        showroomId,
        showroomName,
        gstin,
        status,
        generatedAt,
        outwardSupplies,
        eligibleItc,
        taxPayments,
        totalOutwardTax,
        totalEligibleItc,
        netCashPayable,
      ];
}
