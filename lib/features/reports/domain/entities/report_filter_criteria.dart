import 'package:equatable/equatable.dart';

/// Common Filter Criteria for all enterprise reports
class ReportFilterCriteria extends Equatable {
  final String? showroomId; // null = All Showrooms
  final String showroomName;
  final String period; // 'month', 'quarter', 'year', 'custom'
  final DateTime startDate;
  final DateTime endDate;
  final String? searchQuery;
  final String? financialYear; // e.g. 'FY 2025-26', 'FY 2026-27'

  const ReportFilterCriteria({
    this.showroomId,
    this.showroomName = 'All Showrooms',
    this.period = 'month',
    required this.startDate,
    required this.endDate,
    this.searchQuery,
    this.financialYear = 'FY 2025-26',
  });

  /// Factory for current month
  factory ReportFilterCriteria.currentMonth({String? showroomId, String showroomName = 'All Showrooms'}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return ReportFilterCriteria(
      showroomId: showroomId,
      showroomName: showroomName,
      period: 'month',
      startDate: start,
      endDate: end,
    );
  }

  /// Factory for current financial year (April 1 to March 31)
  factory ReportFilterCriteria.currentFinancialYear({String? showroomId, String showroomName = 'All Showrooms'}) {
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    final start = DateTime(startYear, 4, 1);
    final end = DateTime(startYear + 1, 3, 31, 23, 59, 59);
    return ReportFilterCriteria(
      showroomId: showroomId,
      showroomName: showroomName,
      period: 'year',
      startDate: start,
      endDate: end,
      financialYear: 'FY $startYear-${(startYear + 1).toString().substring(2)}',
    );
  }

  ReportFilterCriteria copyWith({
    String? showroomId,
    bool clearShowroom = false,
    String? showroomName,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? financialYear,
  }) {
    return ReportFilterCriteria(
      showroomId: clearShowroom ? null : (showroomId ?? this.showroomId),
      showroomName: clearShowroom ? 'All Showrooms' : (showroomName ?? this.showroomName),
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
      financialYear: financialYear ?? this.financialYear,
    );
  }

  @override
  List<Object?> get props => [
        showroomId,
        showroomName,
        period,
        startDate,
        endDate,
        searchQuery,
        financialYear,
      ];
}
