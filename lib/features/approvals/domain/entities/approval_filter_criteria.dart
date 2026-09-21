import 'package:equatable/equatable.dart';

/// Approval Filter Criteria Value Object
class ApprovalFilterCriteria extends Equatable {
  final String? showroomId;
  final String? transactionType; // 'all' or specific type
  final String? status; // 'all', 'pending', 'approved', 'rejected'
  final String? urgency; // 'all', 'low', 'normal', 'high', 'critical'
  final String? requesterId;
  final String? searchQuery;

  const ApprovalFilterCriteria({
    this.showroomId,
    this.transactionType = 'all',
    this.status = 'all',
    this.urgency = 'all',
    this.requesterId,
    this.searchQuery,
  });

  ApprovalFilterCriteria copyWith({
    String? showroomId,
    String? transactionType,
    String? status,
    String? urgency,
    String? requesterId,
    String? searchQuery,
    bool clearType = false,
    bool clearStatus = false,
    bool clearUrgency = false,
    bool clearSearch = false,
  }) {
    return ApprovalFilterCriteria(
      showroomId: showroomId ?? this.showroomId,
      transactionType: clearType ? 'all' : (transactionType ?? this.transactionType),
      status: clearStatus ? 'all' : (status ?? this.status),
      urgency: clearUrgency ? 'all' : (urgency ?? this.urgency),
      requesterId: requesterId ?? this.requesterId,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
    );
  }

  @override
  List<Object?> get props => [
        showroomId,
        transactionType,
        status,
        urgency,
        requesterId,
        searchQuery,
      ];
}
