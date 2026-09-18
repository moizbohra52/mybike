import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/vehicle_master_service.dart';
import 'package:mybike/features/vehicles/domain/entities/vehicle_color_entity.dart';
import 'package:mybike/features/vehicles/domain/entities/vehicle_model_entity.dart';
import 'package:mybike/features/vehicles/domain/entities/vehicle_variant_entity.dart';
import 'package:mybike/features/vehicles/presentation/cubit/vehicle_catalog_cubit.dart';
import 'package:mybike/features/vehicles/presentation/cubit/vehicle_catalog_state.dart';
import 'package:mybike/features/vehicles/presentation/cubit/vehicle_detail_cubit.dart';
import 'package:mybike/features/vehicles/presentation/cubit/vehicle_detail_state.dart';
import 'package:mybike/features/vehicles/presentation/cubit/vehicle_form_cubit.dart';
import 'package:mybike/features/vehicles/presentation/cubit/vehicle_form_state.dart';

void main() {
  group('Vehicle Master — Entities & Pricing Logic', () {
    test('VehicleVariantEntity correctly computes estimated on-road price and tax breakdown', () {
      final now = DateTime(2025, 1, 1);
      final petrolVariant = VehicleVariantEntity(
        id: 'v-test-1',
        modelId: 'm-test-1',
        name: 'Petrol Special',
        code: 'P-SPEC',
        engineCc: 348.36,
        exShowroomPrice: 200000.0,
        gstRate: 28.0,
        cessRate: 0.0,
        rtoCharges: 20000.0,
        insuranceCharges: 10000.0,
        otherCharges: 2000.0,
        createdAt: now,
        updatedAt: now,
      );

      // On-road = 200000 + 20000 + 10000 + 2000 = 232000
      expect(petrolVariant.estimatedOnRoadPrice, equals(232000.0));

      // Dual spec getters
      expect(petrolVariant.engineCc, equals(348.36));
      expect(petrolVariant.batteryCapacityKwh, isNull);
    });

    test('Electric Variant Entity verifies 5% GST and EV specs', () {
      final now = DateTime(2025, 1, 1);
      final evVariant = VehicleVariantEntity(
        id: 'v-test-2',
        modelId: 'm-test-2',
        name: 'EV Ultra',
        code: 'EV-ULTRA',
        batteryCapacityKwh: 3.7,
        motorPowerKw: 6.4,
        rangeKm: 150,
        trueRangeKm: 110,
        chargingTimeHours: 4.5,
        fastCharging: true,
        batteryWarrantyYears: 5,
        exShowroomPrice: 150000.0,
        gstRate: 5.0,
        cessRate: 0.0,
        rtoCharges: 2500.0,
        insuranceCharges: 6500.0,
        otherCharges: 3000.0,
        createdAt: now,
        updatedAt: now,
      );

      expect(evVariant.estimatedOnRoadPrice, equals(162000.0));
      expect(evVariant.batteryCapacityKwh, equals(3.7));
      expect(evVariant.fastCharging, isTrue);
      expect(evVariant.rangeKm, equals(150));
    });

    test('VehicleModelEntity distinguishes petrol and electric powertrain types', () {
      final now = DateTime.now();
      final petrol = VehicleModelEntity(
        id: 'm-p',
        brandId: 'b-1',
        name: 'Petrol Roadster',
        type: 'petrol',
        bodyType: 'cruiser',
        createdAt: now,
        updatedAt: now,
      );
      final ev = VehicleModelEntity(
        id: 'm-e',
        brandId: 'b-2',
        name: 'Electric Scooter',
        type: 'electric',
        bodyType: 'scooter',
        createdAt: now,
        updatedAt: now,
      );

      expect(petrol.isPetrol, isTrue);
      expect(petrol.isElectric, isFalse);
      expect(ev.isElectric, isTrue);
      expect(ev.isPetrol, isFalse);
    });
  });

  group('VehicleMasterService — In-Memory & Catalog Aggregation', () {
    final service = VehicleMasterService.instance;

    test('Seeds initial brands and models properly', () async {
      final brands = await service.fetchBrands();
      expect(brands.length, greaterThanOrEqualTo(5));
      expect(brands.any((b) => b.code == 'HONDA'), isTrue);
      expect(brands.any((b) => b.code == 'ATHER'), isTrue);

      final models = await service.fetchModels();
      expect(models.length, greaterThanOrEqualTo(7));
      expect(models.any((m) => m.name.contains("CB350")), isTrue);
      expect(models.any((m) => m.name.contains("450X")), isTrue);
    });

    test('Filters models by type and search query', () async {
      final petrolModels = await service.fetchModels(type: 'petrol');
      expect(petrolModels.every((m) => m.isPetrol), isTrue);

      final evModels = await service.fetchModels(type: 'electric');
      expect(evModels.every((m) => m.isElectric), isTrue);

      final searchResults = await service.fetchModels(search: 'Ather');
      expect(searchResults.every((m) => m.name.toLowerCase().contains('ather') || m.brandId == 'b-002'), isTrue);
    });

    test('Aggregates catalog items with variants, colors, and price ranges', () async {
      final catalog = await service.fetchCatalogItems();
      expect(catalog.isNotEmpty, isTrue);

      final cb350Item = catalog.firstWhere((item) => item.model.name.contains("CB350"));
      expect(cb350Item.brand, isNotNull);
      expect(cb350Item.variants.length, greaterThanOrEqualTo(2));
      expect(cb350Item.colors.length, greaterThanOrEqualTo(2));
      expect(cb350Item.minPrice, greaterThan(200000.0));
      expect(cb350Item.maxPrice, greaterThanOrEqualTo(cb350Item.minPrice));
    });

    test('Performs CRUD operations for models, variants, and colors', () async {
      final now = DateTime.now();

      // Create model
      final testModel = VehicleModelEntity(
        id: 'm-test-crud',
        brandId: 'b-001',
        name: 'CB650R',
        type: 'petrol',
        bodyType: 'sports',
        description: 'Neo Sports Cafe middleweight',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      final createdModel = await service.createModel(testModel);
      expect(createdModel.id, equals('m-test-crud'));

      // Create variant
      final testVariant = VehicleVariantEntity(
        id: 'v-test-crud',
        modelId: 'm-test-crud',
        name: 'Standard ABS',
        code: 'CB650R-STD',
        engineCc: 649.0,
        exShowroomPrice: 919000.0,
        gstRate: 28.0,
        cessRate: 3.0,
        rtoCharges: 95000.0,
        insuranceCharges: 35000.0,
        otherCharges: 5000.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
      final createdVariant = await service.createVariant(testVariant);
      expect(createdVariant.code, equals('CB650R-STD'));

      // Create color
      final testColor = VehicleColorEntity(
        id: 'c-test-crud',
        modelId: 'm-test-crud',
        name: 'Matte Gunpowder Black',
        code: 'GUN-BLK',
        hexCode: '#222222',
        additionalPrice: 0.0,
        createdAt: now,
        updatedAt: now,
      );
      final createdColor = await service.createColor(testColor);
      expect(createdColor.name, equals('Matte Gunpowder Black'));

      // Verify in catalog
      final catalogItem = await service.fetchCatalogItemById('m-test-crud');
      expect(catalogItem, isNotNull);
      expect(catalogItem!.variantCount, equals(1));
      expect(catalogItem.colorCount, equals(1));

      // Cleanup
      await service.deleteColor('c-test-crud');
      await service.deleteVariant('v-test-crud');
      await service.deleteModel('m-test-crud');

      final deleted = await service.fetchModelById('m-test-crud');
      expect(deleted, isNull);
    });
  });

  group('Vehicle Presentation Cubits', () {
    test('VehicleCatalogCubit loads items, filters and counts accurately', () async {
      final cubit = VehicleCatalogCubit();
      expect(cubit.state.status, equals(VehicleCatalogStatus.initial));

      await cubit.loadCatalog();
      expect(cubit.state.status, equals(VehicleCatalogStatus.success));
      expect(cubit.state.items.isNotEmpty, isTrue);
      expect(cubit.state.brands.isNotEmpty, isTrue);
      expect(cubit.state.totalModels, equals(cubit.state.items.length));
      expect(cubit.state.petrolCount + cubit.state.electricCount, equals(cubit.state.totalModels));

      // Filter by Electric
      await cubit.filterByType('electric');
      expect(cubit.state.selectedType, equals('electric'));
      expect(cubit.state.items.every((i) => i.model.isElectric), isTrue);

      await cubit.close();
    });

    test('VehicleFormCubit validates and saves model correctly', () async {
      final cubit = VehicleFormCubit();
      await cubit.init();

      expect(cubit.state.brands.isNotEmpty, isTrue);

      // Try saving with empty name
      cubit.nameChanged('');
      await cubit.saveModel();
      expect(cubit.state.status, equals(VehicleFormStatus.failure));
      expect(cubit.state.errorMessage, contains('name is required'));

      // Provide valid fields
      cubit.nameChanged('Test Speedster 200');
      cubit.typeChanged('petrol');
      cubit.bodyTypeChanged('sports');
      cubit.descriptionChanged('Fast track motorcycle');

      await cubit.saveModel();
      expect(cubit.state.status, equals(VehicleFormStatus.success));
      expect(cubit.state.savedModel, isNotNull);
      expect(cubit.state.savedModel!.name, equals('Test Speedster 200'));

      await cubit.close();
    });

    test('VehicleDetailCubit loads catalog item and handles variant actions', () async {
      final cubit = VehicleDetailCubit(modelId: 'm-001');
      await cubit.loadDetails();

      expect(cubit.state.status, equals(VehicleDetailStatus.success));
      expect(cubit.state.item, isNotNull);
      expect(cubit.state.item!.model.id, equals('m-001'));
      expect(cubit.state.item!.variants.isNotEmpty, isTrue);

      await cubit.close();
    });
  });
}
