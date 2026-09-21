import 'package:equatable/equatable.dart';

/// Audit Log Filtering Value Object
class AuditFilterCriteria extends Equatable {
  final String? showroomId;
  final String? module; // 'all' or specific module
  final String? action; // 'all' or specific action
  final String? userId;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? severity; // 'all', 'info', 'warning', 'critical'

  const AuditFilterCriteria({
    this.showroomId,
    this.module = 'all',
    this.action = 'all',
    this.userId,
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.severity = 'all',
  });

  AuditFilterCriteria copyWith({
    String? showroomId,
    String? module,
    String? action,
    String? userId,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    String? severity,
    bool clearModule = false,
    bool clearAction = false,
    bool clearSeverity = false,
    bool clearDateRange = false,
  }) {
    return AuditFilterCriteria(
      showroomId: showroomId ?? this.showroomId,
      module: clearModule ? 'all' : (module ?? this.module),
      action: clearAction ? 'all' : (action ?? this.action),
      userId: userId ?? this.userId,
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: clearDateRange ? null : (startDate ?? this.startDate),
      endDate: clearDateRange ? null : (endDate ?? this.endDate),
      severity: clearSeverity ? 'all' : (severity ?? this.severity),
    );
  }

  @override
  List<Object?> get props => [
        showroomId,
        module,
        action,
        userId,
        searchQuery,
        startDate,
        endDate,
        severity,
      ];
}
