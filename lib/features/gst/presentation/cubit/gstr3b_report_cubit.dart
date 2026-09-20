import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/gst_management_service.dart';
import 'gstr3b_report_state.dart';

class Gstr3bReportCubit extends Cubit<Gstr3bReportState> {
  final GstManagementService _service;

  Gstr3bReportCubit({GstManagementService? service})
      : _service = service ?? GstManagementService(),
        super(const Gstr3bReportState());

  Future<void> loadReport({String? period, String? showroomId}) async {
    final filingPeriod = period ?? state.selectedPeriod;
    emit(state.copyWith(status: Gstr3bReportStatus.loading, selectedPeriod: filingPeriod));

    try {
      final report = await _service.generateGstr3bReport(
        filingPeriod: filingPeriod,
        showroomId: showroomId,
      );
      emit(state.copyWith(
        status: Gstr3bReportStatus.success,
        report: report,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Gstr3bReportStatus.failure,
        errorMessage: 'Failed to generate GSTR-3B return: $e',
      ));
    }
  }

  void setSection(int sectionIndex) {
    emit(state.copyWith(activeSection: sectionIndex));
  }

  Future<void> changePeriod(String period) async {
    await loadReport(period: period);
  }
}
