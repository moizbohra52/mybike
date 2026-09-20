import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/gst_management_service.dart';
import '../../domain/entities/gst_rate_entity.dart';
import 'gst_rate_config_state.dart';

class GstRateConfigCubit extends Cubit<GstRateConfigState> {
  final GstManagementService _service;

  GstRateConfigCubit({GstManagementService? service})
      : _service = service ?? GstManagementService(),
        super(const GstRateConfigState());

  Future<void> loadRates() async {
    emit(state.copyWith(status: GstRateConfigStatus.loading));
    try {
      final rates = await _service.getTaxRates();
      emit(state.copyWith(
        status: GstRateConfigStatus.success,
        rates: rates,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GstRateConfigStatus.failure,
        errorMessage: 'Failed to load tax rates: $e',
      ));
    }
  }

  void filterByCategory(String? category) {
    if (category == null) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(selectedCategory: category));
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<bool> saveRate(GstRateEntity rate) async {
    try {
      await _service.saveTaxRate(rate);
      await loadRates();
      emit(state.copyWith(actionSuccessMessage: 'Tax slab for ${rate.hsnSacCode} updated successfully'));
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to save tax slab: $e'));
      return false;
    }
  }

  Future<bool> deleteRate(String id) async {
    try {
      await _service.deleteTaxRate(id);
      await loadRates();
      emit(state.copyWith(actionSuccessMessage: 'Tax rate deleted'));
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete tax rate: $e'));
      return false;
    }
  }
}
