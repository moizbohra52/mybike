import '../../domain/entities/audit_log_entity.dart';

/// Data Model for Audit Logs
class AuditLogModel extends AuditLogEntity {
  const AuditLogModel({
    required super.id,
    super.userId,
    super.userName,
    super.userEmail,
    required super.action,
    required super.module,
    required super.recordId,
    super.recordTitle,
    super.showroomId,
    super.showroomName,
    super.beforeData,
    super.afterData,
    super.ipAddress,
    super.userAgent,
    super.severity = 'info',
    required super.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parseJsonField(dynamic field) {
      if (field == null) return null;
      if (field is Map<String, dynamic>) return field;
      if (field is Map) return Map<String, dynamic>.from(field);
      return null;
    }

    return AuditLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      action: (json['action'] as String?)?.toUpperCase() ?? 'UPDATE',
      module: (json['module'] as String?) ?? (json['table_name'] as String?) ?? 'general',
      recordId: json['record_id']?.toString() ?? '',
      recordTitle: json['record_title'] as String?,
      showroomId: json['showroom_id'] as String?,
      showroomName: json['showroom_name'] as String?,
      beforeData: parseJsonField(json['old_data'] ?? json['before_data']),
      afterData: parseJsonField(json['new_data'] ?? json['after_data']),
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      severity: (json['severity'] as String?)?.toLowerCase() ?? 'info',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'action': action,
      'table_name': module,
      'module': module,
      'record_id': recordId,
      'record_title': recordTitle,
      'showroom_id': showroomId,
      'showroom_name': showroomName,
      'old_data': beforeData,
      'new_data': afterData,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'severity': severity,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AuditLogModel.fromEntity(AuditLogEntity entity) {
    return AuditLogModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      userEmail: entity.userEmail,
      action: entity.action,
      module: entity.module,
      recordId: entity.recordId,
      recordTitle: entity.recordTitle,
      showroomId: entity.showroomId,
      showroomName: entity.showroomName,
      beforeData: entity.beforeData,
      afterData: entity.afterData,
      ipAddress: entity.ipAddress,
      userAgent: entity.userAgent,
      severity: entity.severity,
      createdAt: entity.createdAt,
    );
  }
}
