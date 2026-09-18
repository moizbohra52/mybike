import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import 'supabase_service.dart';
import '../../features/vehicles/domain/entities/brand_entity.dart';
import '../../features/vehicles/domain/entities/vehicle_model_entity.dart';
import '../../features/vehicles/domain/entities/vehicle_variant_entity.dart';
import '../../features/vehicles/domain/entities/vehicle_color_entity.dart';
import '../../features/vehicles/domain/entities/vehicle_catalog_item.dart';
import '../../features/vehicles/data/models/brand_model.dart';
import '../../features/vehicles/data/models/vehicle_model_model.dart';
import '../../features/vehicles/data/models/vehicle_variant_model.dart';
import '../../features/vehicles/data/models/vehicle_color_model.dart';

/// Vehicle Master Service handling Brands, Models, Variants, and Colors
class VehicleMasterService {
  VehicleMasterService._();
  static final VehicleMasterService instance = VehicleMasterService._();

  // In-memory dev cache
  List<BrandModel>? _devBrands;
  List<VehicleModelModel>? _devModels;
  List<VehicleVariantModel>? _devVariants;
  List<VehicleColorModel>? _devColors;

  void _initDevData() {
    if (_devBrands != null) return;
    final now = DateTime.now();

    // 1. Brands
    _devBrands = [
      BrandModel(
        id: 'b-001',
        name: 'Honda 2-Wheelers',
        code: 'HONDA',
        countryOfOrigin: 'Japan',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 300)),
        updatedAt: now,
      ),
      BrandModel(
        id: 'b-002',
        name: 'Ather Energy',
        code: 'ATHER',
        countryOfOrigin: 'India',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 280)),
        updatedAt: now,
      ),
      BrandModel(
        id: 'b-003',
        name: 'TVS Motor Company',
        code: 'TVS',
        countryOfOrigin: 'India',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 250)),
        updatedAt: now,
      ),
      BrandModel(
        id: 'b-004',
        name: 'Royal Enfield',
        code: 'RE',
        countryOfOrigin: 'India',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 220)),
        updatedAt: now,
      ),
      BrandModel(
        id: 'b-005',
        name: 'Hero MotoCorp',
        code: 'HERO',
        countryOfOrigin: 'India',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 180)),
        updatedAt: now,
      ),
    ];

    // 2. Models
    _devModels = [
      VehicleModelModel(
        id: 'm-001',
        brandId: 'b-001',
        name: "CB350 H'ness",
        type: 'petrol',
        bodyType: 'cruiser',
        description: 'Modern-classic cruiser powered by a refined 348cc counterbalanced engine with Honda Selectable Torque Control (HSTC).',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now,
      ),
      VehicleModelModel(
        id: 'm-002',
        brandId: 'b-002',
        name: '450X Gen 3',
        type: 'electric',
        bodyType: 'scooter',
        description: 'Performance electric scooter with Warp mode, Google Maps on dashboard, and aluminium chassis.',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 190)),
        updatedAt: now,
      ),
      VehicleModelModel(
        id: 'm-003',
        brandId: 'b-003',
        name: 'Apache RTR 310',
        type: 'petrol',
        bodyType: 'sports',
        description: 'Streetfighter motorcycle with bi-directional quickshifter, climate control seat, and cornering ABS.',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 150)),
        updatedAt: now,
      ),
      VehicleModelModel(
        id: 'm-004',
        brandId: 'b-004',
        name: 'Hunter 350',
        type: 'petrol',
        bodyType: 'commuter',
        description: 'Compact, agile roadster built on the J-series platform tailored for urban commutes.',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 140)),
        updatedAt: now,
      ),
      VehicleModelModel(
        id: 'm-005',
        brandId: 'b-002',
        name: 'Rizta',
        type: 'electric',
        bodyType: 'scooter',
        description: 'Family electric scooter featuring the largest seat in the segment, SkidControl, and 56L total storage.',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),
      VehicleModelModel(
        id: 'm-006',
        brandId: 'b-003',
        name: 'iQube Electric',
        type: 'electric',
        bodyType: 'scooter',
        description: 'Reliable, silent electric scooter for everyday city commuting with TVS SmartXonnect.',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now,
      ),
      VehicleModelModel(
        id: 'm-007',
        brandId: 'b-005',
        name: 'Splendor+ XTEC',
        type: 'petrol',
        bodyType: 'commuter',
        description: "India's highest selling commuter motorcycle equipped with digital meter, Bluetooth, and i3S technology.",
        isActive: true,
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now,
      ),
    ];

    // 3. Variants
    _devVariants = [
      // CB350 H'ness
      VehicleVariantModel(
        id: 'v-001',
        modelId: 'm-001',
        name: 'DLX',
        code: 'CB350-DLX',
        engineCc: 348.36,
        maxPower: '20.8 bhp @ 5500 rpm',
        maxTorque: '30 Nm @ 3000 rpm',
        fuelCapacityLiters: 15.0,
        mileageKmpl: 38.5,
        transmission: '5-Speed Manual with Assist/Slipper Clutch',
        emissionNorm: 'BS6 Phase 2',
        exShowroomPrice: 209857.0,
        gstRate: 28.0,
        cessRate: 0.0,
        rtoCharges: 21500.0,
        insuranceCharges: 11200.0,
        otherCharges: 2500.0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now,
      ),
      VehicleVariantModel(
        id: 'v-002',
        modelId: 'm-001',
        name: 'DLX Pro',
        code: 'CB350-DLX-PRO',
        engineCc: 348.36,
        maxPower: '20.8 bhp @ 5500 rpm',
        maxTorque: '30 Nm @ 3000 rpm',
        fuelCapacityLiters: 15.0,
        mileageKmpl: 38.5,
        transmission: '5-Speed Manual with Assist/Slipper Clutch',
        emissionNorm: 'BS6 Phase 2',
        exShowroomPrice: 214856.0,
        gstRate: 28.0,
        cessRate: 0.0,
        rtoCharges: 22000.0,
        insuranceCharges: 11400.0,
        otherCharges: 2500.0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 195)),
        updatedAt: now,
      ),
      VehicleVariantModel(
        id: 'v-003',
        modelId: 'm-001',
        name: 'Legacy Edition',
        code: 'CB350-LEGACY',
        engineCc: 348.36,
        maxPower: '20.8 bhp @ 5500 rpm',
        maxTorque: '30 Nm @ 3000 rpm',
        fuelCapacityLiters: 15.0,
        mileageKmpl: 38.5,
        transmission: '5-Speed Manual',
        emissionNorm: 'BS6 Phase 2',
        exShowroomPrice: 219800.0,
        gstRate: 28.0,
        cessRate: 0.0,
        rtoCharges: 22500.0,
        insuranceCharges: 11600.0,
        otherCharges: 2500.0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 180)),
        updatedAt: now,
      ),

      // Ather 450X
      VehicleVariantModel(
        id: 'v-004',
        modelId: 'm-002',
        name: '2.9 kWh Base',
        code: 'ATH-450X-29',
        batteryCapacityKwh: 2.9,
        motorPowerKw: 6.0,
        rangeKm: 111,
        trueRangeKm: 90,
        chargingTimeHours: 5.75,
        fastCharging: true,
        batteryWarrantyYears: 3,
        exShowroomPrice: 140599.0,
        gstRate: 5.0,
        cessRate: 0.0,
        rtoCharges: 2500.0,
        insuranceCharges: 6800.0,
        otherCharges: 3000.0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 190)),
        updatedAt: now,
      ),
      VehicleVariantModel(
        id: 'v-005',
        modelId: 'm-002',
        name: '3.7 kWh Pro',
        code: 'ATH-450X-37-PRO',
        batteryCapacityKwh: 3.7,
        motorPowerKw: 6.4,
        rangeKm: 150,
        trueRangeKm: 110,
        chargingTimeHours: 4.5,
        fastCharging: true,
        batteryWarrantyYears: 5,
        exShowroomPrice: 154999.0,
        gstRate: 5.0,
        cessRate: 0.0,
        rtoCharges: 2500.0,
        insuranceCharges: 7200.0,
        otherCharges: 3000.0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 185)),
        updatedAt: now,
      ),

      // TVS Apache RTR 310
      VehicleVariantModel(
        id: 'v-006',
        modelId: 'm-003',
        name: 'Arsenal Black Standard',
        code: 'RTR310-STD',
        engineCc: 312.12,
        maxPower: '35.6 bhp @ 9700 rpm',
        maxTorque: '28.7 Nm @ 6650 rpm',
        fuelCapacityLiters: 11.0,
        mileageKmpl: 30.0,
        transmission: '6-Speed with Slipper Clutch',
        emissionNorm: 'BS6 Phase 2',
        exShowroomPrice: 242990.0,
        gstRate: 28.0,
        cessRate: 0.0,
        rtoCharges: 26500.0,
        insuranceCharges: 12500.0,
        otherCharges: 3000.0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 150)),
        updatedAt: now,
      ),
      VehicleVariantModel(
        id: 'v-007',
        modelId: 'm-003',
        name: 'Dynamic Pro BTO',
        code: 'RTR310-BTO',
        engineCc: 312.12,
        maxPower: '35.6 bhp @ 9700 rpm',
        maxTorque: '28.7 Nm @ 6650 rpm',
        fuelCapacityLiters: 11.0,
        mileageKmpl: 30.0,
        transmission: '6-Speed with Bi-Directional Quickshifter',
        emissionNorm: 'BS6 Phase 2',
        exShowroomPrice: 260990.0,
        gstRate: 28.0,
        cessRate: 0.0,
        rtoCharges: 28000.0,
        insuranceCharges: 13000.0,
        otherCharges: 3500.0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 145)),
        updatedAt: now,
      ),

      // Royal Enfield Hunter 350
      VehicleVariantModel(
        id: 'v-008',
        modelId: 'm-004',
        name: 'Retro Factory',
        code: 'HNTR-RETRO',
        engineCc: 349.0,
        maxPower: '20.2 bhp @ 6100 rpm',
        maxTorque: '27 Nm @ 4000 rpm',
        fuelCapacityLiters: 13.0,
        mileageKmpl: 36.2,
        transmission: '5-Speed Manual',
        emissionNorm: 'BS6 Phase 2',
        exShowroomPrice: 149900.0,
        gstRate: 28.0,
        cessRate: 0.0,
        rtoCharges: 16500.0,
        insuranceCharges: 9800.0,
        otherCharges: 2000.0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 140)),
        updatedAt: now,
      ),
      VehicleVariantModel(
        id: 'v-009',
        modelId: 'm-004',
        name: 'Metro Dapper',
        code: 'HNTR-METRO',
        engineCc: 349.0,
        maxPower: '20.2 bhp @ 6100 rpm',
        maxTorque: '27 Nm @ 4000 rpm',
        fuelCapacityLiters: 13.0,
        mileageKmpl: 36.2,
        transmission: '5-Speed Manual',
        emissionNorm: 'BS6 Phase 2',
        exShowroomPrice: 169656.0,
        gstRate: 28.0,
        cessRate: 0.0,
        rtoCharges: 18500.0,
        insuranceCharges: 10400.0,
        otherCharges: 2000.0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 135)),
        updatedAt: now,
      ),

      // Ather Rizta
      VehicleVariantModel(
        id: 'v-010',
        modelId: 'm-005',
        name: 'Rizta S 2.9 kWh',
        code: 'RIZTA-S-29',
        batteryCapacityKwh: 2.9,
        motorPowerKw: 4.3,
        rangeKm: 123,
        trueRangeKm: 105,
        chargingTimeHours: 6.4,
        fastCharging: true,
        batteryWarrantyYears: 3,
        exShowroomPrice: 109999.0,
        gstRate: 5.0,
        cessRate: 0.0,
        rtoCharges: 2000.0,
        insuranceCharges: 5800.0,
        otherCharges: 2500.0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),
      VehicleVariantModel(
        id: 'v-011',
        modelId: 'm-005',
        name: 'Rizta Z 3.7 kWh',
        code: 'RIZTA-Z-37',
        batteryCapacityKwh: 3.7,
        motorPowerKw: 4.3,
        rangeKm: 159,
        trueRangeKm: 125,
        chargingTimeHours: 4.5,
        fastCharging: true,
        batteryWarrantyYears: 5,
        exShowroomPrice: 144999.0,
        gstRate: 5.0,
        cessRate: 0.0,
        rtoCharges: 2200.0,
        insuranceCharges: 6800.0,
        otherCharges: 2500.0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 55)),
        updatedAt: now,
      ),

      // TVS iQube
      VehicleVariantModel(
        id: 'v-012',
        modelId: 'm-006',
        name: 'iQube Standard 3.4 kWh',
        code: 'IQUBE-34',
        batteryCapacityKwh: 3.4,
        motorPowerKw: 4.4,
        rangeKm: 100,
        trueRangeKm: 75,
        chargingTimeHours: 4.5,
        fastCharging: false,
        batteryWarrantyYears: 3,
        exShowroomPrice: 117299.0,
        gstRate: 5.0,
        cessRate: 0.0,
        rtoCharges: 2000.0,
        insuranceCharges: 6000.0,
        otherCharges: 2500.0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now,
      ),

      // Hero Splendor+ XTEC
      VehicleVariantModel(
        id: 'v-013',
        modelId: 'm-007',
        name: 'Drum Self Cast',
        code: 'SPL-XTEC-DRUM',
        engineCc: 97.2,
        maxPower: '7.9 bhp @ 8000 rpm',
        maxTorque: '8.05 Nm @ 6000 rpm',
        fuelCapacityLiters: 9.8,
        mileageKmpl: 68.0,
        transmission: '4-Speed Manual',
        emissionNorm: 'BS6 Phase 2',
        exShowroomPrice: 79911.0,
        gstRate: 28.0,
        cessRate: 0.0,
        rtoCharges: 9000.0,
        insuranceCharges: 6200.0,
        otherCharges: 1500.0,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now,
      ),
    ];

    // 4. Colors
    _devColors = [
      // CB350 H'ness
      VehicleColorModel(
        id: 'c-001',
        modelId: 'm-001',
        name: 'Precious Red Metallic',
        code: 'RED-MET',
        hexCode: '#9B111E',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      VehicleColorModel(
        id: 'c-002',
        modelId: 'm-001',
        name: 'Pearl Nightstar Black',
        code: 'BLK-PNT',
        hexCode: '#111111',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      VehicleColorModel(
        id: 'c-003',
        modelId: 'm-001',
        name: 'Matte Marshal Green Metallic',
        code: 'GRN-MET',
        hexCode: '#2F4F4F',
        additionalPrice: 1500.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Ather 450X
      VehicleColorModel(
        id: 'c-004',
        modelId: 'm-002',
        name: 'Space Grey',
        code: 'GRY-SPC',
        hexCode: '#4A4E51',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      VehicleColorModel(
        id: 'c-005',
        modelId: 'm-002',
        name: 'True Red',
        code: 'RED-TRU',
        hexCode: '#E50914',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      VehicleColorModel(
        id: 'c-006',
        modelId: 'm-002',
        name: 'Salt Green',
        code: 'GRN-SLT',
        hexCode: '#8CAFA0',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      VehicleColorModel(
        id: 'c-007',
        modelId: 'm-002',
        name: 'Lunar Grey',
        code: 'GRY-LUN',
        hexCode: '#DCDCDC',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // TVS Apache RTR 310
      VehicleColorModel(
        id: 'c-008',
        modelId: 'm-003',
        name: 'Arsenal Black',
        code: 'BLK-ARS',
        hexCode: '#1A1A1A',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      VehicleColorModel(
        id: 'c-009',
        modelId: 'm-003',
        name: 'Fury Yellow',
        code: 'YEL-FUR',
        hexCode: '#F5C518',
        additionalPrice: 2000.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      VehicleColorModel(
        id: 'c-010',
        modelId: 'm-003',
        name: 'Sepang Blue',
        code: 'BLU-SEP',
        hexCode: '#0047AB',
        additionalPrice: 3000.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Royal Enfield Hunter 350
      VehicleColorModel(
        id: 'c-011',
        modelId: 'm-004',
        name: 'Dapper Ash',
        code: 'ASH-DAP',
        hexCode: '#708090',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      VehicleColorModel(
        id: 'c-012',
        modelId: 'm-004',
        name: 'Rebel Blue',
        code: 'BLU-REB',
        hexCode: '#1E3F66',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Ather Rizta
      VehicleColorModel(
        id: 'c-013',
        modelId: 'm-005',
        name: 'Pangong Blue',
        code: 'BLU-PNG',
        hexCode: '#5B92E5',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      VehicleColorModel(
        id: 'c-014',
        modelId: 'm-005',
        name: 'Cardamom Green',
        code: 'GRN-CRD',
        hexCode: '#6B8E23',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // TVS iQube
      VehicleColorModel(
        id: 'c-015',
        modelId: 'm-006',
        name: 'Shining Red',
        code: 'RED-SHN',
        hexCode: '#C8102E',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      VehicleColorModel(
        id: 'c-016',
        modelId: 'm-006',
        name: 'Titanium Grey',
        code: 'GRY-TTN',
        hexCode: '#53565A',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),

      // Hero Splendor+ XTEC
      VehicleColorModel(
        id: 'c-017',
        modelId: 'm-007',
        name: 'Sparkling Alpha Blue',
        code: 'BLU-ALP',
        hexCode: '#1034A6',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      VehicleColorModel(
        id: 'c-018',
        modelId: 'm-007',
        name: 'Black with Silver Graphics',
        code: 'BLK-SLV',
        hexCode: '#222222',
        additionalPrice: 0.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // ─────────────────────────────────────────────
  // 1. BRANDS
  // ─────────────────────────────────────────────

  Future<List<BrandEntity>> fetchBrands({bool? isActive}) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        var query = SupabaseService.client!.from('brands').select();
        if (isActive != null) {
          query = query.eq('is_active', isActive);
        }
        final data = await query.order('name', ascending: true);
        return (data as List).map((row) => BrandModel.fromJson(row)).toList();
      } catch (e) {
        debugPrint('Supabase fetchBrands error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    var list = _devBrands!;
    if (isActive != null) {
      list = list.where((b) => b.isActive == isActive).toList();
    }
    return List.unmodifiable(list);
  }

  Future<BrandEntity> createBrand(BrandEntity brand) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final model = BrandModel.fromEntity(brand);
        final response = await SupabaseService.client!
            .from('brands')
            .insert(model.toJson())
            .select()
            .single();
        return BrandModel.fromJson(response);
      } catch (e) {
        debugPrint('Supabase createBrand error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    final model = BrandModel.fromEntity(brand);
    _devBrands!.add(model);
    return model;
  }

  Future<BrandEntity> updateBrand(BrandEntity brand) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final model = BrandModel.fromEntity(brand);
        final response = await SupabaseService.client!
            .from('brands')
            .update(model.toJson())
            .eq('id', brand.id)
            .select()
            .single();
        return BrandModel.fromJson(response);
      } catch (e) {
        debugPrint('Supabase updateBrand error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    final index = _devBrands!.indexWhere((b) => b.id == brand.id);
    if (index != -1) {
      _devBrands![index] = BrandModel.fromEntity(brand);
    }
    return brand;
  }

  Future<void> deleteBrand(String brandId) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('brands').delete().eq('id', brandId);
        return;
      } catch (e) {
        debugPrint('Supabase deleteBrand error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    _devBrands!.removeWhere((b) => b.id == brandId);
  }

  // ─────────────────────────────────────────────
  // 2. VEHICLE MODELS
  // ─────────────────────────────────────────────

  Future<List<VehicleModelEntity>> fetchModels({
    String? brandId,
    String? type,
    String? bodyType,
    String? search,
    bool? isActive,
  }) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        var query = SupabaseService.client!.from('vehicle_models').select();
        if (brandId != null) query = query.eq('brand_id', brandId);
        if (type != null) query = query.eq('type', type);
        if (bodyType != null) query = query.eq('body_type', bodyType);
        if (isActive != null) query = query.eq('is_active', isActive);
        if (search != null && search.isNotEmpty) {
          query = query.ilike('name', '%$search%');
        }

        final data = await query.order('name', ascending: true);
        return (data as List).map((row) => VehicleModelModel.fromJson(row)).toList();
      } catch (e) {
        debugPrint('Supabase fetchModels error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    var list = _devModels!;
    if (brandId != null) {
      list = list.where((m) => m.brandId == brandId).toList();
    }
    if (type != null) {
      list = list.where((m) => m.type.toLowerCase() == type.toLowerCase()).toList();
    }
    if (bodyType != null) {
      list = list.where((m) => m.bodyType.toLowerCase() == bodyType.toLowerCase()).toList();
    }
    if (isActive != null) {
      list = list.where((m) => m.isActive == isActive).toList();
    }
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      list = list.where((m) => m.name.toLowerCase().contains(s)).toList();
    }
    return List.unmodifiable(list);
  }

  Future<VehicleModelEntity?> fetchModelById(String id) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final data = await SupabaseService.client!
            .from('vehicle_models')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (data != null) return VehicleModelModel.fromJson(data);
      } catch (e) {
        debugPrint('Supabase fetchModelById error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    final index = _devModels!.indexWhere((m) => m.id == id);
    return index != -1 ? _devModels![index] : null;
  }

  Future<VehicleModelEntity> createModel(VehicleModelEntity model) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final m = VehicleModelModel.fromEntity(model);
        final response = await SupabaseService.client!
            .from('vehicle_models')
            .insert(m.toJson())
            .select()
            .single();
        return VehicleModelModel.fromJson(response);
      } catch (e) {
        debugPrint('Supabase createModel error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    final m = VehicleModelModel.fromEntity(model);
    _devModels!.add(m);
    return m;
  }

  Future<VehicleModelEntity> updateModel(VehicleModelEntity model) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final m = VehicleModelModel.fromEntity(model);
        final response = await SupabaseService.client!
            .from('vehicle_models')
            .update(m.toJson())
            .eq('id', model.id)
            .select()
            .single();
        return VehicleModelModel.fromJson(response);
      } catch (e) {
        debugPrint('Supabase updateModel error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    final index = _devModels!.indexWhere((m) => m.id == model.id);
    if (index != -1) {
      _devModels![index] = VehicleModelModel.fromEntity(model);
    }
    return model;
  }

  Future<void> deleteModel(String modelId) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('vehicle_models').delete().eq('id', modelId);
        return;
      } catch (e) {
        debugPrint('Supabase deleteModel error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    _devModels!.removeWhere((m) => m.id == modelId);
    _devVariants!.removeWhere((v) => v.modelId == modelId);
    _devColors!.removeWhere((c) => c.modelId == modelId);
  }

  // ─────────────────────────────────────────────
  // 3. VEHICLE VARIANTS
  // ─────────────────────────────────────────────

  Future<List<VehicleVariantEntity>> fetchVariants({
    String? modelId,
    bool? isActive,
  }) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        var query = SupabaseService.client!.from('vehicle_variants').select();
        if (modelId != null) query = query.eq('model_id', modelId);
        if (isActive != null) query = query.eq('is_active', isActive);

        final data = await query.order('ex_showroom_price', ascending: true);
        return (data as List).map((row) => VehicleVariantModel.fromJson(row)).toList();
      } catch (e) {
        debugPrint('Supabase fetchVariants error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    var list = _devVariants!;
    if (modelId != null) {
      list = list.where((v) => v.modelId == modelId).toList();
    }
    if (isActive != null) {
      list = list.where((v) => v.isActive == isActive).toList();
    }
    return List.unmodifiable(list);
  }

  Future<VehicleVariantEntity> createVariant(VehicleVariantEntity variant) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final model = VehicleVariantModel.fromEntity(variant);
        final response = await SupabaseService.client!
            .from('vehicle_variants')
            .insert(model.toJson())
            .select()
            .single();
        return VehicleVariantModel.fromJson(response);
      } catch (e) {
        debugPrint('Supabase createVariant error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    final model = VehicleVariantModel.fromEntity(variant);
    _devVariants!.add(model);
    return model;
  }

  Future<VehicleVariantEntity> updateVariant(VehicleVariantEntity variant) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final model = VehicleVariantModel.fromEntity(variant);
        final response = await SupabaseService.client!
            .from('vehicle_variants')
            .update(model.toJson())
            .eq('id', variant.id)
            .select()
            .single();
        return VehicleVariantModel.fromJson(response);
      } catch (e) {
        debugPrint('Supabase updateVariant error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    final index = _devVariants!.indexWhere((v) => v.id == variant.id);
    if (index != -1) {
      _devVariants![index] = VehicleVariantModel.fromEntity(variant);
    }
    return variant;
  }

  Future<void> deleteVariant(String variantId) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('vehicle_variants').delete().eq('id', variantId);
        return;
      } catch (e) {
        debugPrint('Supabase deleteVariant error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    _devVariants!.removeWhere((v) => v.id == variantId);
  }

  // ─────────────────────────────────────────────
  // 4. VEHICLE COLORS
  // ─────────────────────────────────────────────

  Future<List<VehicleColorEntity>> fetchColors({
    String? modelId,
    bool? isActive,
  }) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        var query = SupabaseService.client!.from('vehicle_colors').select();
        if (modelId != null) query = query.eq('model_id', modelId);
        if (isActive != null) query = query.eq('is_active', isActive);

        final data = await query.order('name', ascending: true);
        return (data as List).map((row) => VehicleColorModel.fromJson(row)).toList();
      } catch (e) {
        debugPrint('Supabase fetchColors error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    var list = _devColors!;
    if (modelId != null) {
      list = list.where((c) => c.modelId == modelId).toList();
    }
    if (isActive != null) {
      list = list.where((c) => c.isActive == isActive).toList();
    }
    return List.unmodifiable(list);
  }

  Future<VehicleColorEntity> createColor(VehicleColorEntity color) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final model = VehicleColorModel.fromEntity(color);
        final response = await SupabaseService.client!
            .from('vehicle_colors')
            .insert(model.toJson())
            .select()
            .single();
        return VehicleColorModel.fromJson(response);
      } catch (e) {
        debugPrint('Supabase createColor error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    final model = VehicleColorModel.fromEntity(color);
    _devColors!.add(model);
    return model;
  }

  Future<VehicleColorEntity> updateColor(VehicleColorEntity color) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final model = VehicleColorModel.fromEntity(color);
        final response = await SupabaseService.client!
            .from('vehicle_colors')
            .update(model.toJson())
            .eq('id', color.id)
            .select()
            .single();
        return VehicleColorModel.fromJson(response);
      } catch (e) {
        debugPrint('Supabase updateColor error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    final index = _devColors!.indexWhere((c) => c.id == color.id);
    if (index != -1) {
      _devColors![index] = VehicleColorModel.fromEntity(color);
    }
    return color;
  }

  Future<void> deleteColor(String colorId) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('vehicle_colors').delete().eq('id', colorId);
        return;
      } catch (e) {
        debugPrint('Supabase deleteColor error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    _devColors!.removeWhere((c) => c.id == colorId);
  }

  // ─────────────────────────────────────────────
  // 5. AGGREGATED CATALOG
  // ─────────────────────────────────────────────

  Future<List<VehicleCatalogItem>> fetchCatalogItems({
    String? brandId,
    String? type,
    String? bodyType,
    String? search,
    bool? isActive,
  }) async {
    final models = await fetchModels(
      brandId: brandId,
      type: type,
      bodyType: bodyType,
      search: search,
      isActive: isActive,
    );

    final brands = await fetchBrands();
    final brandsMap = {for (final b in brands) b.id: b};

    final allVariants = await fetchVariants(isActive: isActive);
    final allColors = await fetchColors(isActive: isActive);

    final items = <VehicleCatalogItem>[];
    for (final model in models) {
      final brand = brandsMap[model.brandId];
      final variants = allVariants.where((v) => v.modelId == model.id).toList();
      final colors = allColors.where((c) => c.modelId == model.id).toList();

      items.add(VehicleCatalogItem(
        model: model,
        brand: brand,
        variants: variants,
        colors: colors,
      ));
    }

    return items;
  }

  Future<VehicleCatalogItem?> fetchCatalogItemById(String modelId) async {
    final model = await fetchModelById(modelId);
    if (model == null) return null;

    final brands = await fetchBrands();
    final brand = brands.where((b) => b.id == model.brandId).firstOrNull;
    final variants = await fetchVariants(modelId: modelId);
    final colors = await fetchColors(modelId: modelId);

    return VehicleCatalogItem(
      model: model,
      brand: brand,
      variants: variants,
      colors: colors,
    );
  }
}
