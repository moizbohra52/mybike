import 'package:equatable/equatable.dart';

/// Periodic GST Summary Entity
///
/// High-level monthly overview summarizing Outward tax liabilities,
/// Inward Input Tax Credit (ITC), and Net statutory tax payable or
/// credit carry-forward, along with GL reconciliation indicators.
class GstSummaryEntity extends Equatable {
  final String filingPeriod; // e.g. "2026-09"
  final String showroomId;
  final String showroomName;

  // Outward (Sales) Liabilities
  final double totalOutwardTaxable;
  final double outputCgst;
  final double outputSgst;
  final double outputIgst;
  final double outputCess;
  final double totalOutputTax;

  // Inward (Purchases / ITC)
  final double totalInwardTaxable;
  final double itcCgst;
  final double itcSgst;
  final double itcIgst;
  final double itcCess;
  final double totalEligibleItc;

  // Net Tax Calculations
  final double netCgstPayable;
  final double netSgstPayable;
  final double netIgstPayable;
  final double totalNetTaxPayable;

  // General Ledger Tax Account Balances
  final double glOutputTaxBalance; // Accounts 2020 + 2021 + 2022
  final double glInputTaxBalance; // Accounts 1060 + 1061 + 1062
  final bool isGlReconciled;

  // Status
  final String returnStatus; // 'open', 'computed', 'filed'
  final DateTime updatedAt;

  const GstSummaryEntity({
    required this.filingPeriod,
    required this.showroomId,
    required this.showroomName,
    required this.totalOutwardTaxable,
    required this.outputCgst,
    required this.outputSgst,
    required this.outputIgst,
    this.outputCess = 0.0,
    required this.totalOutputTax,
    required this.totalInwardTaxable,
    required this.itcCgst,
    required this.itcSgst,
    required this.itcIgst,
    this.itcCess = 0.0,
    required this.totalEligibleItc,
    required this.netCgstPayable,
    required this.netSgstPayable,
    required this.netIgstPayable,
    required this.totalNetTaxPayable,
    required this.glOutputTaxBalance,
    required this.glInputTaxBalance,
    required this.isGlReconciled,
    this.returnStatus = 'open',
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        filingPeriod,
        showroomId,
        showroomName,
        totalOutwardTaxable,
        outputCgst,
        outputSgst,
        outputIgst,
        outputCess,
        totalOutputTax,
        totalInwardTaxable,
        itcCgst,
        itcSgst,
        itcIgst,
        itcCess,
        totalEligibleItc,
        netCgstPayable,
        netSgstPayable,
        netIgstPayable,
        totalNetTaxPayable,
        glOutputTaxBalance,
        glInputTaxBalance,
        isGlReconciled,
        returnStatus,
        updatedAt,
      ];
}
