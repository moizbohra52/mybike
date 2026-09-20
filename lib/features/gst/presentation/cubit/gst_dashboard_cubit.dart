import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/gst_management_service.dart';
import 'gst_dashboard_state.dart';

class GstDashboardCubit extends Cubit<GstDashboardState> {
  final GstManagementService _service;

  GstDashboardCubit({GstManagementService? service})
      : _service = service ?? GstManagementService(),
        super(const GstDashboardState());

  Future<void> loadDashboard({String? period, String? showroomId}) async {
    final filingPeriod = period ?? state.selectedPeriod;
    emit(state.copyWith(status: GstDashboardStatus.loading, selectedPeriod: filingPeriod));

    try {
      final summary = await _service.getGstSummary(
        filingPeriod: filingPeriod,
        showroomId: showroomId,
      );
      emit(state.copyWith(
        status: GstDashboardStatus.success,
        summary: summary,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GstDashboardStatus.failure,
        errorMessage: 'Failed to load GST summary: $e',
      ));
    }
  }

  Future<void> changePeriod(String newPeriod) async {
    await loadDashboard(period: newPeriod);
  }
}
