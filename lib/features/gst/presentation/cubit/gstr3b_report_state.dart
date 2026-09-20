import 'package:equatable/equatable.dart';
import '../../domain/entities/gstr3b_report_entity.dart';

enum Gstr3bReportStatus { initial, loading, success, failure }

class Gstr3bReportState extends Equatable {
  final Gstr3bReportStatus status;
  final Gstr3bReportEntity? report;
  final String selectedPeriod;
  final int activeSection; // 0: Table 3.1 Outward, 1: Table 4 Eligible ITC, 2: Table 6.1 Tax Payment
  final String? errorMessage;

  const Gstr3bReportState({
    this.status = Gstr3bReportStatus.initial,
    this.report,
    this.selectedPeriod = '2026-09',
    this.activeSection = 0,
    this.errorMessage,
  });

  Gstr3bReportState copyWith({
    Gstr3bReportStatus? status,
    Gstr3bReportEntity? report,
    String? selectedPeriod,
    int? activeSection,
    String? errorMessage,
  }) {
    return Gstr3bReportState(
      status: status ?? this.status,
      report: report ?? this.report,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      activeSection: activeSection ?? this.activeSection,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        report,
        selectedPeriod,
        activeSection,
        errorMessage,
      ];
}
