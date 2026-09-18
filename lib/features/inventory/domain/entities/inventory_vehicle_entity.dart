import 'package:equatable/equatable.dart';

/// Serialized Vehicle Inventory Unit Domain Entity
class InventoryVehicleEntity extends Equatable {
  final String id;
  final String showroomId;
  final String variantId;
  final String colorId;
  final String vin; // 17-character VIN/Chassis number
  final String? engineNumber; // Petrol
  final String? motorNumber; // Electric EV
  final String? batterySerialNumber; // Electric EV
  final String? keyNumber;
  final String status; // 'in_stock', 'booked', 'allocated', 'sold', 'in_transit', 'delivered', 'damaged'
  final double purchaseCost;
  final DateTime receivedDate;
  final String mfgYearMonth; // e.g. "2026-01"
  final double? batteryHealthPercentage; // e.g. 100.0
  final double odometerReadingKm;
  final String locationInShowroom;
  final String pdiStatus; // 'pending', 'passed', 'failed'
  final String? pdiNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryVehicleEntity({
    required this.id,
    required this.showroomId,
    required this.variantId,
    required this.colorId,
    required this.vin,
    this.engineNumber,
    this.motorNumber,
    this.batterySerialNumber,
    this.keyNumber,
    this.status = 'in_stock',
    this.purchaseCost = 0.0,
    required this.receivedDate,
    this.mfgYearMonth = '2026-01',
    this.batteryHealthPercentage,
    this.odometerReadingKm = 0.0,
    this.locationInShowroom = 'Main Display Area',
    this.pdiStatus = 'pending',
    this.pdiNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAvailable => status == 'in_stock';
  bool get isBooked => status == 'booked' || status == 'allocated';
  bool get isSold => status == 'sold' || status == 'delivered';
  bool get isInTransit => status == 'in_transit';
  bool get isPdiPassed => pdiStatus == 'passed';
  bool get isElectric => motorNumber != null || batterySerialNumber != null;
  bool get isPetrol => engineNumber != null;

  InventoryVehicleEntity copyWith({
    String? id,
    String? showroomId,
    String? variantId,
    String? colorId,
    String? vin,
    String? engineNumber,
    String? motorNumber,
    String? batterySerialNumber,
    String? keyNumber,
    String? status,
    double? purchaseCost,
    DateTime? receivedDate,
    String? mfgYearMonth,
    double? batteryHealthPercentage,
    double? odometerReadingKm,
    String? locationInShowroom,
    String? pdiStatus,
    String? pdiNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryVehicleEntity(
      id: id ?? this.id,
      showroomId: showroomId ?? this.showroomId,
      variantId: variantId ?? this.variantId,
      colorId: colorId ?? this.colorId,
      vin: vin ?? this.vin,
      engineNumber: engineNumber ?? this.engineNumber,
      motorNumber: motorNumber ?? this.motorNumber,
      batterySerialNumber: batterySerialNumber ?? this.batterySerialNumber,
      keyNumber: keyNumber ?? this.keyNumber,
      status: status ?? this.status,
      purchaseCost: purchaseCost ?? this.purchaseCost,
      receivedDate: receivedDate ?? this.receivedDate,
      mfgYearMonth: mfgYearMonth ?? this.mfgYearMonth,
      batteryHealthPercentage: batteryHealthPercentage ?? this.batteryHealthPercentage,
      odometerReadingKm: odometerReadingKm ?? this.odometerReadingKm,
      locationInShowroom: locationInShowroom ?? this.locationInShowroom,
      pdiStatus: pdiStatus ?? this.pdiStatus,
      pdiNotes: pdiNotes ?? this.pdiNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        showroomId,
        variantId,
        colorId,
        vin,
        engineNumber,
        motorNumber,
        batterySerialNumber,
        keyNumber,
        status,
        purchaseCost,
        receivedDate,
        mfgYearMonth,
        batteryHealthPercentage,
        odometerReadingKm,
        locationInShowroom,
        pdiStatus,
        pdiNotes,
        createdAt,
        updatedAt,
      ];
}
