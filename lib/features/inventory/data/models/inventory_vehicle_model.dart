import '../../domain/entities/inventory_vehicle_entity.dart';

/// Inventory Vehicle Data Model with JSON serialization
class InventoryVehicleModel extends InventoryVehicleEntity {
  const InventoryVehicleModel({
    required super.id,
    required super.showroomId,
    required super.variantId,
    required super.colorId,
    required super.vin,
    super.engineNumber,
    super.motorNumber,
    super.batterySerialNumber,
    super.keyNumber,
    super.status = 'in_stock',
    super.purchaseCost = 0.0,
    required super.receivedDate,
    super.mfgYearMonth = '2026-01',
    super.batteryHealthPercentage,
    super.odometerReadingKm = 0.0,
    super.locationInShowroom = 'Main Display Area',
    super.pdiStatus = 'pending',
    super.pdiNotes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InventoryVehicleModel.fromJson(Map<String, dynamic> json) {
    return InventoryVehicleModel(
      id: json['id'] as String,
      showroomId: json['showroom_id'] as String,
      variantId: json['variant_id'] as String,
      colorId: json['color_id'] as String,
      vin: json['vin'] as String,
      engineNumber: json['engine_number'] as String?,
      motorNumber: json['motor_number'] as String?,
      batterySerialNumber: json['battery_serial_number'] as String?,
      keyNumber: json['key_number'] as String?,
      status: json['status'] as String? ?? 'in_stock',
      purchaseCost: (json['purchase_cost'] as num?)?.toDouble() ?? 0.0,
      receivedDate: json['received_date'] != null
          ? DateTime.parse(json['received_date'] as String)
          : DateTime.now(),
      mfgYearMonth: json['mfg_year_month'] as String? ?? '2026-01',
      batteryHealthPercentage: (json['battery_health_percentage'] as num?)?.toDouble(),
      odometerReadingKm: (json['odometer_reading_km'] as num?)?.toDouble() ?? 0.0,
      locationInShowroom: json['location_in_showroom'] as String? ?? 'Main Display Area',
      pdiStatus: json['pdi_status'] as String? ?? 'pending',
      pdiNotes: json['pdi_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'showroom_id': showroomId,
      'variant_id': variantId,
      'color_id': colorId,
      'vin': vin,
      'engine_number': engineNumber,
      'motor_number': motorNumber,
      'battery_serial_number': batterySerialNumber,
      'key_number': keyNumber,
      'status': status,
      'purchase_cost': purchaseCost,
      'received_date': receivedDate.toIso8601String().split('T').first,
      'mfg_year_month': mfgYearMonth,
      'battery_health_percentage': batteryHealthPercentage,
      'odometer_reading_km': odometerReadingKm,
      'location_in_showroom': locationInShowroom,
      'pdi_status': pdiStatus,
      'pdi_notes': pdiNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory InventoryVehicleModel.fromEntity(InventoryVehicleEntity entity) {
    return InventoryVehicleModel(
      id: entity.id,
      showroomId: entity.showroomId,
      variantId: entity.variantId,
      colorId: entity.colorId,
      vin: entity.vin,
      engineNumber: entity.engineNumber,
      motorNumber: entity.motorNumber,
      batterySerialNumber: entity.batterySerialNumber,
      keyNumber: entity.keyNumber,
      status: entity.status,
      purchaseCost: entity.purchaseCost,
      receivedDate: entity.receivedDate,
      mfgYearMonth: entity.mfgYearMonth,
      batteryHealthPercentage: entity.batteryHealthPercentage,
      odometerReadingKm: entity.odometerReadingKm,
      locationInShowroom: entity.locationInShowroom,
      pdiStatus: entity.pdiStatus,
      pdiNotes: entity.pdiNotes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
