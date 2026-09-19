import 'package:equatable/equatable.dart';

/// Delivery Challan Domain Entity (Vehicle Handover Document)
class DeliveryChallanEntity extends Equatable {
  final String id;
  final String showroomId;
  final String invoiceId;
  final String challanNumber; // e.g. "IND-MUM-DC-00042"
  final DateTime challanDate;

  // Handover Specs
  final String allocatedVin;
  final double odometerReadingKm;
  final double? batterySocPercent;
  final String? fuelLevel;

  // Compliance & Checklist
  final bool helmetProvided;
  final bool toolkitProvided;
  final bool firstAidKitProvided;
  final bool ownerManualProvided;
  final int spareKeysCount;
  final String? batteryChargerSerial;
  final bool pdiFormSigned;
  final bool customerAcceptanceSigned;

  final String? deliveredBy;
  final String receivedByName;
  final String receivedByRelationship;
  final String? notes;
  final DateTime createdAt;

  // Hydrated helpers
  final String? invoiceNumber;
  final String? customerName;
  final String? modelName;
  final String? variantName;
  final String? colorName;

  const DeliveryChallanEntity({
    required this.id,
    required this.showroomId,
    required this.invoiceId,
    required this.challanNumber,
    required this.challanDate,
    required this.allocatedVin,
    this.odometerReadingKm = 2.0,
    this.batterySocPercent,
    this.fuelLevel,
    this.helmetProvided = true,
    this.toolkitProvided = true,
    this.firstAidKitProvided = true,
    this.ownerManualProvided = true,
    this.spareKeysCount = 2,
    this.batteryChargerSerial,
    this.pdiFormSigned = true,
    this.customerAcceptanceSigned = true,
    this.deliveredBy,
    required this.receivedByName,
    this.receivedByRelationship = 'self',
    this.notes,
    required this.createdAt,
    this.invoiceNumber,
    this.customerName,
    this.modelName,
    this.variantName,
    this.colorName,
  });

  bool get isChecklistComplete =>
      helmetProvided &&
      toolkitProvided &&
      firstAidKitProvided &&
      ownerManualProvided &&
      spareKeysCount >= 2 &&
      pdiFormSigned &&
      customerAcceptanceSigned;

  @override
  List<Object?> get props => [id, challanNumber, invoiceId, allocatedVin];
}
