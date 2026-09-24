import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import 'supabase_service.dart';
import 'showroom_management_service.dart';
import 'vehicle_master_service.dart';
import '../../features/inventory/domain/entities/inventory_vehicle_entity.dart';
import '../../features/inventory/domain/entities/stock_transfer_entity.dart';
import '../../features/inventory/domain/entities/stock_movement_entity.dart';
import '../../features/inventory/domain/entities/vehicle_inventory_item.dart';
import '../../features/inventory/data/models/inventory_vehicle_model.dart';
import '../../features/inventory/data/models/stock_transfer_model.dart';
import '../../features/inventory/data/models/stock_movement_model.dart';

/// DTO for inwarding a single serialized vehicle unit
class InwardVehicleUnit {
  final String vin;
  final String? engineNumber;
  final String? motorNumber;
  final String? batterySerialNumber;
  final String? keyNumber;
  final double purchaseCost;
  final String mfgYearMonth;
  final String locationInShowroom;

  const InwardVehicleUnit({
    required this.vin,
    this.engineNumber,
    this.motorNumber,
    this.batterySerialNumber,
    this.keyNumber,
    this.purchaseCost = 0.0,
    this.mfgYearMonth = '2026-01',
    this.locationInShowroom = 'Main Display Area',
  });
}

/// Comprehensive Inventory & Stock Management Service
class InventoryManagementService {
  InventoryManagementService._();
  static final InventoryManagementService instance = InventoryManagementService._();

  List<InventoryVehicleModel>? _devVehicles;
  List<StockTransferModel>? _devTransfers;
  List<StockMovementModel>? _devMovements;

