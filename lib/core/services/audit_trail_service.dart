import '../../features/audit/data/models/audit_log_model.dart';
import '../../features/audit/domain/entities/audit_filter_criteria.dart';
import '../../features/audit/domain/entities/audit_log_entity.dart';
import 'spreadsheet_export_builder.dart';

/// Central Dealership Audit Trail & Compliance Service
class AuditTrailService {
  static final AuditTrailService instance = AuditTrailService._internal();

  factory AuditTrailService() => instance;

  AuditTrailService._internal() {
    _initSeededAuditLogs();
  }

  final List<AuditLogEntity> _logs = [];

  // ─────────────────────────────────────────────────────────
  // Query & Retrieval
  // ─────────────────────────────────────────────────────────

  Future<List<AuditLogEntity>> fetchLogs(AuditFilterCriteria criteria) async {
    List<AuditLogEntity> results = List.from(_logs);

    // Showroom filter
    if (criteria.showroomId != null && criteria.showroomId!.isNotEmpty) {
      results = results.where((log) {
        return log.showroomId == null || log.showroomId == criteria.showroomId;
      }).toList();
    }

    // Module filter
    if (criteria.module != null && criteria.module != 'all') {
      results = results.where((log) {
        return log.module.toLowerCase() == criteria.module!.toLowerCase();
      }).toList();
    }

    // Action filter
    if (criteria.action != null && criteria.action != 'all') {
      results = results.where((log) {
        return log.action.toUpperCase() == criteria.action!.toUpperCase();
      }).toList();
    }

    // User filter
    if (criteria.userId != null && criteria.userId!.isNotEmpty) {
      results = results.where((log) => log.userId == criteria.userId).toList();
    }

    // Severity filter
    if (criteria.severity != null && criteria.severity != 'all') {
      results = results.where((log) {
        return log.severity.toLowerCase() == criteria.severity!.toLowerCase();
      }).toList();
    }

    // Date Range
    if (criteria.startDate != null) {
      results = results.where((log) => log.createdAt.isAfter(criteria.startDate!)).toList();
    }
    if (criteria.endDate != null) {
      results = results.where((log) => log.createdAt.isBefore(criteria.endDate!)).toList();
    }

    // Search Query (Search user, record title, action, module, or payload text)
    if (criteria.searchQuery != null && criteria.searchQuery!.trim().isNotEmpty) {
      final q = criteria.searchQuery!.trim().toLowerCase();
      results = results.where((log) {
        final matchesUser = (log.userName?.toLowerCase().contains(q) ?? false) ||
            (log.userEmail?.toLowerCase().contains(q) ?? false);
        final matchesRecord = (log.recordId.toLowerCase().contains(q)) ||
            (log.recordTitle?.toLowerCase().contains(q) ?? false);
        final matchesAction = log.action.toLowerCase().contains(q);
        final matchesModule = log.module.toLowerCase().contains(q);
        return matchesUser || matchesRecord || matchesAction || matchesModule;
      }).toList();
    }

    // Sort newest first
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  // ─────────────────────────────────────────────────────────
  // Recording / Ingestion
  // ─────────────────────────────────────────────────────────

  Future<AuditLogEntity> logEvent({
    String? userId,
    String? userName,
    String? userEmail,
    required String action,
    required String module,
    required String recordId,
    String? recordTitle,
    String? showroomId,
    String? showroomName,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
    String? ipAddress,
    String? userAgent,
    String severity = 'info',
    DateTime? timestamp,
  }) async {
    final newLog = AuditLogModel(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}_${_logs.length + 1}',
      userId: userId ?? 'usr-current',
      userName: userName ?? 'Store Administrator',
      userEmail: userEmail ?? 'admin@mybike.in',
      action: action.toUpperCase(),
      module: module.toLowerCase(),
      recordId: recordId,
      recordTitle: recordTitle,
      showroomId: showroomId,
      showroomName: showroomName,
      beforeData: beforeData,
      afterData: afterData,
      ipAddress: ipAddress ?? '192.168.1.100',
      userAgent: userAgent ?? 'MYBIKE ERP Desktop / Flutter Windows',
      severity: severity,
      createdAt: timestamp ?? DateTime.now(),
    );

    _logs.insert(0, newLog);
    return newLog;
  }

