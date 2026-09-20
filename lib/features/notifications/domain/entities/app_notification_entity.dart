import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Notification Domain Entity for MYBIKE Dealership Network
class AppNotificationEntity extends Equatable {
  final String id;
  final String? showroomId;
  final String? userId;
  final String? targetRole;
  final String category; // 'inventory', 'sales', 'finance', 'booking', 'gst', 'system', 'transfer'
  final String priority; // 'low', 'normal', 'high', 'urgent'
  final String title;
  final String message;
  final String? actionRoute;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotificationEntity({
    required this.id,
    this.showroomId,
    this.userId,
    this.targetRole,
    required this.category,
    this.priority = 'normal',
    required this.title,
    required this.message,
    this.actionRoute,
    this.data = const {},
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  bool get isUrgent => priority == 'urgent';
  bool get isHighPriority => priority == 'high' || priority == 'urgent';

  String get priorityLabel {
    switch (priority) {
      case 'urgent':
        return 'URGENT';
      case 'high':
        return 'HIGH';
      case 'low':
        return 'LOW';
      case 'normal':
      default:
        return 'NORMAL';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 'urgent':
        return AppColors.error;
      case 'high':
        return Colors.orangeAccent;
      case 'low':
        return Colors.blueGrey;
      case 'normal':
      default:
        return AppColors.primaryYellowDark;
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'inventory':
        return 'Inventory & Stock';
      case 'sales':
        return 'Sales & Invoicing';
      case 'booking':
        return 'Customer Booking';
      case 'finance':
        return 'Finance & Accounts';
      case 'gst':
        return 'GST & Statutory';
      case 'transfer':
        return 'Stock Transfer';
      case 'system':
      default:
        return 'System Alert';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case 'inventory':
        return Icons.inventory_2_outlined;
      case 'sales':
        return Icons.receipt_long_outlined;
      case 'booking':
        return Icons.bookmark_border_rounded;
      case 'finance':
        return Icons.account_balance_wallet_outlined;
      case 'gst':
        return Icons.calculate_outlined;
      case 'transfer':
        return Icons.swap_horiz_rounded;
      case 'system':
      default:
        return Icons.notifications_active_outlined;
    }
  }

  String get relativeTime {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  AppNotificationEntity copyWith({
    String? id,
    String? showroomId,
    String? userId,
    String? targetRole,
    String? category,
    String? priority,
    String? title,
    String? message,
    String? actionRoute,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return AppNotificationEntity(
      id: id ?? this.id,
      showroomId: showroomId ?? this.showroomId,
      userId: userId ?? this.userId,
      targetRole: targetRole ?? this.targetRole,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      message: message ?? this.message,
      actionRoute: actionRoute ?? this.actionRoute,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        showroomId,
        userId,
        targetRole,
        category,
        priority,
        title,
        message,
        actionRoute,
        data,
        isRead,
        readAt,
        createdAt,
      ];
}
