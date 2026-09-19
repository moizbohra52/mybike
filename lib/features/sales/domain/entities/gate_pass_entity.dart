import 'package:equatable/equatable.dart';

/// Gate Pass Domain Entity (Showroom Security Clearance)
class GatePassEntity extends Equatable {
  final String id;
  final String showroomId;
  final String challanId;
  final String invoiceId;
  final String gatePassNumber; // e.g. "IND-MUM-GP-00042"
  final DateTime issuedAt;

  final String vin;
  final String customerName;
  final String? authorizedBy;
  final String? authorizedByName;
  final String? securityGuardName;
  final DateTime? vehicleDepartedAt;
  final String status; // 'issued', 'departed', 'void'
  final DateTime createdAt;

  const GatePassEntity({
    required this.id,
    required this.showroomId,
    required this.challanId,
    required this.invoiceId,
    required this.gatePassNumber,
    required this.issuedAt,
    required this.vin,
    required this.customerName,
    this.authorizedBy,
    this.authorizedByName,
    this.securityGuardName,
    this.vehicleDepartedAt,
    this.status = 'issued',
    required this.createdAt,
  });

  bool get isDeparted => status == 'departed';
  bool get isIssued => status == 'issued';

  @override
  List<Object?> get props => [id, gatePassNumber, challanId, vin, status];
}
