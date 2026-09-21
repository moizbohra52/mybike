import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/audit_trail_service.dart';
import '../../domain/entities/audit_filter_criteria.dart';
import 'audit_log_state.dart';

class AuditLogCubit extends Cubit<AuditLogState> {
  final AuditTrailService _service;

  AuditLogCubit({AuditTrailService? service})
      : _service = service ?? AuditTrailService.instance,
        super(const AuditLogInitial());

  AuditFilterCriteria _currentCriteria = const AuditFilterCriteria();

  AuditFilterCriteria get currentCriteria => _currentCriteria;

  Future<void> loadLogs({AuditFilterCriteria? criteria}) async {
    if (criteria != null) {
      _currentCriteria = criteria;
    }
    emit(const AuditLogLoading());
    try {
      final logs = await _service.fetchLogs(_currentCriteria);
      final metrics = await _service.getAuditMetrics(showroomId: _currentCriteria.showroomId);
      emit(AuditLogLoaded(
        logs: logs,
        criteria: _currentCriteria,
        metrics: metrics,
      ));
    } catch (e) {
      emit(AuditLogError('Failed to load audit logs: $e'));
    }
  }

  Future<void> setModule(String module) async {
    _currentCriteria = _currentCriteria.copyWith(
      module: module == 'all' ? 'all' : module,
      clearModule: module == 'all',
    );
    await loadLogs(criteria: _currentCriteria);
  }

  Future<void> setAction(String action) async {
    _currentCriteria = _currentCriteria.copyWith(
      action: action == 'all' ? 'all' : action,
      clearAction: action == 'all',
    );
    await loadLogs(criteria: _currentCriteria);
  }

  Future<void> setSeverity(String severity) async {
    _currentCriteria = _currentCriteria.copyWith(
      severity: severity == 'all' ? 'all' : severity,
      clearSeverity: severity == 'all',
    );
    await loadLogs(criteria: _currentCriteria);
  }

  Future<void> setSearch(String query) async {
    _currentCriteria = _currentCriteria.copyWith(
      searchQuery: query.trim().isEmpty ? null : query,
    );
    await loadLogs(criteria: _currentCriteria);
  }

  Future<void> setShowroom(String? showroomId) async {
    _currentCriteria = _currentCriteria.copyWith(
      showroomId: showroomId,
    );
    await loadLogs(criteria: _currentCriteria);
  }

  Future<void> setDateRange(DateTime? start, DateTime? end) async {
    _currentCriteria = _currentCriteria.copyWith(
      startDate: start,
      endDate: end,
      clearDateRange: start == null && end == null,
    );
    await loadLogs(criteria: _currentCriteria);
  }

  Future<void> logEvent({
    required String action,
    required String module,
    required String recordId,
    String? recordTitle,
    String? userName,
    String? userEmail,
    String? showroomId,
    String? showroomName,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
    String severity = 'info',
  }) async {
    try {
      await _service.logEvent(
        action: action,
        module: module,
        recordId: recordId,
        recordTitle: recordTitle,
        userName: userName,
        userEmail: userEmail,
        showroomId: showroomId,
        showroomName: showroomName,
        beforeData: beforeData,
        afterData: afterData,
        severity: severity,
      );
      await loadLogs(criteria: _currentCriteria);
    } catch (e) {
      emit(AuditLogError('Failed to record audit log: $e'));
    }
  }

  Future<String> exportCsv() async {
    try {
      return await _service.exportLogsCsv(_currentCriteria);
    } catch (e) {
      emit(AuditLogError('Failed to export audit logs: $e'));
      return '';
    }
  }

  void clearSuccessMessage() {
    if (state is AuditLogLoaded) {
      emit((state as AuditLogLoaded).copyWith(clearSuccessMessage: true));
    }
  }
}
