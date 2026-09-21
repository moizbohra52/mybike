import '../../domain/entities/approval_request_entity.dart';

/// Data model for Approval Requests
class ApprovalRequestModel extends ApprovalRequestEntity {
  const ApprovalRequestModel({
    required super.id,
    super.ruleId,
    required super.transactionType,
    required super.recordId,
    super.recordReference,
    required super.title,
    super.description,
    super.amount,
    super.requesterId,
    super.requesterName,
    super.requesterRole,
    super.showroomId,
    super.showroomName,
    super.status = 'pending',
    super.urgency = 'normal',
    super.approverId,
    super.approverName,
    super.approvedAt,
    super.rejectionReason,
    super.approvalNotes,
    super.payload,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ApprovalRequestModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parseJsonField(dynamic field) {
      if (field == null) return null;
      if (field is Map<String, dynamic>) return field;
      if (field is Map) return Map<String, dynamic>.from(field);
      return null;
    }

    return ApprovalRequestModel(
      id: json['id'] as String,
      ruleId: json['rule_id'] as String?,
      transactionType: (json['transaction_type'] as String?)?.toLowerCase() ?? 'other',
      recordId: json['record_id']?.toString() ?? '',
      recordReference: json['record_reference'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      requesterId: json['requester_id'] as String?,
      requesterName: json['requester_name'] as String?,
      requesterRole: json['requester_role'] as String?,
      showroomId: json['showroom_id'] as String?,
      showroomName: json['showroom_name'] as String?,
      status: (json['status'] as String?)?.toLowerCase() ?? 'pending',
      urgency: (json['urgency'] as String?)?.toLowerCase() ?? 'normal',
      approverId: json['approver_id'] as String?,
      approverName: json['approver_name'] as String?,
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at'].toString()) : null,
      rejectionReason: json['rejection_reason'] as String?,
      approvalNotes: json['approval_notes'] as String?,
      payload: parseJsonField(json['payload']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rule_id': ruleId,
      'transaction_type': transactionType,
      'record_id': recordId,
      'record_reference': recordReference,
      'title': title,
      'description': description,
      'amount': amount,
      'requester_id': requesterId,
      'requester_name': requesterName,
      'requester_role': requesterRole,
      'showroom_id': showroomId,
      'showroom_name': showroomName,
      'status': status,
      'urgency': urgency,
      'approver_id': approverId,
      'approver_name': approverName,
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'approval_notes': approvalNotes,
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ApprovalRequestModel.fromEntity(ApprovalRequestEntity entity) {
    return ApprovalRequestModel(
      id: entity.id,
      ruleId: entity.ruleId,
      transactionType: entity.transactionType,
      recordId: entity.recordId,
      recordReference: entity.recordReference,
      title: entity.title,
      description: entity.description,
      amount: entity.amount,
      requesterId: entity.requesterId,
      requesterName: entity.requesterName,
      requesterRole: entity.requesterRole,
      showroomId: entity.showroomId,
      showroomName: entity.showroomName,
      status: entity.status,
      urgency: entity.urgency,
      approverId: entity.approverId,
      approverName: entity.approverName,
      approvedAt: entity.approvedAt,
      rejectionReason: entity.rejectionReason,
      approvalNotes: entity.approvalNotes,
      payload: entity.payload,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