  void _initDevData() {
    if (_devVehicles != null) return;
    final now = DateTime.now();

    // 25+ Seeded Serialized Units
    _devVehicles = [
      // ─── Mumbai Central (IND-MAIN) ───
      // Petrol - Honda CB350 H'ness DLX Pro (v-002, Precious Red Metallic c-001)
      InventoryVehicleModel(
        id: 'inv-001',
        showroomId: 'sh-001',
        variantId: 'v-002',
        colorId: 'c-001',
        vin: 'ME4NC5800N8000101',
        engineNumber: 'NC58E-1002341',
        keyNumber: 'KEY-MUM-01',
        status: 'in_stock',
        purchaseCost: 175000.0,
        receivedDate: now.subtract(const Duration(days: 20)),
        mfgYearMonth: '2026-01',
        odometerReadingKm: 2.4,
        locationInShowroom: 'Bay A1 - Premium Floor',
        pdiStatus: 'passed',
        pdiNotes: 'PDI verified: engine fluids, electricals, torque check OK.',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
      ),
      // Petrol - Honda CB350 H'ness DLX (v-001, Pearl Nightstar Black c-002)
      InventoryVehicleModel(
        id: 'inv-002',
        showroomId: 'sh-001',
        variantId: 'v-001',
        colorId: 'c-002',
        vin: 'ME4NC5800N8000102',
        engineNumber: 'NC58E-1002342',
        keyNumber: 'KEY-MUM-02',
        status: 'booked',
        purchaseCost: 170000.0,
        receivedDate: now.subtract(const Duration(days: 18)),
        mfgYearMonth: '2026-01',
        odometerReadingKm: 1.8,
        locationInShowroom: 'Bay A2 - Booking Reserved',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 18)),
        updatedAt: now,
      ),
      // EV - Ather 450X 3.7 kWh Pro (v-005, Space Grey c-004)
      InventoryVehicleModel(
        id: 'inv-003',
        showroomId: 'sh-001',
        variantId: 'v-005',
        colorId: 'c-004',
        vin: 'MALJA450XN0000103',
        motorNumber: 'ATH-MTR-64-001',
        batterySerialNumber: 'ATH-BAT-37-9001',
        keyNumber: 'KEY-MUM-03',
        status: 'in_stock',
        purchaseCost: 128000.0,
        receivedDate: now.subtract(const Duration(days: 15)),
        mfgYearMonth: '2026-01',
        batteryHealthPercentage: 100.0,
        odometerReadingKm: 3.1,
        locationInShowroom: 'EV Experience Center',
        pdiStatus: 'passed',
        pdiNotes: 'Software v5.2 updated, battery charged to 98%.',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
      ),
      // EV - Ather Rizta Z 3.7 kWh (v-011, Pangong Blue c-013)
      InventoryVehicleModel(
        id: 'inv-004',
        showroomId: 'sh-001',
        variantId: 'v-011',
        colorId: 'c-013',
        vin: 'MALRIZTAZN0000104',
        motorNumber: 'ATH-MTR-43-002',
        batterySerialNumber: 'ATH-BAT-37-9002',
        keyNumber: 'KEY-MUM-04',
        status: 'in_stock',
        purchaseCost: 119000.0,
        receivedDate: now.subtract(const Duration(days: 10)),
        mfgYearMonth: '2026-01',
        batteryHealthPercentage: 100.0,
        odometerReadingKm: 1.2,
        locationInShowroom: 'Main Display Area',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
      ),
      // Petrol - TVS Apache RTR 310 BTO (v-007, Sepang Blue c-010)
      InventoryVehicleModel(
        id: 'inv-005',
        showroomId: 'sh-001',
        variantId: 'v-007',
        colorId: 'c-010',
        vin: 'MD625CK31N8000105',
        engineNumber: 'CK31E-2001011',
        keyNumber: 'KEY-MUM-05',
        status: 'in_stock',
        purchaseCost: 215000.0,
        receivedDate: now.subtract(const Duration(days: 12)),
        mfgYearMonth: '2026-01',
        odometerReadingKm: 4.0,
        locationInShowroom: 'Racing Pavilion',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now,
      ),
      // Petrol - Royal Enfield Hunter 350 Metro (v-009, Rebel Blue c-012)
      InventoryVehicleModel(
        id: 'inv-006',
        showroomId: 'sh-001',
        variantId: 'v-009',
        colorId: 'c-012',
        vin: 'ME3J3A507N8000106',
        engineNumber: 'J3A5E-4001921',
        keyNumber: 'KEY-MUM-06',
        status: 'in_stock',
        purchaseCost: 138000.0,
        receivedDate: now.subtract(const Duration(days: 14)),
        mfgYearMonth: '2026-01',
        odometerReadingKm: 2.1,
        locationInShowroom: 'Urban Roadster Zone',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now,
      ),
      // Petrol - Hero Splendor+ XTEC (v-013, Sparkling Alpha Blue c-017)
      InventoryVehicleModel(
        id: 'inv-007',
        showroomId: 'sh-001',
        variantId: 'v-013',
        colorId: 'c-017',
        vin: 'MBLHA10EMN8000107',
        engineNumber: 'HA10E-9003812',
        keyNumber: 'KEY-MUM-07',
        status: 'in_stock',
        purchaseCost: 65000.0,
        receivedDate: now.subtract(const Duration(days: 8)),
        mfgYearMonth: '2026-01',
        odometerReadingKm: 0.9,
        locationInShowroom: 'Commuter Row',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now,
      ),
      // EV - TVS iQube 3.4 kWh (v-012, Shining Red c-015)
      InventoryVehicleModel(
        id: 'inv-008',
        showroomId: 'sh-001',
        variantId: 'v-012',
        colorId: 'c-015',
        vin: 'MD625EV00N8000108',
        motorNumber: 'TVS-MTR-44-01',
        batterySerialNumber: 'TVS-BAT-34-8812',
        keyNumber: 'KEY-MUM-08',
        status: 'in_stock',
        purchaseCost: 98000.0,
        receivedDate: now.subtract(const Duration(days: 6)),
        mfgYearMonth: '2026-01',
        batteryHealthPercentage: 100.0,
        odometerReadingKm: 1.5,
        locationInShowroom: 'Main Display Area',
        pdiStatus: 'pending',
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now,
      ),