  // ─────────────────────────────────────────────────────────
  // Analytics & Metrics
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAuditMetrics({String? showroomId}) async {
    final scoped = showroomId == null
        ? _logs
        : _logs.where((l) => l.showroomId == null || l.showroomId == showroomId).toList();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final todayLogs = scoped.where((l) => l.createdAt.isAfter(todayStart)).length;
    final criticalLogs = scoped.where((l) => l.isCritical).length;

    final users = scoped.map((l) => l.userName ?? l.userEmail ?? 'System').toSet().length;

    final Map<String, int> moduleCounts = {};
    for (final log in scoped) {
      moduleCounts[log.module] = (moduleCounts[log.module] ?? 0) + 1;
    }

    return {
      'total': scoped.length,
      'today': todayLogs,
      'critical': criticalLogs,
      'uniqueUsers': users,
      'moduleCounts': moduleCounts,
    };
  }

  // ─────────────────────────────────────────────────────────
  // Export Engine Integration
  // ─────────────────────────────────────────────────────────

  Future<String> exportLogsCsv(AuditFilterCriteria criteria) async {
    final logs = await fetchLogs(criteria);
    final headers = [
      'Timestamp',
      'Action',
      'Module',
      'Record ID',
      'Record Title',
      'Operator',
      'Email',
      'Showroom',
      'Severity',
      'IP Address',
    ];

    final rows = logs.map((l) {
      return [
        '${l.formattedDate} ${l.formattedTime}',
        l.action,
        l.moduleLabel,
        l.recordId,
        l.recordTitle ?? '',
        l.userName ?? '',
        l.userEmail ?? '',
        l.showroomName ?? '',
        l.severity.toUpperCase(),
        l.ipAddress ?? '',
      ];
    }).toList();

    return SpreadsheetExportBuilder.buildCsv(headers: headers, rows: rows);
  }

  // ─────────────────────────────────────────────────────────
  // Seeded Historical Records
  // ─────────────────────────────────────────────────────────

