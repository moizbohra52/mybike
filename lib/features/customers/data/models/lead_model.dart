import '../../domain/entities/lead_entity.dart';

/// Lead Data Model — Supabase JSON ↔ Entity mapper
class LeadModel {
  const LeadModel._();

  static LeadEntity fromJson(Map<String, dynamic> json) {
    return LeadEntity(
      id: json['id'] as String,
      showroomId: json['showroom_id'] as String,
      customerId: json['customer_id'] as String?,
      leadNumber: json['lead_number'] as String,
      prospectName: json['prospect_name'] as String?,
      prospectMobile: json['prospect_mobile'] as String?,
      prospectEmail: json['prospect_email'] as String?,
      source: json['source'] as String? ?? 'walk_in',
      status: json['status'] as String? ?? 'new',
      interestedModelId: json['interested_model_id'] as String?,
      interestedVariantId: json['interested_variant_id'] as String?,
      assignedTo: json['assigned_to'] as String?,
      priority: json['priority'] as String? ?? 'warm',
      expectedClosureDate: json['expected_closure_date'] != null
          ? DateTime.parse(json['expected_closure_date'] as String)
          : null,
      lastFollowUpAt: json['last_follow_up_at'] != null
          ? DateTime.parse(json['last_follow_up_at'] as String)
          : null,
      nextFollowUpAt: json['next_follow_up_at'] != null
          ? DateTime.parse(json['next_follow_up_at'] as String)
          : null,
      lostReason: json['lost_reason'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // Hydrated fields from joined queries
      customerName: json['customer_name'] as String?,
      assignedToName: json['assigned_to_name'] as String?,
      interestedModelName: json['interested_model_name'] as String?,
      interestedVariantName: json['interested_variant_name'] as String?,
    );
  }

  static Map<String, dynamic> toJson(LeadEntity entity) {
    return {
      'id': entity.id,
      'showroom_id': entity.showroomId,
      'customer_id': entity.customerId,
      'lead_number': entity.leadNumber,
      'prospect_name': entity.prospectName,
      'prospect_mobile': entity.prospectMobile,
      'prospect_email': entity.prospectEmail,
      'source': entity.source,
      'status': entity.status,
      'interested_model_id': entity.interestedModelId,
      'interested_variant_id': entity.interestedVariantId,
      'assigned_to': entity.assignedTo,
      'priority': entity.priority,
      'expected_closure_date': entity.expectedClosureDate?.toIso8601String().substring(0, 10),
      'last_follow_up_at': entity.lastFollowUpAt?.toIso8601String(),
      'next_follow_up_at': entity.nextFollowUpAt?.toIso8601String(),
      'lost_reason': entity.lostReason,
      'notes': entity.notes,
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> toInsertJson(LeadEntity entity) {
    final json = toJson(entity);
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    json.remove('customer_name');
    json.remove('assigned_to_name');
    json.remove('interested_model_name');
    json.remove('interested_variant_name');
    return json;
  }
}
