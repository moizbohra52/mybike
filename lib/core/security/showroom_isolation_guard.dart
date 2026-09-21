import 'package:flutter/foundation.dart';
import '../services/showroom_service.dart';
import '../services/permission_service.dart';

/// Thrown when a multi-tenant security boundary violation or unauthorized cross-showroom access is attempted.
class SecurityViolationException implements Exception {
  final String message;
  final String? operation;
  final String? attemptedShowroomId;
  final String? userId;

  const SecurityViolationException(
    this.message, {
    this.operation,
    this.attemptedShowroomId,
    this.userId,
  });

  @override
  String toString() =>
      'SecurityViolationException: $message (Operation: ${operation ?? "N/A"}, Showroom: ${attemptedShowroomId ?? "N/A"})';
}

/// Multi-tenant Showroom Data Isolation Guard.
///
/// Ensures database queries, storage uploads, and record mutations are strictly
/// bound to showrooms the authenticated user has explicit rights to access.
class ShowroomIsolationGuard {
  ShowroomIsolationGuard._();

  /// Asserts that the authenticated user has authorization to access [showroomId].
  ///
  /// Throws a [SecurityViolationException] if access is denied.
  static void validateAccess(String showroomId, {String? operation}) {
    final hasAccess = ShowroomService.instance.canAccess(showroomId) ||
        PermissionService.instance.isSuperAdmin;

    if (!hasAccess) {
      final msg = 'Access denied: User not assigned to showroom "$showroomId"';
      if (kDebugMode) {
        debugPrint('🚨 [SECURITY ALERT] $msg (Operation: $operation)');
      }
      throw SecurityViolationException(
        msg,
        operation: operation,
        attemptedShowroomId: showroomId,
        userId: PermissionService.instance.currentProfile?.id,
      );
    }
  }

  /// Asserts that an active showroom context matches the expected [targetShowroomId].
  ///
  /// Super admins are exempted from single-active showroom restrictions.
  static void assertCurrentTenant(String targetShowroomId, {String? operation}) {
    if (PermissionService.instance.isSuperAdmin) {
      return;
    }

    final active = ShowroomService.instance.activeShowroom?.id;
    if (active != null && active != targetShowroomId) {
      final msg =
          'Multi-tenant mismatch: Operation targeted showroom "$targetShowroomId", but active session is bound to "$active"';
      if (kDebugMode) {
        debugPrint('🚨 [SECURITY ALERT] $msg');
      }
      throw SecurityViolationException(
        msg,
        operation: operation,
        attemptedShowroomId: targetShowroomId,
        userId: PermissionService.instance.currentProfile?.id,
      );
    }
  }

  /// Validates whether a cross-showroom stock transfer is permitted.
  static bool isTransferPermitted(
    String sourceShowroomId,
    String destinationShowroomId,
  ) {
    if (PermissionService.instance.isSuperAdmin) {
      return true;
    }

    final canAccessSource = ShowroomService.instance.canAccess(sourceShowroomId);
    final hasTransferPermission =
        PermissionService.instance.hasPermission('inventory', 'transfer');

    return canAccessSource && hasTransferPermission;
  }

  /// Validates that a storage upload path is strictly quarantined within the showroom's folder.
  ///
  /// Storage paths MUST be structured as: `{showroomId}/{category}/{filename}`.
  static void validateStoragePath(String path, String expectedShowroomId) {
    final normalized = path.replaceAll('\\', '/').trim();
    final parts = normalized.split('/').where((p) => p.isNotEmpty).toList();

    if (parts.isEmpty || parts[0] != expectedShowroomId) {
      final msg =
          'Storage security breach: Attempted to upload file to path "$path" outside showroom quarantine "$expectedShowroomId"';
      if (kDebugMode) {
        debugPrint('🚨 [STORAGE SECURITY BREACH] $msg');
      }
      throw SecurityViolationException(
        msg,
        operation: 'storage_upload',
        attemptedShowroomId: expectedShowroomId,
      );
    }
  }
}
