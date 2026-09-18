import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/vehicle_master_service.dart';
import '../../domain/entities/vehicle_model_entity.dart';
import 'vehicle_form_state.dart';

class VehicleFormCubit extends Cubit<VehicleFormState> {
  final VehicleMasterService _service;

  VehicleFormCubit({VehicleMasterService? service})
      : _service = service ?? VehicleMasterService.instance,
        super(const VehicleFormState());

  Future<void> init({String? modelId}) async {
    emit(state.copyWith(status: VehicleFormStatus.loading));
    try {
      final brands = await _service.fetchBrands(isActive: true);
      if (modelId != null) {
        final model = await _service.fetchModelById(modelId);
        if (model != null) {
          emit(state.copyWith(
            status: VehicleFormStatus.initial,
            initialModel: model,
            brands: brands,
            brandId: () => model.brandId,
            name: model.name,
            type: model.type,
            bodyType: model.bodyType,
            description: model.description ?? '',
            isActive: model.isActive,
          ));
          return;
        }
      }

      emit(state.copyWith(
        status: VehicleFormStatus.initial,
        brands: brands,
        brandId: () => brands.isNotEmpty ? brands.first.id : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VehicleFormStatus.failure,
        errorMessage: () => 'Failed to initialize form: $e',
      ));
    }
  }

  void brandChanged(String brandId) {
    emit(state.copyWith(brandId: () => brandId));
  }

  void nameChanged(String name) {
    emit(state.copyWith(name: name));
  }

  void typeChanged(String type) {
    emit(state.copyWith(type: type));
  }

  void bodyTypeChanged(String bodyType) {
    emit(state.copyWith(bodyType: bodyType));
  }

  void descriptionChanged(String description) {
    emit(state.copyWith(description: description));
  }

  void isActiveChanged(bool isActive) {
    emit(state.copyWith(isActive: isActive));
  }

  Future<void> saveModel() async {
    if (state.brandId == null || state.brandId!.isEmpty) {
      emit(state.copyWith(
        status: VehicleFormStatus.failure,
        errorMessage: () => 'Please select a brand',
      ));
      return;
    }

    if (state.name.trim().isEmpty) {
      emit(state.copyWith(
        status: VehicleFormStatus.failure,
        errorMessage: () => 'Model name is required',
      ));
      return;
    }

    emit(state.copyWith(status: VehicleFormStatus.submitting));
    try {
      final now = DateTime.now();
      VehicleModelEntity saved;
      if (state.isEditing) {
        final updated = state.initialModel!.copyWith(
          brandId: state.brandId,
          name: state.name.trim(),
          type: state.type,
          bodyType: state.bodyType,
          description: state.description.trim().isNotEmpty ? state.description.trim() : null,
          isActive: state.isActive,
          updatedAt: now,
        );
        saved = await _service.updateModel(updated);
      } else {
        final newModel = VehicleModelEntity(
          id: 'm-${now.millisecondsSinceEpoch}',
          brandId: state.brandId!,
          name: state.name.trim(),
          type: state.type,
          bodyType: state.bodyType,
          description: state.description.trim().isNotEmpty ? state.description.trim() : null,
          isActive: state.isActive,
          createdAt: now,
          updatedAt: now,
        );
        saved = await _service.createModel(newModel);
      }

      emit(state.copyWith(
        status: VehicleFormStatus.success,
        savedModel: saved,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VehicleFormStatus.failure,
        errorMessage: () => 'Failed to save model: $e',
      ));
    }
  }
}
