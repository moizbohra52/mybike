import '../../domain/entities/lead_activity_entity.dart';

/// Lead Activity Data Model — Supabase JSON ↔ Entity mapper
class LeadActivityModel {
  const LeadActivityModel._();

  static LeadActivityEntity fromJson(Map<String, dynamic> json) {
    return LeadActivityEntity(
      id: json['id'] as String,
      leadId: json['lead_id'] as String,
      activityType: json['activity_type'] as String,
      description: json['description'] as String,
      performedBy: json['performed_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      performedByName: json['performed_by_name'] as String?,
    );
  }

  static Map<String, dynamic> toJson(LeadActivityEntity entity) {
    return {
      'id': entity.id,
      'lead_id': entity.leadId,
      'activity_type': entity.activityType,
      'description': entity.description,
      'performed_by': entity.performedBy,
      'created_at': entity.createdAt.toIso8601String(),
    };
  }
}
