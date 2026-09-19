import 'package:equatable/equatable.dart';

/// Sales Lead Pipeline Domain Entity
///
/// Tracks the lifecycle of a potential customer inquiry in the Indian
/// two-wheeler dealership context: Walk-in → Contact → Interest → Test Ride → Negotiation → Booking → Conversion.
class LeadEntity extends Equatable {
  final String id;
  final String showroomId;
  final String? customerId; // null if prospect (not yet a customer)
  final String leadNumber; // e.g. "LEAD-IND-MAIN-0001"
  // Prospect Info (for leads without a customer record)
  final String? prospectName;
  final String? prospectMobile;
  final String? prospectEmail;
  final String source;
  final String status; // 'new', 'contacted', 'interested', etc.
  final String? interestedModelId;
  final String? interestedVariantId;
  final String? assignedTo; // Sales executive profile ID
  final String priority; // 'hot', 'warm', 'cold'
  final DateTime? expectedClosureDate;
  final DateTime? lastFollowUpAt;
  final DateTime? nextFollowUpAt;
  final String? lostReason;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ─── Hydrated Fields (populated by service/cubit) ───
  final String? customerName;
  final String? assignedToName;
  final String? interestedModelName;
  final String? interestedVariantName;

  const LeadEntity({
    required this.id,
    required this.showroomId,
    this.customerId,
    required this.leadNumber,
    this.prospectName,
    this.prospectMobile,
    this.prospectEmail,
    this.source = 'walk_in',
    this.status = 'new',
    this.interestedModelId,
    this.interestedVariantId,
    this.assignedTo,
    this.priority = 'warm',
    this.expectedClosureDate,
    this.lastFollowUpAt,
    this.nextFollowUpAt,
    this.lostReason,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    // Hydrated
    this.customerName,
    this.assignedToName,
    this.interestedModelName,
    this.interestedVariantName,
  });

  // ─── Computed Helpers ───

  /// Display name — use customer name if linked, otherwise prospect name
  String get displayName => customerName ?? prospectName ?? 'Unknown Prospect';

  /// Display mobile
  String get displayMobile => prospectMobile ?? '';

  bool get isHot => priority == 'hot';
  bool get isWarm => priority == 'warm';
  bool get isCold => priority == 'cold';

  bool get isNew => status == 'new';
  bool get isConverted => status == 'converted';
  bool get isLost => status == 'lost';
  bool get isActive => !isConverted && !isLost;

  /// Days since lead was created
  int get daysOpen => DateTime.now().difference(createdAt).inDays;

  /// Days until expected closure
  int? get daysToClose {
    if (expectedClosureDate == null) return null;
    return expectedClosureDate!.difference(DateTime.now()).inDays;
  }

  /// Whether follow-up is overdue
  bool get isFollowUpOverdue {
    if (nextFollowUpAt == null) return false;
    return DateTime.now().isAfter(nextFollowUpAt!);
  }

  /// Priority emoji
  String get priorityEmoji {
    switch (priority) {
      case 'hot':
        return '🔥';
      case 'warm':
        return '☀️';
      case 'cold':
        return '❄️';
      default:
        return '⚪';
    }
  }

  /// Priority label
  String get priorityLabel {
    switch (priority) {
      case 'hot':
        return 'Hot';
      case 'warm':
        return 'Warm';
      case 'cold':
        return 'Cold';
      default:
        return priority;
    }
  }

  /// Human-readable status label
  String get statusLabel {
    switch (status) {
      case 'new':
        return 'New';
      case 'contacted':
        return 'Contacted';
      case 'interested':
        return 'Interested';
      case 'test_ride_scheduled':
        return 'Test Ride Scheduled';
      case 'test_ride_done':
        return 'Test Ride Done';
      case 'negotiation':
        return 'Negotiation';
      case 'booking_initiated':
        return 'Booking Initiated';
      case 'converted':
        return 'Converted ✓';
      case 'lost':
        return 'Lost ✗';
      case 'follow_up':
        return 'Follow Up';
      default:
        return status;
    }
  }

  /// Source display label
  String get sourceLabel {
    switch (source) {
      case 'walk_in':
        return 'Walk-in';
      case 'phone_call':
        return 'Phone Call';
      case 'website':
        return 'Website';
      case 'social_media':
        return 'Social Media';
      case 'oem_referral':
        return 'OEM Referral';
      case 'exchange_inquiry':
        return 'Exchange';
      case 'corporate_tieup':
        return 'Corporate';
      case 'auto_expo':
        return 'Auto Expo';
      case 'existing_customer':
        return 'Existing';
      default:
        return source;
    }
  }

  LeadEntity copyWith({
    String? id,
    String? showroomId,
    String? customerId,
    String? leadNumber,
    String? prospectName,
    String? prospectMobile,
    String? prospectEmail,
    String? source,
    String? status,
    String? interestedModelId,
    String? interestedVariantId,
    String? assignedTo,
    String? priority,
    DateTime? expectedClosureDate,
    DateTime? lastFollowUpAt,
    DateTime? nextFollowUpAt,
    String? lostReason,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerName,
    String? assignedToName,
    String? interestedModelName,
    String? interestedVariantName,
  }) {
    return LeadEntity(
      id: id ?? this.id,
      showroomId: showroomId ?? this.showroomId,
      customerId: customerId ?? this.customerId,
      leadNumber: leadNumber ?? this.leadNumber,
      prospectName: prospectName ?? this.prospectName,
      prospectMobile: prospectMobile ?? this.prospectMobile,
      prospectEmail: prospectEmail ?? this.prospectEmail,
      source: source ?? this.source,
      status: status ?? this.status,
      interestedModelId: interestedModelId ?? this.interestedModelId,
      interestedVariantId: interestedVariantId ?? this.interestedVariantId,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
      expectedClosureDate: expectedClosureDate ?? this.expectedClosureDate,
      lastFollowUpAt: lastFollowUpAt ?? this.lastFollowUpAt,
      nextFollowUpAt: nextFollowUpAt ?? this.nextFollowUpAt,
      lostReason: lostReason ?? this.lostReason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName ?? this.customerName,
      assignedToName: assignedToName ?? this.assignedToName,
      interestedModelName: interestedModelName ?? this.interestedModelName,
      interestedVariantName: interestedVariantName ?? this.interestedVariantName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        showroomId,
        customerId,
        leadNumber,
        prospectName,
        prospectMobile,
        prospectEmail,
        source,
        status,
        interestedModelId,
        interestedVariantId,
        assignedTo,
        priority,
        expectedClosureDate,
        lastFollowUpAt,
        nextFollowUpAt,
        lostReason,
        notes,
        createdAt,
        updatedAt,
      ];
}
