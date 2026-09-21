import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Represents an individual field-level change between before and after snapshots.
class AuditFieldDiff extends Equatable {
  final String fieldName;
  final dynamic oldValue;
  final dynamic newValue;

  const AuditFieldDiff({
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
  });

  @override
  List<Object?> get props => [fieldName, oldValue, newValue];
}

/// Audit Log Domain Entity
class AuditLogEntity extends Equatable {
  final String id;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String action; // CREATE, UPDATE, DELETE, VERIFY, REJECT, LOGIN, EXPORT, STATUS_CHANGE
  final String module; // sales, inventory, finance, accounting, customers, documents, vehicles, showrooms, users, auth
  final String recordId;
  final String? recordTitle;
  final String? showroomId;
  final String? showroomName;
  final Map<String, dynamic>? beforeData;
  final Map<String, dynamic>? afterData;
  final String? ipAddress;
  final String? userAgent;
  final String severity; // info, warning, critical
  final DateTime createdAt;

  const AuditLogEntity({
    required this.id,
    this.userId,
    this.userName,
    this.userEmail,
    required this.action,
    required this.module,
    required this.recordId,
    this.recordTitle,
    this.showroomId,
    this.showroomName,
    this.beforeData,
    this.afterData,
    this.ipAddress,
    this.userAgent,
    this.severity = 'info',
    required this.createdAt,
  });

  bool get isCreate => action.toUpperCase() == 'CREATE';
  bool get isUpdate => action.toUpperCase() == 'UPDATE';
  bool get isDelete => action.toUpperCase() == 'DELETE';
  bool get isVerify => action.toUpperCase() == 'VERIFY';
  bool get isReject => action.toUpperCase() == 'REJECT';
  bool get isExport => action.toUpperCase() == 'EXPORT';
  bool get isLogin => action.toUpperCase() == 'LOGIN';
  bool get isStatusChange => action.toUpperCase() == 'STATUS_CHANGE';

  bool get isCritical => severity == 'critical';
  bool get isWarning => severity == 'warning';

  bool get hasDiff => beforeData != null || afterData != null;

  /// Computes granular field diffs between Before and After snapshots.
  List<AuditFieldDiff> computeDiff() {
    final diffs = <AuditFieldDiff>[];
    final before = beforeData ?? {};
    final after = afterData ?? {};

    final allKeys = {...before.keys, ...after.keys}.toList()..sort();

    for (final key in allKeys) {
      final oldVal = before[key];
      final newVal = after[key];

      if (oldVal != newVal) {
        diffs.add(AuditFieldDiff(
          fieldName: key,
          oldValue: oldVal,
          newValue: newVal,
        ));
      }
    }
    return diffs;
  }

  Color get actionColor {
    switch (action.toUpperCase()) {
      case 'CREATE':
        return AppColors.success;
      case 'UPDATE':
      case 'STATUS_CHANGE':
        return const Color(0xFF3B82F6);
      case 'DELETE':
      case 'REJECT':
        return AppColors.error;
      case 'VERIFY':
        return const Color(0xFF10B981);
      case 'EXPORT':
        return const Color(0xFF8B5CF6);
      case 'LOGIN':
        return AppColors.primaryYellowDark;
      default:
        return AppColors.primaryYellowDark;
    }
  }

  IconData get actionIcon {
    switch (action.toUpperCase()) {
      case 'CREATE':
        return Icons.add_circle_outline_rounded;
      case 'UPDATE':
        return Icons.edit_note_rounded;
      case 'DELETE':
        return Icons.delete_forever_rounded;
      case 'VERIFY':
        return Icons.verified_outlined;
      case 'REJECT':
        return Icons.cancel_outlined;
      case 'EXPORT':
        return Icons.file_download_outlined;
      case 'LOGIN':
        return Icons.login_rounded;
      case 'STATUS_CHANGE':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  String get moduleLabel {
    switch (module.toLowerCase()) {
      case 'sales':
        return 'Sales & Invoices';
      case 'inventory':
        return 'Inventory & Stock';
      case 'finance':
        return 'Finance & Vouchers';
      case 'accounting':
        return 'Accounts & Ledgers';
      case 'customers':
        return 'Customers & Bookings';
      case 'documents':
        return 'Document DMS';
      case 'vehicles':
        return 'Vehicle Master';
      case 'showrooms':
        return 'Showroom Branches';
      case 'users':
        return 'User & Roles';
      case 'auth':
        return 'Authentication';
      default:
        return module.toUpperCase();
    }
  }

  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }

  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final second = createdAt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String get relativeTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formattedDate;
  }

  AuditLogEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? action,
    String? module,
    String? recordId,
    String? recordTitle,
    String? showroomId,
    String? showroomName,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
    String? ipAddress,
    String? userAgent,
    String? severity,
    DateTime? createdAt,
  }) {
    return AuditLogEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      action: action ?? this.action,
      module: module ?? this.module,
      recordId: recordId ?? this.recordId,
      recordTitle: recordTitle ?? this.recordTitle,
      showroomId: showroomId ?? this.showroomId,
      showroomName: showroomName ?? this.showroomName,
      beforeData: beforeData ?? this.beforeData,
      afterData: afterData ?? this.afterData,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userEmail,
        action,
        module,
        recordId,
        recordTitle,
        showroomId,
        showroomName,
        beforeData,
        afterData,
        ipAddress,
        userAgent,
        severity,
        createdAt,
      ];
}
