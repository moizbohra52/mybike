import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/permission_service.dart';

class SecurityViolationException implements Exception {
  final String message;
  final String? code;
  
  SecurityViolationException(this.message, {this.code});
  
  @override
  String toString() => 'SecurityViolationException: $message ${code != null ? '($code)' : ''}';
}

class ShowroomIsolationGuard {
  static final ShowroomIsolationGuard _instance = ShowroomIsolationGuard._internal();
  static ShowroomIsolationGuard get instance => _instance;
  
  ShowroomIsolationGuard._internal();

  /// Asserts current user has explicit assignment to the target showroom 
  /// or is a super_admin. Throws [SecurityViolationException] on violation.
  Future<void> validateAccess(String showroomId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw SecurityViolationException('Unauthenticated user cannot access showroom data', code: 'UNAUTHENTICATED');
    }
    
    final isAuthorized = _checkAuthorization(showroomId);
    if (!isAuthorized) {
      throw SecurityViolationException('User lacks permission to access showroom data: $showroomId', code: 'UNAUTHORIZED_TENANT');
    }
  }

  /// Cross-checks active showroom context to eliminate cross-showroom data leakage.
  /// Throws [SecurityViolationException] if the requested targetShowroomId does not match
  /// the active isolated context (unless user is super_admin).
  Future<void> assertTenantIntegrity(String targetShowroomId, String activeShowroomId) async {
    if (targetShowroomId == activeShowroomId) return;
    
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw SecurityViolationException('Unauthenticated access attempt during tenant integrity check');
    }
    
    // Allow super admins to cross contexts
    if (PermissionService.instance.isSuperAdmin) return;
    
    throw SecurityViolationException(
      'Tenant integrity violation: Attempted to operate on showroom $targetShowroomId while active context is $activeShowroomId',
      code: 'TENANT_LEAKAGE_PREVENTED'
    );
  }

  /// Validates if the current user can authorize an inter-branch transfer 
  /// between source and destination showrooms.
  Future<bool> isCrossShowroomAuthorized(String sourceId, String destinationId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;
    
    if (PermissionService.instance.isSuperAdmin) return true;
    
    // User must have access to at least the source showroom
    final hasSourceAccess = _checkAuthorization(sourceId);
    if (!hasSourceAccess) return false;
    
    // And must have inventory transfer permissions
    final hasTransferPerm = PermissionService.instance.hasPermission('inventory', 'transfer');
    return hasTransferPerm;
  }
  
  bool _checkAuthorization(String showroomId) {
    return PermissionService.instance.currentProfile?.hasShowroomAccess(showroomId) ?? false;
  }
}
