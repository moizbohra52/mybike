import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/approval_workflow_service.dart';
import '../../domain/entities/approval_filter_criteria.dart';
import '../../domain/entities/approval_request_entity.dart';
import 'approval_list_state.dart';

class ApprovalListCubit extends Cubit<ApprovalListState> {
  final ApprovalWorkflowService _service;

  ApprovalListCubit({ApprovalWorkflowService? service})
      : _service = service ?? ApprovalWorkflowService.instance,
        super(const ApprovalListInitial());

  ApprovalFilterCriteria _currentCriteria = const ApprovalFilterCriteria();

  ApprovalFilterCriteria get currentCriteria => _currentCriteria;

  Future<void> loadRequests({ApprovalFilterCriteria? criteria}) async {
    if (criteria != null) {
      _currentCriteria = criteria;
    }
    emit(const ApprovalListLoading());
    try {
      final requests = await _service.fetchRequests(_currentCriteria);
      final allRequests = await _service.fetchRequests(
        ApprovalFilterCriteria(showroomId: _currentCriteria.showroomId),
      );

      final pendingCount = allRequests.where((r) => r.isPending).length;
      final approvedCount = allRequests.where((r) => r.isApproved).length;
      final rejectedCount = allRequests.where((r) => r.isRejected).length;

      emit(ApprovalListLoaded(
        requests: requests,
        criteria: _currentCriteria,
        pendingCount: pendingCount,
        approvedCount: approvedCount,
        rejectedCount: rejectedCount,
      ));
    } catch (e) {
      emit(ApprovalListError('Failed to load approval requests: $e'));
    }
  }

  Future<void> setTransactionType(String type) async {
    _currentCriteria = _currentCriteria.copyWith(
      transactionType: type == 'all' ? 'all' : type,
      clearType: type == 'all',
    );
    await loadRequests(criteria: _currentCriteria);
  }

  Future<void> setStatus(String status) async {
    _currentCriteria = _currentCriteria.copyWith(
      status: status == 'all' ? 'all' : status,
      clearStatus: status == 'all',
    );
    await loadRequests(criteria: _currentCriteria);
  }

  Future<void> setUrgency(String urgency) async {
    _currentCriteria = _currentCriteria.copyWith(
      urgency: urgency == 'all' ? 'all' : urgency,
      clearUrgency: urgency == 'all',
    );
    await loadRequests(criteria: _currentCriteria);
  }

  Future<void> setSearch(String query) async {
    _currentCriteria = _currentCriteria.copyWith(
      searchQuery: query.trim().isEmpty ? null : query,
    );
    await loadRequests(criteria: _currentCriteria);
  }

  Future<void> setShowroom(String? showroomId) async {
    _currentCriteria = _currentCriteria.copyWith(
      showroomId: showroomId,
    );
    await loadRequests(criteria: _currentCriteria);
  }

  Future<void> approveRequest(
    String requestId, {
    required String approverName,
    String? approverId,
    String? notes,
  }) async {
    try {
      await _service.approveRequest(
        requestId,
        approverName: approverName,
        approverId: approverId,
        notes: notes,
      );
      final requests = await _service.fetchRequests(_currentCriteria);
      final allRequests = await _service.fetchRequests(
        ApprovalFilterCriteria(showroomId: _currentCriteria.showroomId),
      );

      final pendingCount = allRequests.where((r) => r.isPending).length;
      final approvedCount = allRequests.where((r) => r.isApproved).length;
      final rejectedCount = allRequests.where((r) => r.isRejected).length;

      emit(ApprovalListLoaded(
        requests: requests,
        criteria: _currentCriteria,
        pendingCount: pendingCount,
        approvedCount: approvedCount,
        rejectedCount: rejectedCount,
        successMessage: 'Request approved successfully.',
      ));
    } catch (e) {
      emit(ApprovalListError('Failed to approve request: $e'));
    }
  }

  Future<void> rejectRequest(
    String requestId, {
    required String approverName,
    required String reason,
    String? approverId,
  }) async {
    try {
      await _service.rejectRequest(
        requestId,
        rejectedBy: approverName,
        reason: reason,
        rejectorId: approverId,
      );
      final requests = await _service.fetchRequests(_currentCriteria);
      final allRequests = await _service.fetchRequests(
        ApprovalFilterCriteria(showroomId: _currentCriteria.showroomId),
      );

      final pendingCount = allRequests.where((r) => r.isPending).length;
      final approvedCount = allRequests.where((r) => r.isApproved).length;
      final rejectedCount = allRequests.where((r) => r.isRejected).length;

      emit(ApprovalListLoaded(
        requests: requests,
        criteria: _currentCriteria,
        pendingCount: pendingCount,
        approvedCount: approvedCount,
        rejectedCount: rejectedCount,
        successMessage: 'Request rejected.',
      ));
    } catch (e) {
      emit(ApprovalListError('Failed to reject request: $e'));
    }
  }

  Future<ApprovalRequestEntity?> submitRequest({
    required String transactionType,
    required String recordId,
    String? recordReference,
    required String title,
    String? description,
    double? amount,
    String? requesterId,
    required String requesterName,
    String? requesterRole,
    String? showroomId,
    String? showroomName,
    String urgency = 'normal',
    Map<String, dynamic>? payload,
  }) async {
    try {
      final req = await _service.submitApprovalRequest(
        transactionType: transactionType,
        recordId: recordId,
        recordReference: recordReference,
        title: title,
        description: description,
        amount: amount,
        requesterId: requesterId,
        requesterName: requesterName,
        requesterRole: requesterRole,
        showroomId: showroomId,
        showroomName: showroomName,
        urgency: urgency,
        payload: payload,
      );
      await loadRequests(criteria: _currentCriteria);
      return req;
    } catch (e) {
      emit(ApprovalListError('Failed to submit approval request: $e'));
      return null;
    }
  }

  void clearSuccessMessage() {
    if (state is ApprovalListLoaded) {
      emit((state as ApprovalListLoaded).copyWith(clearSuccessMessage: true));
    }
  }
}
