import 'package:equatable/equatable.dart';

/// Vehicle Variant Domain Entity (dual petrol & electric specs + statutory pricing)
class VehicleVariantEntity extends Equatable {
  final String id;
  final String modelId;
  final String name;
  final String code;

  // Petrol Specific Specifications
  final double? engineCc;
  final String? maxPower;
  final String? maxTorque;
  final double? fuelCapacityLiters;
  final double? mileageKmpl;
  final String? transmission;
  final String? emissionNorm;

  // Electric Specific Specifications
  final double? batteryCapacityKwh;
  final double? motorPowerKw;
  final int? rangeKm;
  final int? trueRangeKm;
  final double? chargingTimeHours;
  final bool fastCharging;
  final int? batteryWarrantyYears;

  // Statutory Pricing Breakdown (INR)
  final double exShowroomPrice;
  final double gstRate; // e.g. 28.0 for Petrol, 5.0 for EV
  final double cessRate; // e.g. 3.0 for >350cc, 0.0 otherwise
  final double rtoCharges;
  final double insuranceCharges;
  final double otherCharges; // Accessories/Logistics/Handling

  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleVariantEntity({
    required this.id,
    required this.modelId,
    required this.name,
    required this.code,
    this.engineCc,
    this.maxPower,
    this.maxTorque,
    this.fuelCapacityLiters,
    this.mileageKmpl,
    this.transmission,
    this.emissionNorm,
    this.batteryCapacityKwh,
    this.motorPowerKw,
    this.rangeKm,
    this.trueRangeKm,
    this.chargingTimeHours,
    this.fastCharging = false,
    this.batteryWarrantyYears,
    required this.exShowroomPrice,
    this.gstRate = 28.0,
    this.cessRate = 0.0,
    this.rtoCharges = 0.0,
    this.insuranceCharges = 0.0,
    this.otherCharges = 0.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Computed Estimated On-Road Price (INR)
  double get estimatedOnRoadPrice =>
      exShowroomPrice + rtoCharges + insuranceCharges + otherCharges;

  /// Computed GST amount included within ex-showroom (or applied on base)
  double get estimatedGstAmount {
    final totalTaxRate = gstRate + cessRate;
    if (totalTaxRate <= 0) return 0.0;
    // In India automotive invoicing: Ex-Showroom = Base Price * (1 + TaxRate/100)
    final basePrice = exShowroomPrice / (1 + (totalTaxRate / 100));
    return basePrice * (gstRate / 100);
  }

  /// Computed CESS amount
  double get estimatedCessAmount {
    final totalTaxRate = gstRate + cessRate;
    if (totalTaxRate <= 0 || cessRate <= 0) return 0.0;
    final basePrice = exShowroomPrice / (1 + (totalTaxRate / 100));
    return basePrice * (cessRate / 100);
  }

  VehicleVariantEntity copyWith({
    String? id,
    String? modelId,
    String? name,
    String? code,
    double? engineCc,
    String? maxPower,
    String? maxTorque,
    double? fuelCapacityLiters,
    double? mileageKmpl,
    String? transmission,
    String? emissionNorm,
    double? batteryCapacityKwh,
    double? motorPowerKw,
    int? rangeKm,
    int? trueRangeKm,
    double? chargingTimeHours,
    bool? fastCharging,
    int? batteryWarrantyYears,
    double? exShowroomPrice,
    double? gstRate,
    double? cessRate,
    double? rtoCharges,
    double? insuranceCharges,
    double? otherCharges,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleVariantEntity(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      name: name ?? this.name,
      code: code ?? this.code,
      engineCc: engineCc ?? this.engineCc,
      maxPower: maxPower ?? this.maxPower,
      maxTorque: maxTorque ?? this.maxTorque,
      fuelCapacityLiters: fuelCapacityLiters ?? this.fuelCapacityLiters,
      mileageKmpl: mileageKmpl ?? this.mileageKmpl,
      transmission: transmission ?? this.transmission,
      emissionNorm: emissionNorm ?? this.emissionNorm,
      batteryCapacityKwh: batteryCapacityKwh ?? this.batteryCapacityKwh,
      motorPowerKw: motorPowerKw ?? this.motorPowerKw,
      rangeKm: rangeKm ?? this.rangeKm,
      trueRangeKm: trueRangeKm ?? this.trueRangeKm,
      chargingTimeHours: chargingTimeHours ?? this.chargingTimeHours,
      fastCharging: fastCharging ?? this.fastCharging,
      batteryWarrantyYears: batteryWarrantyYears ?? this.batteryWarrantyYears,
      exShowroomPrice: exShowroomPrice ?? this.exShowroomPrice,
      gstRate: gstRate ?? this.gstRate,
      cessRate: cessRate ?? this.cessRate,
      rtoCharges: rtoCharges ?? this.rtoCharges,
      insuranceCharges: insuranceCharges ?? this.insuranceCharges,
      otherCharges: otherCharges ?? this.otherCharges,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        modelId,
        name,
        code,
        engineCc,
        maxPower,
        maxTorque,
        fuelCapacityLiters,
        mileageKmpl,
        transmission,
        emissionNorm,
        batteryCapacityKwh,
        motorPowerKw,
        rangeKm,
        trueRangeKm,
        chargingTimeHours,
        fastCharging,
        batteryWarrantyYears,
        exShowroomPrice,
        gstRate,
        cessRate,
        rtoCharges,
        insuranceCharges,
        otherCharges,
        isActive,
        createdAt,
        updatedAt,
      ];
}