      // ─── Pune West Hub (IND-WEST) ───
      // Petrol - Honda CB350 H'ness DLX Pro (v-002, Matte Marshal Green c-003)
      InventoryVehicleModel(
        id: 'inv-009',
        showroomId: 'sh-002',
        variantId: 'v-002',
        colorId: 'c-003',
        vin: 'ME4NC5800N8000201',
        engineNumber: 'NC58E-1002451',
        keyNumber: 'KEY-PUN-01',
        status: 'in_stock',
        purchaseCost: 176500.0,
        receivedDate: now.subtract(const Duration(days: 22)),
        mfgYearMonth: '2026-01',
        odometerReadingKm: 2.0,
        locationInShowroom: 'Showroom Floor Bay 1',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 22)),
        updatedAt: now,
      ),
      // EV - Ather 450X 3.7 kWh Pro (v-005, True Red c-005)
      InventoryVehicleModel(
        id: 'inv-010',
        showroomId: 'sh-002',
        variantId: 'v-005',
        colorId: 'c-005',
        vin: 'MALJA450XN0000202',
        motorNumber: 'ATH-MTR-64-003',
        batterySerialNumber: 'ATH-BAT-37-9015',
        keyNumber: 'KEY-PUN-02',
        status: 'in_stock',
        purchaseCost: 128000.0,
        receivedDate: now.subtract(const Duration(days: 16)),
        mfgYearMonth: '2026-01',
        batteryHealthPercentage: 100.0,
        odometerReadingKm: 3.5,
        locationInShowroom: 'EV Pod 1',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 16)),
        updatedAt: now,
      ),
      // Petrol - TVS Apache RTR 310 (v-006, Arsenal Black c-008)
      InventoryVehicleModel(
        id: 'inv-011',
        showroomId: 'sh-002',
        variantId: 'v-006',
        colorId: 'c-008',
        vin: 'MD625CK31N8000203',
        engineNumber: 'CK31E-2001140',
        keyNumber: 'KEY-PUN-03',
        status: 'booked',
        purchaseCost: 198000.0,
        receivedDate: now.subtract(const Duration(days: 14)),
        mfgYearMonth: '2026-01',
        odometerReadingKm: 1.1,
        locationInShowroom: 'Customer Delivery Bay',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now,
      ),
      // Petrol - Royal Enfield Hunter 350 Retro (v-008, Factory Black c-013)
      InventoryVehicleModel(
        id: 'inv-012',
        showroomId: 'sh-002',
        variantId: 'v-008',
        colorId: 'c-013',
        vin: 'ME3J3A507N8000204',
        engineNumber: 'J3A5E-4002011',
        keyNumber: 'KEY-PUN-04',
        status: 'in_stock',
        purchaseCost: 122000.0,
        receivedDate: now.subtract(const Duration(days: 19)),
        mfgYearMonth: '2026-01',
        odometerReadingKm: 1.9,
        locationInShowroom: 'Main Floor',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 19)),
        updatedAt: now,
      ),
      // EV - Ather Rizta S (v-010, Cardamom Green c-014)
      InventoryVehicleModel(
        id: 'inv-013',
        showroomId: 'sh-002',
        variantId: 'v-010',
        colorId: 'c-014',
        vin: 'MALRIZTASN0000205',
        motorNumber: 'ATH-MTR-43-005',
        batterySerialNumber: 'ATH-BAT-29-8410',
        keyNumber: 'KEY-PUN-05',
        status: 'in_stock',
        purchaseCost: 91000.0,
        receivedDate: now.subtract(const Duration(days: 5)),
        mfgYearMonth: '2026-01',
        batteryHealthPercentage: 100.0,
        odometerReadingKm: 0.8,
        locationInShowroom: 'EV Pod 2',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
      // In-Transit Unit (Transfer from Mumbai to Pune)
      InventoryVehicleModel(
        id: 'inv-014',
        showroomId: 'sh-002',
        variantId: 'v-003',
        colorId: 'c-002',
        vin: 'ME4NC5800N8000206',
        engineNumber: 'NC58E-1002590',
        keyNumber: 'KEY-TRF-01',
        status: 'in_transit',
        purchaseCost: 180000.0,
        receivedDate: now.subtract(const Duration(days: 2)),
        mfgYearMonth: '2026-01',
        odometerReadingKm: 0.5,
        locationInShowroom: 'In-Transit Carrier #MH-12-TR-4001',
        pdiStatus: 'pending',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),

      // ─── Bangalore Metro (IND-SOUTH) ───
      // EV - Ather 450X 3.7 Pro (v-005, Salt Green c-006)
      InventoryVehicleModel(
        id: 'inv-015',
        showroomId: 'sh-003',
        variantId: 'v-005',
        colorId: 'c-006',
        vin: 'MALJA450XN0000301',
        motorNumber: 'ATH-MTR-64-008',
        batterySerialNumber: 'ATH-BAT-37-9099',
        keyNumber: 'KEY-BLR-01',
        status: 'in_stock',
        purchaseCost: 128000.0,
        receivedDate: now.subtract(const Duration(days: 25)),
        mfgYearMonth: '2026-01',
        batteryHealthPercentage: 100.0,
        odometerReadingKm: 2.8,
        locationInShowroom: 'Flagship EV Arena',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now,
      ),
      // EV - Ather 450X 2.9 Base (v-004, Lunar Grey c-007)
      InventoryVehicleModel(
        id: 'inv-016',
        showroomId: 'sh-003',
        variantId: 'v-004',
        colorId: 'c-007',
        vin: 'MALJA450XN0000302',
        motorNumber: 'ATH-MTR-60-012',
        batterySerialNumber: 'ATH-BAT-29-8720',
        keyNumber: 'KEY-BLR-02',
        status: 'in_stock',
        purchaseCost: 116000.0,
        receivedDate: now.subtract(const Duration(days: 21)),
        mfgYearMonth: '2026-01',
        batteryHealthPercentage: 100.0,
        odometerReadingKm: 1.9,
        locationInShowroom: 'Flagship EV Arena',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 21)),
        updatedAt: now,
      ),
      // Petrol - Honda CB350 H'ness DLX Pro (v-002, Precious Red c-001)
      InventoryVehicleModel(
        id: 'inv-017',
        showroomId: 'sh-003',
        variantId: 'v-002',
        colorId: 'c-001',
        vin: 'ME4NC5800N8000303',
        engineNumber: 'NC58E-1002711',
        keyNumber: 'KEY-BLR-03',
        status: 'in_stock',
        purchaseCost: 175000.0,
        receivedDate: now.subtract(const Duration(days: 15)),
        mfgYearMonth: '2026-01',
        odometerReadingKm: 3.0,
        locationInShowroom: 'BigWing Zone',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
      ),
      // Petrol - TVS Apache RTR 310 BTO (v-007, Fury Yellow c-009)
      InventoryVehicleModel(
        id: 'inv-018',
        showroomId: 'sh-003',
        variantId: 'v-007',
        colorId: 'c-009',
        vin: 'MD625CK31N8000304',
        engineNumber: 'CK31E-2001399',
        keyNumber: 'KEY-BLR-04',
        status: 'in_stock',
        purchaseCost: 216000.0,
        receivedDate: now.subtract(const Duration(days: 11)),
        mfgYearMonth: '2026-01',
        odometerReadingKm: 2.2,
        locationInShowroom: 'Sport Floor',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 11)),
        updatedAt: now,
      ),
      // EV - TVS iQube 3.4 kWh (v-012, Titanium Grey c-016)
      InventoryVehicleModel(
        id: 'inv-019',
        showroomId: 'sh-003',
        variantId: 'v-012',
        colorId: 'c-016',
        vin: 'MD625EV00N8000305',
        motorNumber: 'TVS-MTR-44-09',
        batterySerialNumber: 'TVS-BAT-34-8930',
        keyNumber: 'KEY-BLR-05',
        status: 'sold',
        purchaseCost: 98000.0,
        receivedDate: now.subtract(const Duration(days: 30)),
        mfgYearMonth: '2025-12',
        batteryHealthPercentage: 99.8,
        odometerReadingKm: 6.5,
        locationInShowroom: 'Customer Delivery Area',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      // Petrol - Hero Splendor+ XTEC (v-013, Black with Silver c-018)
      InventoryVehicleModel(
        id: 'inv-020',
        showroomId: 'sh-003',
        variantId: 'v-013',
        colorId: 'c-018',
        vin: 'MBLHA10EMN8000306',
        engineNumber: 'HA10E-9004101',
        keyNumber: 'KEY-BLR-06',
        status: 'in_stock',
        purchaseCost: 65000.0,
        receivedDate: now.subtract(const Duration(days: 7)),
        mfgYearMonth: '2026-01',
        odometerReadingKm: 1.1,
        locationInShowroom: 'Main Commuter Floor',
        pdiStatus: 'passed',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now,
      ),
    ];

    // Seeded Stock Transfers
    _devTransfers = [
      StockTransferModel(
        id: 'trf-001',
        transferNumber: 'TRF-IND-MAIN-2026-0001',
        sourceShowroomId: 'sh-001',
        destinationShowroomId: 'sh-002',
        status: 'in_transit',
        requestedBy: 'user-002',
        dispatchedBy: 'user-001',
        dispatchedAt: now.subtract(const Duration(days: 2)),
        notes: 'Inter-branch stock rebalance for Pune customer demand',
        items: const [
          StockTransferItemModel(
            id: 'trf-item-001',
            transferId: 'trf-001',
            vehicleId: 'inv-014',
            status: 'in_transit',
          ),
        ],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),
    ];

    // Seeded Stock Movements
    _devMovements = [
      StockMovementModel(
        id: 'mov-001',
        vehicleId: 'inv-001',
        movementType: 'inward_grn',
        toShowroomId: 'sh-001',
        remarks: 'Factory dispatch received via Goods Receipt Note GRN-2026-0182',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      StockMovementModel(
        id: 'mov-002',
        vehicleId: 'inv-001',
        movementType: 'pdi_status_update',
        toShowroomId: 'sh-001',
        remarks: 'Pre-Delivery Inspection passed by Senior Tech Rajesh Sharma',
        createdAt: now.subtract(const Duration(days: 19)),
      ),
      StockMovementModel(
        id: 'mov-003',
        vehicleId: 'inv-014',
        movementType: 'inward_grn',
        toShowroomId: 'sh-001',
        remarks: 'Received at Mumbai Central hub',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      StockMovementModel(
        id: 'mov-004',
        vehicleId: 'inv-014',
        movementType: 'transfer_dispatch',
        fromShowroomId: 'sh-001',
        toShowroomId: 'sh-002',
        remarks: 'Dispatched via carrier MH-12-TR-4001 under Challan TRF-IND-MAIN-2026-0001',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  // ─────────────────────────────────────────────
  // 1. INVENTORY QUERIES
  // ─────────────────────────────────────────────

  Future<List<VehicleInventoryItem>> fetchInventory({
    String? showroomId,
    String? variantId,
    String? status,
    String? pdiStatus,
    String? search,
    String? powertrain, // 'petrol', 'electric'
  }) async {
    // ─── Live Supabase ───
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        var query = SupabaseService.client!.from('inventory_vehicles').select();
        if (showroomId != null) query = query.eq('showroom_id', showroomId);
        if (variantId != null) query = query.eq('variant_id', variantId);
        if (status != null && status.isNotEmpty && status != 'all') {
          query = query.eq('status', status);
        }
        if (pdiStatus != null && pdiStatus.isNotEmpty && pdiStatus != 'all') {
          query = query.eq('pdi_status', pdiStatus);
        }
        if (search != null && search.isNotEmpty) {
          query = query.or('vin.ilike.%$search%,engine_number.ilike.%$search%,motor_number.ilike.%$search%,key_number.ilike.%$search%');
        }

        final data = await query.order('created_at', ascending: false);
        final rawVehicles = (data as List).map((row) => InventoryVehicleModel.fromJson(row)).toList();

        return _hydrateVehicles(rawVehicles, powertrain: powertrain);
      } catch (e) {
        debugPrint('Supabase fetchInventory error: $e, falling back to dev mode');
      }
    }

    // ─── Dev Mode Fallback ───
    await SupabaseService.devLatency();
    _initDevData();
    var list = _devVehicles!;

    if (showroomId != null) {
      list = list.where((v) => v.showroomId == showroomId).toList();
    }
    if (variantId != null) {
      list = list.where((v) => v.variantId == variantId).toList();
    }
    if (status != null && status.isNotEmpty && status != 'all') {
      list = list.where((v) => v.status == status).toList();
    }
    if (pdiStatus != null && pdiStatus.isNotEmpty && pdiStatus != 'all') {
      list = list.where((v) => v.pdiStatus == pdiStatus).toList();
    }
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      list = list.where((v) =>
          v.vin.toLowerCase().contains(s) ||
          (v.engineNumber?.toLowerCase().contains(s) ?? false) ||
          (v.motorNumber?.toLowerCase().contains(s) ?? false) ||
          (v.keyNumber?.toLowerCase().contains(s) ?? false)).toList();
    }

    return _hydrateVehicles(list, powertrain: powertrain);
  }

  Future<List<VehicleInventoryItem>> _hydrateVehicles(
    List<InventoryVehicleEntity> vehicles, {
    String? powertrain,
  }) async {
    final showrooms = await ShowroomManagementService.instance.fetchShowrooms();
    final showroomMap = {for (final s in showrooms) s.showroom.id: s.showroom};

    final catalog = await VehicleMasterService.instance.fetchCatalogItems();
    final modelsMap = {for (final item in catalog) item.model.id: item.model};
    final brandsMap = {for (final item in catalog) if (item.brand != null) item.brand!.id: item.brand!};

    final allVariants = catalog.expand((c) => c.variants).toList();
    final variantMap = {for (final v in allVariants) v.id: v};

    final allColors = catalog.expand((c) => c.colors).toList();
    final colorMap = {for (final col in allColors) col.id: col};

    final results = <VehicleInventoryItem>[];
    for (final v in vehicles) {
      final variant = variantMap[v.variantId];
      final model = variant != null ? modelsMap[variant.modelId] : null;
      final brand = model != null ? brandsMap[model.brandId] : null;
      final color = colorMap[v.colorId];
      final showroom = showroomMap[v.showroomId];

      // Filter by powertrain if specified
      if (powertrain != null && powertrain.isNotEmpty && powertrain != 'all') {
        if (powertrain == 'petrol' && (model?.isPetrol != true && !v.isPetrol)) continue;
        if (powertrain == 'electric' && (model?.isElectric != true && !v.isElectric)) continue;
      }

      results.add(VehicleInventoryItem(
        vehicle: v,
        model: model,
        variant: variant,
        brand: brand,
        color: color,
        showroom: showroom,
      ));
    }

    return results;
  }

  Future<VehicleInventoryItem?> fetchVehicleById(String id) async {
    final items = await fetchInventory();
    return items.where((i) => i.vehicle.id == id).firstOrNull;
  }

  Future<VehicleInventoryItem?> fetchVehicleByVin(String vin) async {
    final items = await fetchInventory();
    return items.where((i) => i.vehicle.vin.toUpperCase() == vin.toUpperCase()).firstOrNull;
  }

  // ─────────────────────────────────────────────
  // 2. INWARDING (GRN BATCH)
  // ─────────────────────────────────────────────

  Future<List<InventoryVehicleEntity>> inwardStock({
    required String showroomId,
    required String variantId,
    required String colorId,
    required List<InwardVehicleUnit> units,
    String? remarks,
  }) async {
    final now = DateTime.now();
    final createdList = <InventoryVehicleEntity>[];

    for (final unit in units) {
      final id = 'inv-${now.millisecondsSinceEpoch}-${createdList.length}';
      final model = InventoryVehicleModel(
        id: id,
        showroomId: showroomId,
        variantId: variantId,
        colorId: colorId,
        vin: unit.vin.trim().toUpperCase(),
        engineNumber: unit.engineNumber?.trim().isNotEmpty == true ? unit.engineNumber!.trim() : null,
        motorNumber: unit.motorNumber?.trim().isNotEmpty == true ? unit.motorNumber!.trim() : null,
        batterySerialNumber: unit.batterySerialNumber?.trim().isNotEmpty == true ? unit.batterySerialNumber!.trim() : null,
        keyNumber: unit.keyNumber?.trim().isNotEmpty == true ? unit.keyNumber!.trim() : null,
        status: 'in_stock',
        purchaseCost: unit.purchaseCost,
        receivedDate: now,
        mfgYearMonth: unit.mfgYearMonth,
        batteryHealthPercentage: unit.motorNumber != null ? 100.0 : null,
        odometerReadingKm: 0.0,
        locationInShowroom: unit.locationInShowroom,
        pdiStatus: 'pending',
        createdAt: now,
        updatedAt: now,
      );

      if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
        try {
          final res = await SupabaseService.client!
              .from('inventory_vehicles')
              .insert(model.toJson())
              .select()
              .single();
          createdList.add(InventoryVehicleModel.fromJson(res));
          await logStockMovement(
            vehicleId: model.id,
            movementType: 'inward_grn',
            toShowroomId: showroomId,
            remarks: remarks ?? 'Factory Inward (GRN)',
          );
          continue;
        } catch (e) {
          debugPrint('Supabase inwardStock unit error: $e, falling back to dev mode');
        }
      }

      _initDevData();
      _devVehicles!.insert(0, model);
      createdList.add(model);

      _devMovements!.insert(0, StockMovementModel(
        id: 'mov-${now.millisecondsSinceEpoch}-${createdList.length}',
        vehicleId: model.id,
        movementType: 'inward_grn',
        toShowroomId: showroomId,
        remarks: remarks ?? 'Factory Inward (GRN)',
        createdAt: now,
      ));
    }

    return createdList;
  }

  // ─────────────────────────────────────────────
  // 3. STATUS & PDI UPDATES
  // ─────────────────────────────────────────────

  Future<void> updateVehicleStatus(String vehicleId, String status, {String? remarks}) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        await SupabaseService.client!
            .from('inventory_vehicles')
            .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
            .eq('id', vehicleId);
        await logStockMovement(
          vehicleId: vehicleId,
          movementType: 'status_adjustment',
          remarks: remarks ?? 'Status changed to $status',
        );
        return;
      } catch (e) {
        debugPrint('Supabase updateVehicleStatus error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    final index = _devVehicles!.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      _devVehicles![index] = InventoryVehicleModel.fromEntity(
        _devVehicles![index].copyWith(status: status, updatedAt: DateTime.now()),
      );
      _devMovements!.insert(0, StockMovementModel(
        id: 'mov-${DateTime.now().millisecondsSinceEpoch}',
        vehicleId: vehicleId,
        movementType: 'status_adjustment',
        remarks: remarks ?? 'Status changed to $status',
        createdAt: DateTime.now(),
      ));
    }
  }

  Future<void> updatePdiStatus(String vehicleId, String pdiStatus, {String? notes}) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        await SupabaseService.client!
            .from('inventory_vehicles')
            .update({
              'pdi_status': pdiStatus,
              'pdi_notes': notes,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', vehicleId);
        await logStockMovement(
          vehicleId: vehicleId,
          movementType: 'pdi_status_update',
          remarks: 'PDI Inspection status marked: $pdiStatus. $notes',
        );
        return;
      } catch (e) {
        debugPrint('Supabase updatePdiStatus error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    final index = _devVehicles!.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      _devVehicles![index] = InventoryVehicleModel.fromEntity(
        _devVehicles![index].copyWith(
          pdiStatus: pdiStatus,
          pdiNotes: notes,
          updatedAt: DateTime.now(),
        ),
      );
      _devMovements!.insert(0, StockMovementModel(
        id: 'mov-${DateTime.now().millisecondsSinceEpoch}',
        vehicleId: vehicleId,
        movementType: 'pdi_status_update',
        remarks: 'PDI Inspection status marked: $pdiStatus. $notes',
        createdAt: DateTime.now(),
      ));
    }
  }

  Future<void> updateVehicleLocation(String vehicleId, String location, {String? remarks}) async {
    _initDevData();
    final index = _devVehicles!.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      _devVehicles![index] = InventoryVehicleModel.fromEntity(
        _devVehicles![index].copyWith(locationInShowroom: location, updatedAt: DateTime.now()),
      );
      _devMovements!.insert(0, StockMovementModel(
        id: 'mov-${DateTime.now().millisecondsSinceEpoch}',
        vehicleId: vehicleId,
        movementType: 'bay_location_change',
        remarks: remarks ?? 'Relocated to $location',
        createdAt: DateTime.now(),
      ));
    }
  }

  // ─────────────────────────────────────────────
  // 4. INTER-SHOWROOM STOCK TRANSFERS
  // ─────────────────────────────────────────────

  Future<List<StockTransferEntity>> fetchStockTransfers({
    String? showroomId,
    String? status,
  }) async {
    await SupabaseService.devLatency();
    _initDevData();
    var list = _devTransfers!;
    if (showroomId != null) {
      list = list.where((t) => t.sourceShowroomId == showroomId || t.destinationShowroomId == showroomId).toList();
    }
    if (status != null && status.isNotEmpty && status != 'all') {
      list = list.where((t) => t.status == status).toList();
    }
    return List.unmodifiable(list);
  }

  Future<StockTransferEntity> createStockTransfer({
    required String sourceShowroomId,
    required String destinationShowroomId,
    required List<String> vehicleIds,
    String? notes,
  }) async {
    final now = DateTime.now();
    final transferNumber = 'TRF-TR-${now.millisecondsSinceEpoch.toString().substring(7)}';
    final transferId = 'trf-${now.millisecondsSinceEpoch}';

    final items = vehicleIds.map((vId) => StockTransferItemEntity(
      id: 'item-${now.millisecondsSinceEpoch}-${vehicleIds.indexOf(vId)}',
      transferId: transferId,
      vehicleId: vId,
      status: 'pending',
    )).toList();

    final transfer = StockTransferModel(
      id: transferId,
      transferNumber: transferNumber,
      sourceShowroomId: sourceShowroomId,
      destinationShowroomId: destinationShowroomId,
      status: 'requested',
      notes: notes,
      items: items,
      createdAt: now,
      updatedAt: now,
    );

    _initDevData();
    _devTransfers!.insert(0, transfer);

    return transfer;
  }

  Future<void> dispatchStockTransfer(String transferId) async {
    _initDevData();
    final index = _devTransfers!.indexWhere((t) => t.id == transferId);
    if (index == -1) return;

    final trf = _devTransfers![index];
    final now = DateTime.now();

    _devTransfers![index] = StockTransferModel.fromEntity(
      trf.copyWith(
        status: 'in_transit',
        dispatchedAt: now,
        updatedAt: now,
      ),
    );

    // Update all vehicle units to 'in_transit'
    for (final item in trf.items) {
      final vIndex = _devVehicles!.indexWhere((v) => v.id == item.vehicleId);
      if (vIndex != -1) {
        _devVehicles![vIndex] = InventoryVehicleModel.fromEntity(
          _devVehicles![vIndex].copyWith(status: 'in_transit', updatedAt: now),
        );
        _devMovements!.insert(0, StockMovementModel(
          id: 'mov-${now.millisecondsSinceEpoch}-${item.vehicleId}',
          vehicleId: item.vehicleId,
          movementType: 'transfer_dispatch',
          fromShowroomId: trf.sourceShowroomId,
          toShowroomId: trf.destinationShowroomId,
          remarks: 'Dispatched under transfer ${trf.transferNumber}',
          createdAt: now,
        ));
      }
    }
  }

  Future<void> receiveStockTransfer(String transferId) async {
    _initDevData();
    final index = _devTransfers!.indexWhere((t) => t.id == transferId);
    if (index == -1) return;

    final trf = _devTransfers![index];
    final now = DateTime.now();

    _devTransfers![index] = StockTransferModel.fromEntity(
      trf.copyWith(
        status: 'received',
        receivedAt: now,
        updatedAt: now,
      ),
    );

    // Reallocate vehicles to destination showroom and set status to 'in_stock'
    for (final item in trf.items) {
      final vIndex = _devVehicles!.indexWhere((v) => v.id == item.vehicleId);
      if (vIndex != -1) {
        _devVehicles![vIndex] = InventoryVehicleModel.fromEntity(
          _devVehicles![vIndex].copyWith(
            showroomId: trf.destinationShowroomId,
            status: 'in_stock',
            locationInShowroom: 'Arrival Intake Bay',
            updatedAt: now,
          ),
        );
        _devMovements!.insert(0, StockMovementModel(
          id: 'mov-${now.millisecondsSinceEpoch}-${item.vehicleId}',
          vehicleId: item.vehicleId,
          movementType: 'transfer_receive',
          fromShowroomId: trf.sourceShowroomId,
          toShowroomId: trf.destinationShowroomId,
          remarks: 'Received and inwarded at destination branch under transfer ${trf.transferNumber}',
          createdAt: now,
        ));
      }
    }
  }

  // ─────────────────────────────────────────────
  // 5. MOVEMENTS & AUDIT LOG
  // ─────────────────────────────────────────────

  Future<List<StockMovementEntity>> fetchVehicleMovements(String vehicleId) async {
    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        final data = await SupabaseService.client!
            .from('stock_movements')
            .select()
            .eq('vehicle_id', vehicleId)
            .order('created_at', ascending: false);
        return (data as List).map((row) => StockMovementModel.fromJson(row)).toList();
      } catch (e) {
        debugPrint('Supabase fetchVehicleMovements error: $e, falling back to dev mode');
      }
    }

    await SupabaseService.devLatency();
    _initDevData();
    return _devMovements!.where((m) => m.vehicleId == vehicleId).toList();
  }

  Future<void> logStockMovement({
    required String vehicleId,
    required String movementType,
    String? fromShowroomId,
    String? toShowroomId,
    String? performedBy,
    String? remarks,
  }) async {
    final model = StockMovementModel(
      id: 'mov-${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: vehicleId,
      movementType: movementType,
      fromShowroomId: fromShowroomId,
      toShowroomId: toShowroomId,
      performedBy: performedBy,
      remarks: remarks,
      createdAt: DateTime.now(),
    );

    if (SupabaseConfig.isConfigured && SupabaseService.client != null) {
      try {
        await SupabaseService.client!.from('stock_movements').insert(model.toJson());
        return;
      } catch (e) {
        debugPrint('Supabase logStockMovement error: $e, falling back to dev mode');
      }
    }

    _initDevData();
    _devMovements!.insert(0, model);
  }
}
