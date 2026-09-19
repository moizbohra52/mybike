import '../../domain/entities/gate_pass_entity.dart';

/// Gate Pass Data Model
class GatePassModel {
  const GatePassModel._();

  static GatePassEntity fromJson(Map<String, dynamic> json) {
    return GatePassEntity(
      id: json['id'] as String,
      showroomId: json['showroom_id'] as String,
      challanId: json['challan_id'] as String,
      invoiceId: json['invoice_id'] as String,
      gatePassNumber: json['gate_pass_number'] as String,
      issuedAt: DateTime.parse(json['issued_at'] as String),
      vin: json['vin'] as String,
      customerName: json['customer_name'] as String,
      authorizedBy: json['authorized_by'] as String?,
      authorizedByName: json['authorized_by_name'] as String?,
      securityGuardName: json['security_guard_name'] as String?,
      vehicleDepartedAt: json['vehicle_departed_at'] != null
          ? DateTime.parse(json['vehicle_departed_at'] as String)
          : null,
      status: json['status'] as String? ?? 'issued',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> toJson(GatePassEntity entity) {
    return {
      'id': entity.id,
      'showroom_id': entity.showroomId,
      'challan_id': entity.challanId,
      'invoice_id': entity.invoiceId,
      'gate_pass_number': entity.gatePassNumber,
      'issued_at': entity.issuedAt.toIso8601String(),
      'vin': entity.vin,
      'customer_name': entity.customerName,
      'authorized_by': entity.authorizedBy,
      'security_guard_name': entity.securityGuardName,
      'vehicle_departed_at': entity.vehicleDepartedAt?.toIso8601String(),
      'status': entity.status,
      'created_at': entity.createdAt.toIso8601String(),
    };
  }
}
