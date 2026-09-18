import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/vehicle_master_service.dart';
import '../../domain/entities/vehicle_color_entity.dart';
import '../../domain/entities/vehicle_variant_entity.dart';
import 'vehicle_detail_state.dart';

class VehicleDetailCubit extends Cubit<VehicleDetailState> {
  final VehicleMasterService _service;
  final String modelId;

  VehicleDetailCubit({
    required this.modelId,
    VehicleMasterService? service,
  })  : _service = service ?? VehicleMasterService.instance,
        super(const VehicleDetailState());

  Future<void> loadDetails() async {
    emit(state.copyWith(status: VehicleDetailStatus.loading));
    try {
      final item = await _service.fetchCatalogItemById(modelId);
      if (item == null) {
        emit(state.copyWith(
          status: VehicleDetailStatus.failure,
          errorMessage: () => 'Vehicle model not found',
        ));
        return;
      }

      emit(state.copyWith(
        status: VehicleDetailStatus.success,
        item: item,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VehicleDetailStatus.failure,
        errorMessage: () => 'Failed to load details: $e',
      ));
    }
  }

  Future<bool> saveVariant(VehicleVariantEntity variant) async {
    emit(state.copyWith(isActionInProgress: true));
    try {
      if (variant.id.isEmpty) {
        final newId = 'v-${DateTime.now().millisecondsSinceEpoch}';
        await _service.createVariant(variant.copyWith(id: newId));
      } else {
        await _service.updateVariant(variant);
      }
      await loadDetails();
      emit(state.copyWith(isActionInProgress: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isActionInProgress: false,
        errorMessage: () => 'Failed to save variant: $e',
      ));
      return false;
    }
  }

  Future<bool> deleteVariant(String variantId) async {
    emit(state.copyWith(isActionInProgress: true));
    try {
      await _service.deleteVariant(variantId);
      await loadDetails();
      emit(state.copyWith(isActionInProgress: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isActionInProgress: false,
        errorMessage: () => 'Failed to delete variant: $e',
      ));
      return false;
    }
  }

  Future<bool> saveColor(VehicleColorEntity color) async {
    emit(state.copyWith(isActionInProgress: true));
    try {
      if (color.id.isEmpty) {
        final newId = 'c-${DateTime.now().millisecondsSinceEpoch}';
        await _service.createColor(color.copyWith(id: newId));
      } else {
        await _service.updateColor(color);
      }
      await loadDetails();
      emit(state.copyWith(isActionInProgress: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isActionInProgress: false,
        errorMessage: () => 'Failed to save color: $e',
      ));
      return false;
    }
  }

  Future<bool> deleteColor(String colorId) async {
    emit(state.copyWith(isActionInProgress: true));
    try {
      await _service.deleteColor(colorId);
      await loadDetails();
      emit(state.copyWith(isActionInProgress: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isActionInProgress: false,
        errorMessage: () => 'Failed to delete color: $e',
      ));
      return false;
    }
  }

  Future<bool> deleteModel() async {
    emit(state.copyWith(isActionInProgress: true));
    try {
      await _service.deleteModel(modelId);
      emit(state.copyWith(isActionInProgress: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isActionInProgress: false,
        errorMessage: () => 'Failed to delete model: $e',
      ));
      return false;
    }
  }
}
