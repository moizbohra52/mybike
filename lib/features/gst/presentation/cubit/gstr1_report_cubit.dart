import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/gst_management_service.dart';
import 'gstr1_report_state.dart';

class Gstr1ReportCubit extends Cubit<Gstr1ReportState> {
  final GstManagementService _service;

  Gstr1ReportCubit({GstManagementService? service})
      : _service = service ?? GstManagementService(),
        super(const Gstr1ReportState());

  Future<void> loadReport({String? period, String? showroomId}) async {
    final filingPeriod = period ?? state.selectedPeriod;
    emit(state.copyWith(status: Gstr1ReportStatus.loading, selectedPeriod: filingPeriod));

    try {
      final report = await _service.generateGstr1Report(
        filingPeriod: filingPeriod,
        showroomId: showroomId,
      );
      emit(state.copyWith(
        status: Gstr1ReportStatus.success,
        report: report,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Gstr1ReportStatus.failure,
        errorMessage: 'Failed to generate GSTR-1 return: $e',
      ));
    }
  }

  void setTab(int tabIndex) {
    emit(state.copyWith(activeTab: tabIndex));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> changePeriod(String period) async {
    await loadReport(period: period);
  }
}
