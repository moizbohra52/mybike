import 'package:equatable/equatable.dart';

/// Party Outstanding Domain Entity (Receivables / Payables Aging)
///
/// Tracks outstanding balances for Customers (Sundry Debtors) and
/// Suppliers/OEMs (Sundry Creditors) with aging breakdown buckets.
class PartyOutstandingEntity extends Equatable {
  final String partyId;
  final String partyName;
  final String partyType; // 'customer' (Receivable / Debtor) or 'supplier' (Payable / Creditor)
  final String? phone;
  final String? email;
  final String? showroomId;
  final String? showroomName;

  final double totalInvoiced;
  final double totalSettled;
  final double outstandingBalance;

  // Aging Analysis Buckets (in Days)
  final double bucket0To30;
  final double bucket31To60;
  final double bucket61To90;
  final double bucket90Plus;

  final DateTime? oldestInvoiceDate;
  final DateTime? latestInvoiceDate;

  const PartyOutstandingEntity({
    required this.partyId,
    required this.partyName,
    required this.partyType,
    this.phone,
    this.email,
    this.showroomId,
    this.showroomName,
    required this.totalInvoiced,
    required this.totalSettled,
    required this.outstandingBalance,
    this.bucket0To30 = 0.0,
    this.bucket31To60 = 0.0,
    this.bucket61To90 = 0.0,
    this.bucket90Plus = 0.0,
    this.oldestInvoiceDate,
    this.latestInvoiceDate,
  });

  bool get isReceivable => partyType == 'customer';
  bool get isPayable => partyType == 'supplier' || partyType == 'oem';
  bool get hasOverdue => (bucket31To60 + bucket61To90 + bucket90Plus) > 0;

  @override
  List<Object?> get props => [
        partyId,
        partyName,
        partyType,
        phone,
        email,
        showroomId,
        totalInvoiced,
        totalSettled,
        outstandingBalance,
        bucket0To30,
        bucket31To60,
        bucket61To90,
        bucket90Plus,
        oldestInvoiceDate,
        latestInvoiceDate,
      ];
}
