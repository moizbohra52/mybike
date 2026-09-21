import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Approval Request Domain Entity
class ApprovalRequestEntity extends Equatable {
  final String id;
  final String? ruleId;
  final String transactionType; // 'expense', 'discount', 'purchase', 'payment', 'stock_adjustment', 'stock_transfer', 'other'
  final String recordId;
  final String? recordReference;
  final String title;
  final String? description;
  final double? amount;
  final String? requesterId;
  final String? requesterName;
  final String? requesterRole;
  final String? showroomId;
  final String? showroomName;
  final String status; // 'pending', 'approved', 'rejected', 'cancelled'
  final String urgency; // 'low', 'normal', 'high', 'critical'
  final String? approverId;
  final String? approverName;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? approvalNotes;
  final Map<String, dynamic>? payload;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApprovalRequestEntity({
    required this.id,
    this.ruleId,
    required this.transactionType,
    required this.recordId,
    this.recordReference,
    required this.title,
    this.description,
    this.amount,
    this.requesterId,
    this.requesterName,
    this.requesterRole,
    this.showroomId,
    this.showroomName,
    this.status = 'pending',
    this.urgency = 'normal',
    this.approverId,
    this.approverName,
    this.approvedAt,
    this.rejectionReason,
    this.approvalNotes,
    this.payload,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  bool get isCriticalUrgency => urgency.toLowerCase() == 'critical';
  bool get isHighUrgency => urgency.toLowerCase() == 'high';

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'cancelled':
        return Colors.grey;
      case 'pending':
      default:
        return AppColors.primaryYellowDark;
    }
  }

  Color get urgencyColor {
    switch (urgency.toLowerCase()) {
      case 'critical':
        return AppColors.error;
      case 'high':
        return Colors.orangeAccent;
      case 'normal':
        return const Color(0xFF3B82F6);
      case 'low':
      default:
        return Colors.blueGrey;
    }
  }

  Color get typeColor {
    switch (transactionType.toLowerCase()) {
      case 'expense':
        return const Color(0xFFE53935);
      case 'discount':
        return AppColors.primaryYellowDark;
      case 'purchase':
        return const Color(0xFF8B5CF6);
      case 'payment':
        return const Color(0xFF2563EB);
      case 'stock_adjustment':
        return const Color(0xFFD97706);
      case 'stock_transfer':
        return const Color(0xFF06B6D4);
      default:
        return AppColors.primaryYellowDark;
    }
  }

  IconData get typeIcon {
    switch (transactionType.toLowerCase()) {
      case 'expense':
        return Icons.payments_outlined;
      case 'discount':
        return Icons.loyalty_outlined;
      case 'purchase':
        return Icons.shopping_cart_outlined;
      case 'payment':
        return Icons.account_balance_wallet_outlined;
      case 'stock_adjustment':
        return Icons.tune_rounded;
      case 'stock_transfer':
        return Icons.local_shipping_outlined;
      default:
        return Icons.approval_rounded;
    }
  }

  String get typeLabel {
    switch (transactionType.toLowerCase()) {
      case 'expense':
        return 'Operating Expense';
      case 'discount':
        return 'Special Discount';
      case 'purchase':
        return 'OEM Purchase';
      case 'payment':
        return 'Supplier Payment';
      case 'stock_adjustment':
        return 'Stock Adjustment';
      case 'stock_transfer':
        return 'Branch Transfer';
      default:
        return transactionType.toUpperCase();
    }
  }

  String get formattedAmount {
    if (amount == null) return 'N/A';
    return '₹${amount!.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }

  String get relativeTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formattedDate;
  }

  ApprovalRequestEntity copyWith({
    String? id,
    String? ruleId,
    String? transactionType,
    String? recordId,
    String? recordReference,
    String? title,
    String? description,
    double? amount,
    String? requesterId,
    String? requesterName,
    String? requesterRole,
    String? showroomId,
    String? showroomName,
    String? status,
    String? urgency,
    String? approverId,
    String? approverName,
    DateTime? approvedAt,
    String? rejectionReason,
    String? approvalNotes,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApprovalRequestEntity(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      transactionType: transactionType ?? this.transactionType,
      recordId: recordId ?? this.recordId,
      recordReference: recordReference ?? this.recordReference,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterRole: requesterRole ?? this.requesterRole,
      showroomId: showroomId ?? this.showroomId,
      showroomName: showroomName ?? this.showroomName,
      status: status ?? this.status,
      urgency: urgency ?? this.urgency,
      approverId: approverId ?? this.approverId,
      approverName: approverName ?? this.approverName,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvalNotes: approvalNotes ?? this.approvalNotes,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ruleId,
        transactionType,
        recordId,
        recordReference,
        title,
        description,
        amount,
        requesterId,
        requesterName,
        requesterRole,
        showroomId,
        showroomName,
        status,
        urgency,
        approverId,
        approverName,
        approvedAt,
        rejectionReason,
        approvalNotes,
        payload,
        createdAt,
        updatedAt,
      ];
}
