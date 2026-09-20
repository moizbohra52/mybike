import 'package:equatable/equatable.dart';
import '../../domain/entities/gst_summary_entity.dart';

enum GstDashboardStatus { initial, loading, success, failure }

class GstDashboardState extends Equatable {
  final GstDashboardStatus status;
  final GstSummaryEntity? summary;
  final String selectedPeriod; // e.g. "2026-09"
  final String? errorMessage;

  const GstDashboardState({
    this.status = GstDashboardStatus.initial,
    this.summary,
    this.selectedPeriod = '2026-09',
    this.errorMessage,
  });

  GstDashboardState copyWith({
    GstDashboardStatus? status,
    GstSummaryEntity? summary,
    String? selectedPeriod,
    String? errorMessage,
  }) {
    return GstDashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, selectedPeriod, errorMessage];
}
