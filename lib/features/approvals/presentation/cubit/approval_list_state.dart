import 'package:equatable/equatable.dart';
import '../../domain/entities/approval_filter_criteria.dart';
import '../../domain/entities/approval_request_entity.dart';

abstract class ApprovalListState extends Equatable {
  const ApprovalListState();

  @override
  List<Object?> get props => [];
}

class ApprovalListInitial extends ApprovalListState {
  const ApprovalListInitial();
}

class ApprovalListLoading extends ApprovalListState {
  const ApprovalListLoading();
}

class ApprovalListLoaded extends ApprovalListState {
  final List<ApprovalRequestEntity> requests;
  final ApprovalFilterCriteria criteria;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final String? successMessage;

  const ApprovalListLoaded({
    required this.requests,
    required this.criteria,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    this.successMessage,
  });

  ApprovalListLoaded copyWith({
    List<ApprovalRequestEntity>? requests,
    ApprovalFilterCriteria? criteria,
    int? pendingCount,
    int? approvedCount,
    int? rejectedCount,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return ApprovalListLoaded(
      requests: requests ?? this.requests,
      criteria: criteria ?? this.criteria,
      pendingCount: pendingCount ?? this.pendingCount,
      approvedCount: approvedCount ?? this.approvedCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        requests,
        criteria,
        pendingCount,
        approvedCount,
        rejectedCount,
        successMessage,
      ];
}

class ApprovalListError extends ApprovalListState {
  final String message;

  const ApprovalListError(this.message);

  @override
  List<Object?> get props => [message];
}
