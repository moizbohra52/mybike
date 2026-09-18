import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/vehicle_master_service.dart';
import 'vehicle_catalog_state.dart';

class VehicleCatalogCubit extends Cubit<VehicleCatalogState> {
  final VehicleMasterService _service;

  VehicleCatalogCubit({VehicleMasterService? service})
      : _service = service ?? VehicleMasterService.instance,
        super(const VehicleCatalogState());

  Future<void> loadCatalog() async {
    emit(state.copyWith(status: VehicleCatalogStatus.loading));
    try {
      final brands = await _service.fetchBrands(isActive: true);
      final items = await _service.fetchCatalogItems(
        brandId: state.selectedBrandId,
        type: state.selectedType,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      emit(state.copyWith(
        status: VehicleCatalogStatus.success,
        items: items,
        brands: brands,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VehicleCatalogStatus.failure,
        errorMessage: () => 'Failed to load vehicle catalog: $e',
      ));
    }
  }

  Future<void> filterByBrand(String? brandId) async {
    emit(state.copyWith(selectedBrandId: () => brandId));
    await loadCatalog();
  }

  Future<void> filterByType(String? type) async {
    final cleanType = (type == null || type == 'all') ? null : type;
    emit(state.copyWith(selectedType: () => cleanType));
    await loadCatalog();
  }

  Future<void> search(String query) async {
    emit(state.copyWith(searchQuery: query));
    await loadCatalog();
  }

  Future<void> deleteModel(String modelId) async {
    try {
      await _service.deleteModel(modelId);
      await loadCatalog();
    } catch (e) {
      emit(state.copyWith(
        status: VehicleCatalogStatus.failure,
        errorMessage: () => 'Failed to delete vehicle model: $e',
      ));
    }
  }
}
