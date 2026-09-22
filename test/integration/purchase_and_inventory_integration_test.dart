import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/inventory_management_service.dart';

void main() {
  group('Phase 25 — Integration Test: Purchase Inwarding & Cross-Branch Inventory Management', () {
    late InventoryManagementService inventoryService;

    setUp(() {
      inventoryService = InventoryManagementService.instance;
    });

    test('1. Inward Batch of Serialized Vehicles (GRN)', () async {
      final units = [
        const InwardVehicleUnit(
          vin: 'ME4NC5800N8999001',
          engineNumber: 'NC58E-9999001',
          keyNumber: 'KEY-INW-01',
          purchaseCost: 175000.0,
          mfgYearMonth: '2026-02',
          locationInShowroom: 'Inward Bay 1',
        ),
        const InwardVehicleUnit(
          vin: 'ME4NC5800N8999002',
          engineNumber: 'NC58E-9999002',
          keyNumber: 'KEY-INW-02',
          purchaseCost: 175000.0,
          mfgYearMonth: '2026-02',
          locationInShowroom: 'Inward Bay 2',
        ),
      ];

      final inwarded = await inventoryService.inwardStock(
        showroomId: 'sh-001',
        variantId: 'v-002',
        colorId: 'c-001',
        units: units,
        remarks: 'Batch procurement from OEM Plant',
      );

      expect(inwarded.length, equals(2));
      expect(inwarded.every((v) => v.status == 'in_stock'), isTrue);
      expect(inwarded.first.vin, equals('ME4NC5800N8999001'));
      expect(inwarded.first.pdiStatus, equals('pending'));
    });

    test('2. Pre-Delivery Inspection (PDI) Pass and Showroom Bay Relocation', () async {
      final allInventory = await inventoryService.fetchInventory(showroomId: 'sh-001');
      expect(allInventory.isNotEmpty, isTrue);

      final targetVehicle = allInventory.first.vehicle;

      await inventoryService.updatePdiStatus(
        targetVehicle.id,
        'passed',
        notes: 'Electrical checks, battery terminal torque, and fluid levels verified OK.',
      );

      await inventoryService.updateVehicleLocation(
        targetVehicle.id,
        'Premium Display Floor Bay 3',
        remarks: 'Moved to customer showroom floor',
      );

      final updated = await inventoryService.fetchVehicleById(targetVehicle.id);
      expect(updated, isNotNull);
      expect(updated!.vehicle.pdiStatus, equals('passed'));
      expect(updated.vehicle.locationInShowroom, equals('Premium Display Floor Bay 3'));
    });

    test('3. Cross-Branch Stock Transfer Lifecycle (Request -> Dispatch -> Receive)', () async {
      // Pick a vehicle in Mumbai (sh-001)
      final mumbaiStock = await inventoryService.fetchInventory(showroomId: 'sh-001');
      final availableVehicle = mumbaiStock.firstWhere((i) => i.vehicle.status == 'in_stock').vehicle;

      // 1. Initiate Transfer request to Pune (sh-002)
      final transfer = await inventoryService.createStockTransfer(
        sourceShowroomId: 'sh-001',
        destinationShowroomId: 'sh-002',
        vehicleIds: [availableVehicle.id],
        notes: 'Transfer to fulfill customer booking at Pune West Hub',
      );

      expect(transfer.id.isNotEmpty, isTrue);
      expect(transfer.status, equals('requested'));
      expect(transfer.items.length, equals(1));

      // 2. Dispatch Transfer
      await inventoryService.dispatchStockTransfer(transfer.id);

      final dispatchedTransfers = await inventoryService.fetchStockTransfers(status: 'in_transit');
      expect(dispatchedTransfers.any((t) => t.id == transfer.id), isTrue);

      // Check vehicle status became 'in_transit'
      final inTransitVehicle = await inventoryService.fetchVehicleById(availableVehicle.id);
      expect(inTransitVehicle!.vehicle.status, equals('in_transit'));

      // 3. Receive Transfer at Pune showroom
      await inventoryService.receiveStockTransfer(transfer.id);

      final completedTransfers = await inventoryService.fetchStockTransfers(status: 'received');
      expect(completedTransfers.any((t) => t.id == transfer.id), isTrue);

      // Check vehicle showroomId was transferred to Pune (sh-002)
      final receivedVehicle = await inventoryService.fetchVehicleById(availableVehicle.id);
      expect(receivedVehicle!.vehicle.showroomId, equals('sh-002'));
      expect(receivedVehicle.vehicle.status, equals('in_stock'));
    });

    test('4. Stock Movement Audit Trail Verification', () async {
      final mumbaiStock = await inventoryService.fetchInventory(showroomId: 'sh-001');
      final targetVehicle = mumbaiStock.first.vehicle;

      final movements = await inventoryService.fetchVehicleMovements(targetVehicle.id);
      expect(movements, isNotNull);
    });
  });
}
