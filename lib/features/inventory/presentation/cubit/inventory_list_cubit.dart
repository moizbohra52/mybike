import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/inventory_management_service.dart';
import '../../../../core/services/showroom_management_service.dart';
import 'inventory_list_state.dart';

class InventoryListCubit extends Cubit<InventoryListState> {
  final InventoryManagementService _inventoryService;
  final ShowroomManagementService _showroomService;

  InventoryListCubit({
    InventoryManagementService? inventoryService,
    ShowroomManagementService? showroomService,
  })  : _inventoryService = inventoryService ?? InventoryManagementService.instance,
        _showroomService = showroomService ?? ShowroomManagementService.instance,
        super(const InventoryListState());

  Future<void> loadInventory() async {
    emit(state.copyWith(status: InventoryListStatus.loading));
    try {
      final showrooms = await _showroomService.fetchShowrooms();
      final items = await _inventoryService.fetchInventory(
        showroomId: state.selectedShowroomId,
        status: state.selectedStatus,
        pdiStatus: state.selectedPdiStatus,
        powertrain: state.selectedPowertrain,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      emit(state.copyWith(
        status: InventoryListStatus.success,
        items: items,
        showrooms: showrooms,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryListStatus.failure,
        errorMessage: () => 'Failed to load inventory: $e',
      ));
    }
  }

  Future<void> filterByShowroom(String? showroomId) async {
    emit(state.copyWith(selectedShowroomId: () => showroomId));
    await loadInventory();
  }

  Future<void> filterByStatus(String? status) async {
    final clean = (status == null || status == 'all') ? null : status;
    emit(state.copyWith(selectedStatus: () => clean));
    await loadInventory();
  }

  Future<void> filterByPowertrain(String? powertrain) async {
    final clean = (powertrain == null || powertrain == 'all') ? null : powertrain;
    emit(state.copyWith(selectedPowertrain: () => clean));
    await loadInventory();
  }

  Future<void> filterByPdiStatus(String? pdiStatus) async {
    final clean = (pdiStatus == null || pdiStatus == 'all') ? null : pdiStatus;
    emit(state.copyWith(selectedPdiStatus: () => clean));
    await loadInventory();
  }

  Future<void> search(String query) async {
    emit(state.copyWith(searchQuery: query));
    await loadInventory();
  }
}
