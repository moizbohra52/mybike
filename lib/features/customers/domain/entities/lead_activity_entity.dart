import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Lead Activity (Interaction Log) Domain Entity
///
/// Represents a single interaction entry in a lead's timeline.
/// Tracks calls, WhatsApp messages, test rides, follow-ups, and notes.
class LeadActivityEntity extends Equatable {
  final String id;
  final String leadId;
  final String activityType; // 'call', 'whatsapp', 'email', 'sms', 'walk_in', 'test_ride', 'follow_up', 'negotiation', 'note'
  final String description;
  final String? performedBy;
  final DateTime createdAt;

  // ─── Hydrated Fields ───
  final String? performedByName;

  const LeadActivityEntity({
    required this.id,
    required this.leadId,
    required this.activityType,
    required this.description,
    this.performedBy,
    required this.createdAt,
    this.performedByName,
  });

  // ─── Computed Helpers ───

  /// Human-readable activity type label
  String get activityTypeLabel {
    switch (activityType) {
      case 'call':
        return 'Phone Call';
      case 'whatsapp':
        return 'WhatsApp';
      case 'email':
        return 'Email';
      case 'sms':
        return 'SMS';
      case 'walk_in':
        return 'Walk-in Visit';
      case 'test_ride':
        return 'Test Ride';
      case 'follow_up':
        return 'Follow Up';
      case 'negotiation':
        return 'Negotiation';
      case 'note':
        return 'Note';
      default:
        return activityType;
    }
  }

  /// Icon for activity type
  IconData get activityTypeIcon {
    switch (activityType) {
      case 'call':
        return Icons.phone_outlined;
      case 'whatsapp':
        return Icons.chat_outlined;
      case 'email':
        return Icons.email_outlined;
      case 'sms':
        return Icons.sms_outlined;
      case 'walk_in':
        return Icons.store_outlined;
      case 'test_ride':
        return Icons.two_wheeler_outlined;
      case 'follow_up':
        return Icons.schedule_outlined;
      case 'negotiation':
        return Icons.handshake_outlined;
      case 'note':
        return Icons.note_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  /// Time ago relative display
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  @override
  List<Object?> get props => [
        id,
        leadId,
        activityType,
        description,
        performedBy,
        createdAt,
      ];
}
