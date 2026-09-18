import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/inventory_management_service.dart';
import '../../../../core/services/showroom_management_service.dart';
import 'stock_transfer_state.dart';

class StockTransferCubit extends Cubit<StockTransferState> {
  final InventoryManagementService _inventoryService;
  final ShowroomManagementService _showroomService;

  StockTransferCubit({
    InventoryManagementService? inventoryService,
    ShowroomManagementService? showroomService,
  })  : _inventoryService = inventoryService ?? InventoryManagementService.instance,
        _showroomService = showroomService ?? ShowroomManagementService.instance,
        super(const StockTransferState());

  Future<void> loadTransfers() async {
    emit(state.copyWith(status: StockTransferStatus.loading));
    try {
      final showrooms = await _showroomService.fetchShowrooms(isActive: true);
      final transfers = await _inventoryService.fetchStockTransfers();

      emit(state.copyWith(
        status: StockTransferStatus.success,
        showrooms: showrooms,
        transfers: transfers,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StockTransferStatus.failure,
        errorMessage: () => 'Failed to load stock transfers: $e',
      ));
    }
  }

  Future<void> selectSourceShowroom(String sourceId) async {
    emit(state.copyWith(
      selectedSourceShowroomId: () => sourceId,
      selectedVehicleIds: [],
    ));

    try {
      final vehicles = await _inventoryService.fetchInventory(
        showroomId: sourceId,
        status: 'in_stock',
      );
      emit(state.copyWith(availableVehicles: vehicles));
    } catch (e) {
      emit(state.copyWith(errorMessage: () => 'Failed to load branch vehicles: $e'));
    }
  }

  void selectDestShowroom(String destId) {
    emit(state.copyWith(selectedDestShowroomId: () => destId));
  }

  void toggleVehicleSelection(String vehicleId) {
    final list = List<String>.from(state.selectedVehicleIds);
    if (list.contains(vehicleId)) {
      list.remove(vehicleId);
    } else {
      list.add(vehicleId);
    }
    emit(state.copyWith(selectedVehicleIds: list));
  }

  void notesChanged(String notes) {
    emit(state.copyWith(notes: notes));
  }

  Future<bool> createTransfer() async {
    if (state.selectedSourceShowroomId == null || state.selectedDestShowroomId == null) {
      emit(state.copyWith(errorMessage: () => 'Please select source and destination branches'));
      return false;
    }
    if (state.selectedSourceShowroomId == state.selectedDestShowroomId) {
      emit(state.copyWith(errorMessage: () => 'Source and destination branches cannot be the same'));
      return false;
    }
    if (state.selectedVehicleIds.isEmpty) {
      emit(state.copyWith(errorMessage: () => 'Please select at least one vehicle to transfer'));
      return false;
    }

    emit(state.copyWith(isSubmitting: true));
    try {
      await _inventoryService.createStockTransfer(
        sourceShowroomId: state.selectedSourceShowroomId!,
        destinationShowroomId: state.selectedDestShowroomId!,
        vehicleIds: state.selectedVehicleIds,
        notes: state.notes,
      );

      emit(state.copyWith(isSubmitting: false));
      await loadTransfers();
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: () => 'Failed to create transfer: $e',
      ));
      return false;
    }
  }

  Future<void> dispatchTransfer(String transferId) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await _inventoryService.dispatchStockTransfer(transferId);
      emit(state.copyWith(isSubmitting: false));
      await loadTransfers();
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: () => 'Failed to dispatch transfer: $e',
      ));
    }
  }

  Future<void> receiveTransfer(String transferId) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await _inventoryService.receiveStockTransfer(transferId);
      emit(state.copyWith(isSubmitting: false));
      await loadTransfers();
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: () => 'Failed to acknowledge transfer receipt: $e',
      ));
    }
  }
}
