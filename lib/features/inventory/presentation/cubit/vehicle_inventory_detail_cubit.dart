import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/inventory_management_service.dart';
import 'vehicle_inventory_detail_state.dart';

class VehicleInventoryDetailCubit extends Cubit<VehicleInventoryDetailState> {
  final InventoryManagementService _service;
  final String vehicleId;

  VehicleInventoryDetailCubit({
    required this.vehicleId,
    InventoryManagementService? service,
  })  : _service = service ?? InventoryManagementService.instance,
        super(const VehicleInventoryDetailState());

  Future<void> loadDetails() async {
    emit(state.copyWith(status: VehicleInventoryDetailStatus.loading));
    try {
      final item = await _service.fetchVehicleById(vehicleId);
      if (item == null) {
        emit(state.copyWith(
          status: VehicleInventoryDetailStatus.failure,
          errorMessage: () => 'Vehicle unit not found in inventory',
        ));
        return;
      }

      final movements = await _service.fetchVehicleMovements(vehicleId);

      emit(state.copyWith(
        status: VehicleInventoryDetailStatus.success,
        item: item,
        movements: movements,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VehicleInventoryDetailStatus.failure,
        errorMessage: () => 'Failed to load vehicle details: $e',
      ));
    }
  }

  Future<bool> updatePdi(String pdiStatus, {String? notes}) async {
    emit(state.copyWith(isUpdating: true));
    try {
      await _service.updatePdiStatus(vehicleId, pdiStatus, notes: notes);
      await loadDetails();
      emit(state.copyWith(isUpdating: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: () => 'Failed to update PDI status: $e',
      ));
      return false;
    }
  }

  Future<bool> updateLocation(String location) async {
    emit(state.copyWith(isUpdating: true));
    try {
      await _service.updateVehicleLocation(vehicleId, location);
      await loadDetails();
      emit(state.copyWith(isUpdating: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: () => 'Failed to update showroom location: $e',
      ));
      return false;
    }
  }

  Future<bool> updateStatus(String status, {String? remarks}) async {
    emit(state.copyWith(isUpdating: true));
    try {
      await _service.updateVehicleStatus(vehicleId, status, remarks: remarks);
      await loadDetails();
      emit(state.copyWith(isUpdating: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: () => 'Failed to update status: $e',
      ));
      return false;
    }
  }
}
