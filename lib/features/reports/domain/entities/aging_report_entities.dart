import 'package:equatable/equatable.dart';

/// Single row item in Receivables or Payables Aging
class AgingBucketItem extends Equatable {
  final String partyId;
  final String partyName;
  final String? phone;
  final String? gstin;
  final double current0to30;
  final double bracket31to60;
  final double bracket61to90;
  final double bracketAbove90;
  final double totalOutstanding;
  final int overdueDays;

  const AgingBucketItem({
    required this.partyId,
    required this.partyName,
    this.phone,
    this.gstin,
    required this.current0to30,
    required this.bracket31to60,
    required this.bracket61to90,
    required this.bracketAbove90,
    required this.totalOutstanding,
    required this.overdueDays,
  });

  @override
  List<Object?> get props => [
        partyId,
        partyName,
        phone,
        gstin,
        current0to30,
        bracket31to60,
        bracket61to90,
        bracketAbove90,
        totalOutstanding,
        overdueDays,
      ];
}

/// Receivables Aging Report (Sundry Debtors)
class ReceivablesAgingReport extends Equatable {
  final String showroomName;
  final DateTime asOfDate;
  final List<AgingBucketItem> customers;
  final double total0to30;
  final double total31to60;
  final double total61to90;
  final double totalAbove90;
  final double grandTotal;

  const ReceivablesAgingReport({
    required this.showroomName,
    required this.asOfDate,
    required this.customers,
    required this.total0to30,
    required this.total31to60,
    required this.total61to90,
    required this.totalAbove90,
    required this.grandTotal,
  });

  @override
  List<Object?> get props => [
        showroomName,
        asOfDate,
        customers,
        total0to30,
        total31to60,
        total61to90,
        totalAbove90,
        grandTotal,
      ];
}

/// Payables Aging Report (Sundry Creditors / OEMs)
class PayablesAgingReport extends Equatable {
  final String showroomName;
  final DateTime asOfDate;
  final List<AgingBucketItem> suppliers;
  final double total0to30;
  final double total31to60;
  final double total61to90;
  final double totalAbove90;
  final double grandTotal;

  const PayablesAgingReport({
    required this.showroomName,
    required this.asOfDate,
    required this.suppliers,
    required this.total0to30,
    required this.total31to60,
    required this.total61to90,
    required this.totalAbove90,
    required this.grandTotal,
  });

  @override
  List<Object?> get props => [
        showroomName,
        asOfDate,
        suppliers,
        total0to30,
        total31to60,
        total61to90,
        totalAbove90,
        grandTotal,
      ];
}
