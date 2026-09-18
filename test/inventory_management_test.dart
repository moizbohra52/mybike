import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/inventory_management_service.dart';
import 'package:mybike/features/inventory/domain/entities/inventory_vehicle_entity.dart';
import 'package:mybike/features/inventory/presentation/cubit/inventory_list_cubit.dart';
import 'package:mybike/features/inventory/presentation/cubit/inventory_list_state.dart';
import 'package:mybike/features/inventory/presentation/cubit/stock_inward_cubit.dart';
import 'package:mybike/features/inventory/presentation/cubit/stock_transfer_cubit.dart';
import 'package:mybike/features/inventory/presentation/cubit/stock_transfer_state.dart';
import 'package:mybike/features/inventory/presentation/cubit/vehicle_inventory_detail_cubit.dart';
import 'package:mybike/features/inventory/presentation/cubit/vehicle_inventory_detail_state.dart';

void main() {
  group('Inventory Management — Entities & VIN Logic', () {
    test('InventoryVehicleEntity handles status flags and dual powertrain detection', () {
      final now = DateTime(2026, 1, 15);
      final petrolUnit = InventoryVehicleEntity(
        id: 'u-1',
        showroomId: 'sh-001',
        variantId: 'v-001',
        colorId: 'c-001',
        vin: 'ME4NC5800N8000991',
        engineNumber: 'NC58E-1009991',
        keyNumber: 'K-01',
        status: 'in_stock',
        purchaseCost: 175000.0,
        receivedDate: now,
        pdiStatus: 'passed',
        createdAt: now,
        updatedAt: now,
      );

      final evUnit = InventoryVehicleEntity(
        id: 'u-2',
        showroomId: 'sh-001',
        variantId: 'v-004',
        colorId: 'c-004',
        vin: 'MALJA450XN0000992',
        motorNumber: 'ATH-MTR-64-992',
        batterySerialNumber: 'ATH-BAT-37-9992',
        keyNumber: 'K-02',
        status: 'booked',
        purchaseCost: 128000.0,
        receivedDate: now,
        pdiStatus: 'pending',
        createdAt: now,
        updatedAt: now,
      );

      expect(petrolUnit.isPetrol, isTrue);
      expect(petrolUnit.isElectric, isFalse);
      expect(petrolUnit.isAvailable, isTrue);
      expect(petrolUnit.isPdiPassed, isTrue);

      expect(evUnit.isElectric, isTrue);
      expect(evUnit.isPetrol, isFalse);
      expect(evUnit.isBooked, isTrue);
      expect(evUnit.isPdiPassed, isFalse);
    });
  });

  group('InventoryManagementService — Stock & VIN Operations', () {
    final service = InventoryManagementService.instance;

    test('Seeds realistic vehicle units across Mumbai, Pune, and Bangalore', () async {
      final items = await service.fetchInventory();
      expect(items.length, greaterThanOrEqualTo(20));

      final mumUnits = items.where((i) => i.vehicle.showroomId == 'sh-001');
      final punUnits = items.where((i) => i.vehicle.showroomId == 'sh-002');
      final blrUnits = items.where((i) => i.vehicle.showroomId == 'sh-003');

      expect(mumUnits.isNotEmpty, isTrue);
      expect(punUnits.isNotEmpty, isTrue);
      expect(blrUnits.isNotEmpty, isTrue);
    });

    test('Filters inventory by powertrain, status, and search keyword', () async {
      final petrolItems = await service.fetchInventory(powertrain: 'petrol');
      expect(petrolItems.every((i) => i.isPetrol), isTrue);

      final evItems = await service.fetchInventory(powertrain: 'electric');
      expect(evItems.every((i) => i.isElectric), isTrue);

      final inStockItems = await service.fetchInventory(status: 'in_stock');
      expect(inStockItems.every((i) => i.vehicle.status == 'in_stock'), isTrue);

      final searchResults = await service.fetchInventory(search: 'ATH-MTR');
      expect(searchResults.isNotEmpty, isTrue);
      expect(searchResults.every((i) => i.vehicle.motorNumber?.contains('ATH-MTR') ?? false), isTrue);
    });

    test('Inwards a factory batch with unique VINs and logs movement', () async {
      final newUnits = [
        const InwardVehicleUnit(
          vin: 'TESTVIN2026INW001',
          engineNumber: 'ENG-TEST-001',
          keyNumber: 'K-TEST-01',
          purchaseCost: 180000.0,
        ),
        const InwardVehicleUnit(
          vin: 'TESTVIN2026INW002',
          engineNumber: 'ENG-TEST-002',
          keyNumber: 'K-TEST-02',
          purchaseCost: 180000.0,
        ),
      ];

      final created = await service.inwardStock(
        showroomId: 'sh-001',
        variantId: 'v-001',
        colorId: 'c-001',
        units: newUnits,
        remarks: 'Test Factory GRN',
      );

      expect(created.length, equals(2));
      expect(created.first.vin, equals('TESTVIN2026INW001'));

      final vehicle = await service.fetchVehicleByVin('TESTVIN2026INW001');
      expect(vehicle, isNotNull);
      expect(vehicle!.vehicle.status, equals('in_stock'));

      final movements = await service.fetchVehicleMovements(created.first.id);
      expect(movements.isNotEmpty, isTrue);
      expect(movements.first.movementType, equals('inward_grn'));
    });

    test('Manages full Inter-Showroom Transfer lifecycle (Request -> Dispatch -> Receive)', () async {
      // Find an available vehicle at Mumbai Central
      final mumAvailable = await service.fetchInventory(showroomId: 'sh-001', status: 'in_stock');
      expect(mumAvailable.isNotEmpty, isTrue);
      final testVehicleId = mumAvailable.first.vehicle.id;

      // 1. Create Transfer Request from Mumbai (sh-001) to Bangalore (sh-003)
      final transfer = await service.createStockTransfer(
        sourceShowroomId: 'sh-001',
        destinationShowroomId: 'sh-003',
        vehicleIds: [testVehicleId],
        notes: 'Urgent transfer for customer demand',
      );

      expect(transfer.status, equals('requested'));
      expect(transfer.items.length, equals(1));

      // 2. Dispatch Transfer
      await service.dispatchStockTransfer(transfer.id);

      final dispatchedVehicle = await service.fetchVehicleById(testVehicleId);
      expect(dispatchedVehicle, isNotNull);
      expect(dispatchedVehicle!.vehicle.status, equals('in_transit'));

      // 3. Receive Transfer at Bangalore
      await service.receiveStockTransfer(transfer.id);

      final receivedVehicle = await service.fetchVehicleById(testVehicleId);
      expect(receivedVehicle, isNotNull);
      expect(receivedVehicle!.vehicle.status, equals('in_stock'));
      expect(receivedVehicle.vehicle.showroomId, equals('sh-003'));

      // Verify movement audit log
      final movements = await service.fetchVehicleMovements(testVehicleId);
      expect(movements.any((m) => m.movementType == 'transfer_dispatch'), isTrue);
      expect(movements.any((m) => m.movementType == 'transfer_receive'), isTrue);
    });

    test('Updates PDI status and showroom bay location with movement audit', () async {
      const targetId = 'inv-001';
      await service.updatePdiStatus(targetId, 'passed', notes: 'All 24 check points verified');
      await service.updateVehicleLocation(targetId, 'VIP Customer Bay');

      final updated = await service.fetchVehicleById(targetId);
      expect(updated, isNotNull);
      expect(updated!.vehicle.pdiStatus, equals('passed'));
      expect(updated.vehicle.locationInShowroom, equals('VIP Customer Bay'));

      final movements = await service.fetchVehicleMovements(targetId);
      expect(movements.any((m) => m.movementType == 'pdi_status_update'), isTrue);
      expect(movements.any((m) => m.movementType == 'bay_location_change'), isTrue);
    });
  });

  group('Inventory Presentation Cubits', () {
    test('InventoryListCubit loads inventory and aggregates KPIs', () async {
      final cubit = InventoryListCubit();
      expect(cubit.state.status, equals(InventoryListStatus.initial));

      await cubit.loadInventory();
      expect(cubit.state.status, equals(InventoryListStatus.success));
      expect(cubit.state.items.isNotEmpty, isTrue);
      expect(cubit.state.showrooms.isNotEmpty, isTrue);
      expect(cubit.state.totalUnits, equals(cubit.state.items.length));
      expect(cubit.state.totalValuationInr, greaterThan(1000000.0));

      // Filter by powertrain
      await cubit.filterByPowertrain('electric');
      expect(cubit.state.items.every((i) => i.isElectric), isTrue);

      await cubit.close();
    });

    test('StockInwardCubit handles unit batch manipulation and validation', () async {
      final cubit = StockInwardCubit();
      await cubit.init();

      expect(cubit.state.showrooms.isNotEmpty, isTrue);
      expect(cubit.state.catalog.isNotEmpty, isTrue);

      // Add unit to batch
      const unit = InwardVehicleUnit(
        vin: 'TESTBATCHVIN001',
        engineNumber: 'ENG-001',
        purchaseCost: 150000.0,
      );
      cubit.addUnit(unit);
      expect(cubit.state.units.length, equals(1));

      // Remove unit
      cubit.removeUnit(0);
      expect(cubit.state.units.isEmpty, isTrue);

      await cubit.close();
    });

    test('StockTransferCubit loads and manages transfer requests', () async {
      final cubit = StockTransferCubit();
      await cubit.loadTransfers();

      expect(cubit.state.status, equals(StockTransferStatus.success));
      expect(cubit.state.showrooms.isNotEmpty, isTrue);

      await cubit.selectSourceShowroom('sh-001');
      expect(cubit.state.availableVehicles.isNotEmpty, isTrue);

      await cubit.close();
    });

    test('VehicleInventoryDetailCubit loads dossier and updates inspection', () async {
      final cubit = VehicleInventoryDetailCubit(vehicleId: 'inv-001');
      await cubit.loadDetails();

      expect(cubit.state.status, equals(VehicleInventoryDetailStatus.success));
      expect(cubit.state.item, isNotNull);
      expect(cubit.state.item!.vehicle.id, equals('inv-001'));
      expect(cubit.state.movements.isNotEmpty, isTrue);

      final updated = await cubit.updateLocation('Showroom Center Display');
      expect(updated, isTrue);
      expect(cubit.state.item!.vehicle.locationInShowroom, equals('Showroom Center Display'));

      await cubit.close();
    });
  });
}
