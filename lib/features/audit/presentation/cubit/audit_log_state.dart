import 'package:equatable/equatable.dart';
import '../../domain/entities/audit_filter_criteria.dart';
import '../../domain/entities/audit_log_entity.dart';

abstract class AuditLogState extends Equatable {
  const AuditLogState();

  @override
  List<Object?> get props => [];
}

class AuditLogInitial extends AuditLogState {
  const AuditLogInitial();
}

class AuditLogLoading extends AuditLogState {
  const AuditLogLoading();
}

class AuditLogLoaded extends AuditLogState {
  final List<AuditLogEntity> logs;
  final AuditFilterCriteria criteria;
  final Map<String, dynamic> metrics;
  final String? successMessage;

  const AuditLogLoaded({
    required this.logs,
    required this.criteria,
    required this.metrics,
    this.successMessage,
  });

  AuditLogLoaded copyWith({
    List<AuditLogEntity>? logs,
    AuditFilterCriteria? criteria,
    Map<String, dynamic>? metrics,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return AuditLogLoaded(
      logs: logs ?? this.logs,
      criteria: criteria ?? this.criteria,
      metrics: metrics ?? this.metrics,
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [logs, criteria, metrics, successMessage];
}

class AuditLogError extends AuditLogState {
  final String message;

  const AuditLogError(this.message);

  @override
  List<Object?> get props => [message];
}
