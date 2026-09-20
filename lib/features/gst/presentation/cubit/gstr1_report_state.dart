import 'package:equatable/equatable.dart';
import '../../domain/entities/gstr1_report_entity.dart';

enum Gstr1ReportStatus { initial, loading, success, failure }

class Gstr1ReportState extends Equatable {
  final Gstr1ReportStatus status;
  final Gstr1ReportEntity? report;
  final String selectedPeriod;
  final int activeTab; // 0: B2B, 1: B2C Large, 2: B2C Small, 3: CDNR Notes, 4: HSN Summary, 5: Doc Summary
  final String searchQuery;
  final String? errorMessage;

  const Gstr1ReportState({
    this.status = Gstr1ReportStatus.initial,
    this.report,
    this.selectedPeriod = '2026-09',
    this.activeTab = 0,
    this.searchQuery = '',
    this.errorMessage,
  });

  Gstr1ReportState copyWith({
    Gstr1ReportStatus? status,
    Gstr1ReportEntity? report,
    String? selectedPeriod,
    int? activeTab,
    String? searchQuery,
    String? errorMessage,
  }) {
    return Gstr1ReportState(
      status: status ?? this.status,
      report: report ?? this.report,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        report,
        selectedPeriod,
        activeTab,
        searchQuery,
        errorMessage,
      ];
}
