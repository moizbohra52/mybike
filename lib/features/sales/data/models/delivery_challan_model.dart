import '../../domain/entities/delivery_challan_entity.dart';

/// Delivery Challan Data Model
class DeliveryChallanModel {
  const DeliveryChallanModel._();

  static DeliveryChallanEntity fromJson(Map<String, dynamic> json) {
    return DeliveryChallanEntity(
      id: json['id'] as String,
      showroomId: json['showroom_id'] as String,
      invoiceId: json['invoice_id'] as String,
      challanNumber: json['challan_number'] as String,
      challanDate: DateTime.parse(json['challan_date'] as String),
      allocatedVin: json['allocated_vin'] as String,
      odometerReadingKm: (json['odometer_reading_km'] as num?)?.toDouble() ?? 0.0,
      batterySocPercent: (json['battery_soc_percent'] as num?)?.toDouble(),
      fuelLevel: json['fuel_level'] as String?,
      helmetProvided: json['helmet_provided'] as bool? ?? true,
      toolkitProvided: json['toolkit_provided'] as bool? ?? true,
      firstAidKitProvided: json['first_aid_kit_provided'] as bool? ?? true,
      ownerManualProvided: json['owner_manual_provided'] as bool? ?? true,
      spareKeysCount: (json['spare_keys_count'] as num?)?.toInt() ?? 2,
      batteryChargerSerial: json['battery_charger_serial'] as String?,
      pdiFormSigned: json['pdi_form_signed'] as bool? ?? true,
      customerAcceptanceSigned: json['customer_acceptance_signed'] as bool? ?? true,
      deliveredBy: json['delivered_by'] as String?,
      receivedByName: json['received_by_name'] as String,
      receivedByRelationship: json['received_by_relationship'] as String? ?? 'self',
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      invoiceNumber: json['invoice_number'] as String?,
      customerName: json['customer_name'] as String?,
      modelName: json['model_name'] as String?,
      variantName: json['variant_name'] as String?,
      colorName: json['color_name'] as String?,
    );
  }

  static Map<String, dynamic> toJson(DeliveryChallanEntity entity) {
    return {
      'id': entity.id,
      'showroom_id': entity.showroomId,
      'invoice_id': entity.invoiceId,
      'challan_number': entity.challanNumber,
      'challan_date': entity.challanDate.toIso8601String(),
      'allocated_vin': entity.allocatedVin,
      'odometer_reading_km': entity.odometerReadingKm,
      'battery_soc_percent': entity.batterySocPercent,
      'fuel_level': entity.fuelLevel,
      'helmet_provided': entity.helmetProvided,
      'toolkit_provided': entity.toolkitProvided,
      'first_aid_kit_provided': entity.firstAidKitProvided,
      'owner_manual_provided': entity.ownerManualProvided,
      'spare_keys_count': entity.spareKeysCount,
      'battery_charger_serial': entity.batteryChargerSerial,
      'pdi_form_signed': entity.pdiFormSigned,
      'customer_acceptance_signed': entity.customerAcceptanceSigned,
      'delivered_by': entity.deliveredBy,
      'received_by_name': entity.receivedByName,
      'received_by_relationship': entity.receivedByRelationship,
      'notes': entity.notes,
      'created_at': entity.createdAt.toIso8601String(),
    };
  }
}
