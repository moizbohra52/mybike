import 'package:equatable/equatable.dart';
import '../../domain/entities/report_filter_criteria.dart';
import '../../domain/entities/report_row_item.dart';

enum ReportViewerStatus { initial, loading, success, failure }

class ReportViewerState extends Equatable {
  final ReportViewerStatus status;
  final String reportType;
  final String title;
  final String subtitle;
  final ReportFilterCriteria criteria;
  final List<ReportColumnDef> columns;
  final List<ReportRowItem> rows;
  final List<Map<String, dynamic>> summaryCards;
  final dynamic rawReportData;
  final String? errorMessage;

  const ReportViewerState({
    this.status = ReportViewerStatus.initial,
    required this.reportType,
    this.title = '',
    this.subtitle = '',
    required this.criteria,
    this.columns = const [],
    this.rows = const [],
    this.summaryCards = const [],
    this.rawReportData,
    this.errorMessage,
  });

  ReportViewerState copyWith({
    ReportViewerStatus? status,
    String? reportType,
    String? title,
    String? subtitle,
    ReportFilterCriteria? criteria,
    List<ReportColumnDef>? columns,
    List<ReportRowItem>? rows,
    List<Map<String, dynamic>>? summaryCards,
    dynamic rawReportData,
    String? errorMessage,
  }) {
    return ReportViewerState(
      status: status ?? this.status,
      reportType: reportType ?? this.reportType,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      criteria: criteria ?? this.criteria,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      summaryCards: summaryCards ?? this.summaryCards,
      rawReportData: rawReportData ?? this.rawReportData,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reportType,
        title,
        subtitle,
        criteria,
        columns,
        rows,
        summaryCards,
        rawReportData,
        errorMessage,
      ];
}
