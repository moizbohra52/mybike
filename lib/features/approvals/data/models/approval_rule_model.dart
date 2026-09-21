import '../../domain/entities/approval_rule_entity.dart';

/// Data model for Approval Rules
class ApprovalRuleModel extends ApprovalRuleEntity {
  const ApprovalRuleModel({
    required super.id,
    required super.transactionType,
    required super.name,
    super.description,
    required super.thresholdAmount,
    required super.requiredRole,
    super.showroomId,
    super.isActive = true,
    super.autoApproveBelowThreshold = true,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ApprovalRuleModel.fromJson(Map<String, dynamic> json) {
    return ApprovalRuleModel(
      id: json['id'] as String,
      transactionType: (json['transaction_type'] as String?)?.toLowerCase() ?? 'other',
      name: json['name'] as String,
      description: json['description'] as String?,
      thresholdAmount: (json['threshold_amount'] as num?)?.toDouble() ?? 0.0,
      requiredRole: (json['required_role'] as String?)?.toLowerCase() ?? 'showroom_manager',
      showroomId: json['showroom_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      autoApproveBelowThreshold: json['auto_approve_below_threshold'] as bool? ?? true,
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
      'transaction_type': transactionType,
      'name': name,
      'description': description,
      'threshold_amount': thresholdAmount,
      'required_role': requiredRole,
      'showroom_id': showroomId,
      'is_active': isActive,
      'auto_approve_below_threshold': autoApproveBelowThreshold,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ApprovalRuleModel.fromEntity(ApprovalRuleEntity entity) {
    return ApprovalRuleModel(
      id: entity.id,
      transactionType: entity.transactionType,
      name: entity.name,
      description: entity.description,
      thresholdAmount: entity.thresholdAmount,
      requiredRole: entity.requiredRole,
      showroomId: entity.showroomId,
      isActive: entity.isActive,
      autoApproveBelowThreshold: entity.autoApproveBelowThreshold,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
