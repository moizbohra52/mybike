import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/inventory_management_service.dart';
import '../../../../core/services/showroom_management_service.dart';
import '../../../../core/services/vehicle_master_service.dart';
import 'stock_inward_state.dart';

class StockInwardCubit extends Cubit<StockInwardState> {
  final InventoryManagementService _inventoryService;
  final ShowroomManagementService _showroomService;
  final VehicleMasterService _vehicleService;

  StockInwardCubit({
    InventoryManagementService? inventoryService,
    ShowroomManagementService? showroomService,
    VehicleMasterService? vehicleService,
  })  : _inventoryService = inventoryService ?? InventoryManagementService.instance,
        _showroomService = showroomService ?? ShowroomManagementService.instance,
        _vehicleService = vehicleService ?? VehicleMasterService.instance,
        super(const StockInwardState());

  Future<void> init() async {
    emit(state.copyWith(status: StockInwardStatus.loading));
    try {
      final showrooms = await _showroomService.fetchShowrooms(isActive: true);
      final catalog = await _vehicleService.fetchCatalogItems(isActive: true);

      final initialShowroomId = showrooms.isNotEmpty ? showrooms.first.showroom.id : null;
      final initialModel = catalog.isNotEmpty ? catalog.first : null;
      final initialVariantId = initialModel?.variants.isNotEmpty == true ? initialModel!.variants.first.id : null;
      final initialColorId = initialModel?.colors.isNotEmpty == true ? initialModel!.colors.first.id : null;

      emit(state.copyWith(
        status: StockInwardStatus.initial,
        showrooms: showrooms,
        catalog: catalog,
        selectedShowroomId: () => initialShowroomId,
        selectedModelId: () => initialModel?.model.id,
        selectedVariantId: () => initialVariantId,
        selectedColorId: () => initialColorId,
        units: [],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StockInwardStatus.failure,
        errorMessage: () => 'Failed to initialize inward form: $e',
      ));
    }
  }

  void showroomChanged(String showroomId) {
    emit(state.copyWith(selectedShowroomId: () => showroomId));
  }

  void modelChanged(String modelId) {
    final catItem = state.catalog.where((c) => c.model.id == modelId).firstOrNull;
    final variantId = catItem?.variants.isNotEmpty == true ? catItem!.variants.first.id : null;
    final colorId = catItem?.colors.isNotEmpty == true ? catItem!.colors.first.id : null;

    emit(state.copyWith(
      selectedModelId: () => modelId,
      selectedVariantId: () => variantId,
      selectedColorId: () => colorId,
    ));
  }

  void variantChanged(String variantId) {
    emit(state.copyWith(selectedVariantId: () => variantId));
  }

  void colorChanged(String colorId) {
    emit(state.copyWith(selectedColorId: () => colorId));
  }

  void remarksChanged(String remarks) {
    emit(state.copyWith(remarks: remarks));
  }

  void addUnit(InwardVehicleUnit unit) {
    final updated = List<InwardVehicleUnit>.from(state.units)..add(unit);
    emit(state.copyWith(units: updated));
  }

  void removeUnit(int index) {
    final updated = List<InwardVehicleUnit>.from(state.units)..removeAt(index);
    emit(state.copyWith(units: updated));
  }

  Future<void> submitInward() async {
    if (state.selectedShowroomId == null) {
      emit(state.copyWith(
        status: StockInwardStatus.failure,
        errorMessage: () => 'Please select receiving showroom',
      ));
      return;
    }

    if (state.selectedVariantId == null || state.selectedColorId == null) {
      emit(state.copyWith(
        status: StockInwardStatus.failure,
        errorMessage: () => 'Please select model, variant and color',
      ));
      return;
    }

    if (state.units.isEmpty) {
      emit(state.copyWith(
        status: StockInwardStatus.failure,
        errorMessage: () => 'Please add at least one vehicle unit with VIN',
      ));
      return;
    }

    emit(state.copyWith(status: StockInwardStatus.submitting));
    try {
      await _inventoryService.inwardStock(
        showroomId: state.selectedShowroomId!,
        variantId: state.selectedVariantId!,
        colorId: state.selectedColorId!,
        units: state.units,
        remarks: state.remarks,
      );

      emit(state.copyWith(status: StockInwardStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: StockInwardStatus.failure,
        errorMessage: () => 'Failed to inward stock: $e',
      ));
    }
  }
}