  void _initSeededAuditLogs() {
    final now = DateTime.now();

    _logs.addAll([
      AuditLogModel(
        id: 'aud-001',
        userId: 'usr-admin-01',
        userName: 'Moiz Bohra',
        userEmail: 'moiz@mybike.in',
        action: 'CREATE',
        module: 'sales',
        recordId: 'INV-2026-00042',
        recordTitle: 'Tax Invoice: Speedster 250 (Customer: Rahul Sharma)',
        showroomId: 'sr-mumbai-01',
        showroomName: 'MYBIKE Mumbai Central',
        beforeData: null,
        afterData: {
          'invoice_number': 'INV-2026-00042',
          'customer_id': 'cust-01',
          'total_amount': 245000.00,
          'gst_amount': 53593.75,
          'status': 'issued',
        },
        severity: 'info',
        createdAt: now.subtract(const Duration(minutes: 25)),
      ),
      AuditLogModel(
        id: 'aud-002',
        userId: 'usr-cashier-02',
        userName: 'Sneha Patel',
        userEmail: 'sneha@mybike.in',
        action: 'CREATE',
        module: 'finance',
        recordId: 'RCP-2026-00088',
        recordTitle: 'Payment Receipt: Advance for BK-2026-0042',
        showroomId: 'sr-mumbai-01',
        showroomName: 'MYBIKE Mumbai Central',
        beforeData: null,
        afterData: {
          'receipt_number': 'RCP-2026-00088',
          'amount': 25000.00,
          'payment_mode': 'UPI',
          'transaction_ref': 'UPI/9988221199',
        },
        severity: 'info',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
      ),
      AuditLogModel(
        id: 'aud-003',
        userId: 'usr-compliance-03',
        userName: 'Compliance Lead',
        userEmail: 'audit@mybike.in',
        action: 'VERIFY',
        module: 'documents',
        recordId: 'doc-seed-01',
        recordTitle: 'Aadhaar Card (Rahul Sharma)',
        showroomId: 'sr-mumbai-01',
        showroomName: 'MYBIKE Mumbai Central',
        beforeData: {
          'verification_status': 'pending',
          'verified_by': null,
          'verified_at': null,
        },
        afterData: {
          'verification_status': 'verified',
          'verified_by': 'Compliance Lead',
          'verified_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
        },
        severity: 'info',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AuditLogModel(
        id: 'aud-004',
        userId: 'usr-compliance-03',
        userName: 'Compliance Lead',
        userEmail: 'audit@mybike.in',
        action: 'REJECT',
        module: 'documents',
        recordId: 'doc-seed-06',
        recordTitle: 'Driving License (Rahul Sharma)',
        showroomId: 'sr-mumbai-01',
        showroomName: 'MYBIKE Mumbai Central',
        beforeData: {
          'verification_status': 'pending',
          'rejection_reason': null,
        },
        afterData: {
          'verification_status': 'rejected',
          'rejection_reason': 'Photo is blurry and address is not clearly legible.',
        },
        severity: 'warning',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      AuditLogModel(
        id: 'aud-005',
        userId: 'usr-stock-04',
        userName: 'Vikram Singh',
        userEmail: 'vikram@mybike.in',
        action: 'UPDATE',
        module: 'inventory',
        recordId: 'MD2A12345E6789012',
        recordTitle: 'Vehicle Stock PDI Status Updated',
        showroomId: 'sr-mumbai-01',
        showroomName: 'MYBIKE Mumbai Central',
        beforeData: {
          'vin': 'MD2A12345E6789012',
          'pdi_status': 'pending',
          'bay_location': 'Yard Section B',
        },
        afterData: {
          'vin': 'MD2A12345E6789012',
          'pdi_status': 'passed',
          'bay_location': 'Showroom Floor Bay 1',
        },
        severity: 'info',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      AuditLogModel(
        id: 'aud-006',
        userId: 'usr-admin-01',
        userName: 'Moiz Bohra',
        userEmail: 'moiz@mybike.in',
        action: 'STATUS_CHANGE',
        module: 'sales',
        recordId: 'INV-2026-00041',
        recordTitle: 'Delivery Challan Issued (DC-2026-00019)',
        showroomId: 'sr-pune-02',
        showroomName: 'MYBIKE Pune Hub',
        beforeData: {
          'delivery_status': 'ready_for_handover',
          'gate_pass_id': null,
        },
        afterData: {
          'delivery_status': 'delivered',
          'gate_pass_id': 'GP-2026-00019',
          'odometer_reading': 4,
        },
        severity: 'info',
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      AuditLogModel(
        id: 'aud-007',
        userId: 'usr-accountant-05',
        userName: 'Rajesh Kumar',
        userEmail: 'rajesh@mybike.in',
        action: 'CREATE',
        module: 'accounting',
        recordId: 'JRN-2026-00104',
        recordTitle: 'Journal Entry: Daily Cash Reconciliation',
        showroomId: 'sr-mumbai-01',
        showroomName: 'MYBIKE Mumbai Central',
        beforeData: null,
        afterData: {
          'journal_number': 'JRN-2026-00104',
          'debit_total': 185000.00,
          'credit_total': 185000.00,
          'balanced': true,
        },
        severity: 'info',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AuditLogModel(
        id: 'aud-008',
        userId: 'usr-admin-01',
        userName: 'Moiz Bohra',
        userEmail: 'moiz@mybike.in',
        action: 'UPDATE',
        module: 'users',
        recordId: 'usr-cashier-02',
        recordTitle: 'Permission Escalation for Sneha Patel',
        showroomId: 'sr-mumbai-01',
        showroomName: 'MYBIKE Mumbai Central',
        beforeData: {
          'roles': ['cashier'],
          'can_approve_discounts': false,
        },
        afterData: {
          'roles': ['cashier', 'finance_executive'],
          'can_approve_discounts': true,
        },
        severity: 'critical',
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),
      AuditLogModel(
        id: 'aud-009',
        userId: 'usr-stock-04',
        userName: 'Vikram Singh',
        userEmail: 'vikram@mybike.in',
        action: 'DELETE',
        module: 'inventory',
        recordId: 'DMG-TAG-0012',
        recordTitle: 'Damaged Spares Scrap Tag Deleted',
        showroomId: 'sr-pune-02',
        showroomName: 'MYBIKE Pune Hub',
        beforeData: {
          'tag_id': 'DMG-TAG-0012',
          'item_code': 'SPR-OIL-FLT',
          'quantity': 2,
          'reason': 'Damaged during transit',
        },
        afterData: null,
        severity: 'warning',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      AuditLogModel(
        id: 'aud-010',
        userId: 'usr-admin-01',
        userName: 'Moiz Bohra',
        userEmail: 'moiz@mybike.in',
        action: 'LOGIN',
        module: 'auth',
        recordId: 'SES-992182',
        recordTitle: 'Superadmin Console Session Started',
        showroomId: null,
        showroomName: 'Headquarters',
        beforeData: null,
        afterData: {
          'client_platform': 'Windows Desktop',
          'auth_method': 'email_password_mfa',
        },
        severity: 'info',
        createdAt: now.subtract(const Duration(days: 2, hours: 2)),
      ),
    ]);
  }
}
