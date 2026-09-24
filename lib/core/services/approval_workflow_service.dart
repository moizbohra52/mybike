import '../../features/approvals/data/models/approval_request_model.dart';
import '../../features/approvals/data/models/approval_rule_model.dart';
import '../../features/approvals/domain/entities/approval_filter_criteria.dart';
import '../../features/approvals/domain/entities/approval_request_entity.dart';
import '../../features/approvals/domain/entities/approval_rule_entity.dart';
import '../../features/notifications/domain/entities/app_notification_entity.dart';
import 'audit_trail_service.dart';
import 'notification_service.dart';
import 'supabase_service.dart';

/// Central Dealership Approval Workflow Service
class ApprovalWorkflowService {
  static final ApprovalWorkflowService instance = ApprovalWorkflowService._internal();

  factory ApprovalWorkflowService() => instance;

  ApprovalWorkflowService._internal() {
    _initSeededRules();
    _initSeededRequests();
  }

  final List<ApprovalRuleEntity> _rules = [];
  final List<ApprovalRequestEntity> _requests = [];

  // ─────────────────────────────────────────────────────────
  // Rules Management
  // ─────────────────────────────────────────────────────────

  Future<List<ApprovalRuleEntity>> getRules({String? showroomId}) async {
    await SupabaseService.devLatency();
    if (showroomId == null) return List.from(_rules);
    return _rules.where((r) => r.showroomId == null || r.showroomId == showroomId).toList();
  }

  Future<void> updateRule(ApprovalRuleEntity updatedRule) async {
    final index = _rules.indexWhere((r) => r.id == updatedRule.id);
    if (index != -1) {
      _rules[index] = updatedRule;
      // Log audit trail
      AuditTrailService.instance.logEvent(
        action: 'UPDATE',
        module: 'settings',
        recordId: updatedRule.id,
        recordTitle: 'Approval Policy Updated: ${updatedRule.name}',
        beforeData: {'threshold': _rules[index].thresholdAmount, 'role': _rules[index].requiredRole},
        afterData: {'threshold': updatedRule.thresholdAmount, 'role': updatedRule.requiredRole},
        severity: 'warning',
      );
    }
  }

  /// Checks if a proposed transaction requires manager sign-off based on configured policy thresholds
  ApprovalRuleEntity? checkApprovalRequired({
    required String transactionType,
    double? amount,
    String? showroomId,
  }) {
    final matchingRules = _rules.where((r) {
      final matchesType = r.transactionType.toLowerCase() == transactionType.toLowerCase();
      final matchesShowroom = r.showroomId == null || r.showroomId == showroomId;
      return matchesType && matchesShowroom && r.isActive;
    }).toList();

    if (matchingRules.isEmpty) return null;

    final rule = matchingRules.first;
    if (rule.thresholdAmount == 0) return rule; // 0 = all transactions require approval
    if (amount != null && amount > rule.thresholdAmount) return rule;

    return null;
  }

  // ─────────────────────────────────────────────────────────
  // Query & Fetch Requests
  // ─────────────────────────────────────────────────────────

  Future<List<ApprovalRequestEntity>> fetchRequests(ApprovalFilterCriteria criteria) async {
    await SupabaseService.devLatency();
    List<ApprovalRequestEntity> results = List.from(_requests);

    if (criteria.showroomId != null && criteria.showroomId!.isNotEmpty) {
      results = results.where((r) => r.showroomId == null || r.showroomId == criteria.showroomId).toList();
    }

    if (criteria.transactionType != null && criteria.transactionType != 'all') {
      results = results.where((r) => r.transactionType.toLowerCase() == criteria.transactionType!.toLowerCase()).toList();
    }

    if (criteria.status != null && criteria.status != 'all') {
      results = results.where((r) => r.status.toLowerCase() == criteria.status!.toLowerCase()).toList();
    }

    if (criteria.urgency != null && criteria.urgency != 'all') {
      results = results.where((r) => r.urgency.toLowerCase() == criteria.urgency!.toLowerCase()).toList();
    }

    if (criteria.requesterId != null && criteria.requesterId!.isNotEmpty) {
      results = results.where((r) => r.requesterId == criteria.requesterId).toList();
    }

    if (criteria.searchQuery != null && criteria.searchQuery!.trim().isNotEmpty) {
      final q = criteria.searchQuery!.trim().toLowerCase();
      results = results.where((r) {
        return r.title.toLowerCase().contains(q) ||
            r.recordId.toLowerCase().contains(q) ||
            (r.recordReference?.toLowerCase().contains(q) ?? false) ||
            (r.requesterName?.toLowerCase().contains(q) ?? false) ||
            (r.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Sort: pending first, then newest
    results.sort((a, b) {
      if (a.isPending && !b.isPending) return -1;
      if (!a.isPending && b.isPending) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return results;
  }

  Future<ApprovalRequestEntity?> getRequestById(String id) async {
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Ingestion & Submission
  // ─────────────────────────────────────────────────────────

  Future<ApprovalRequestEntity> submitApprovalRequest({
    required String transactionType,
    required String recordId,
    String? recordReference,
    required String title,
    String? description,
    double? amount,
    String? requesterId,
    required String requesterName,
    String? requesterRole,
    String? showroomId,
    String? showroomName,
    String urgency = 'normal',
    Map<String, dynamic>? payload,
  }) async {
    final rule = checkApprovalRequired(
      transactionType: transactionType,
      amount: amount,
      showroomId: showroomId,
    );

    final newRequest = ApprovalRequestModel(
      id: 'appr_${DateTime.now().millisecondsSinceEpoch}',
      ruleId: rule?.id,
      transactionType: transactionType.toLowerCase(),
      recordId: recordId,
      recordReference: recordReference,
      title: title,
      description: description,
      amount: amount,
      requesterId: requesterId ?? 'usr-current',
      requesterName: requesterName,
      requesterRole: requesterRole ?? 'Sales Executive',
      showroomId: showroomId,
      showroomName: showroomName,
      status: 'pending',
      urgency: urgency,
      payload: payload,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _requests.insert(0, newRequest);

    // 1. Log to Audit Trail (Phase 20)
    AuditTrailService.instance.logEvent(
      action: 'CREATE',
      module: transactionType,
      recordId: recordId,
      recordTitle: 'Approval Requested: $title',
      userName: requesterName,
      showroomId: showroomId,
      showroomName: showroomName,
      afterData: {
        'request_id': newRequest.id,
        'amount': amount,
        'urgency': urgency,
        'transaction_type': transactionType,
      },
      severity: urgency == 'critical' ? 'critical' : (urgency == 'high' ? 'warning' : 'info'),
    );

    // 2. Dispatch Notification (Phase 18)
    NotificationService.instance.sendNotification(
      AppNotificationEntity(
        id: 'notif_appr_${DateTime.now().millisecondsSinceEpoch}',
        category: 'booking',
        priority: urgency == 'critical' ? 'urgent' : (urgency == 'high' ? 'high' : 'normal'),
        title: 'Approval Required: $title',
        message: '$requesterName has requested authorization for $transactionType ($recordReference).',
        actionRoute: '/approvals',
        showroomId: showroomId,
        createdAt: DateTime.now(),
      ),
    );

    return newRequest;
  }

  // ─────────────────────────────────────────────────────────
  // Decision Workflow
  // ─────────────────────────────────────────────────────────

  Future<ApprovalRequestEntity> approveRequest(
    String requestId, {
    required String approverName,
    String? approverId,
    String? notes,
  }) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      throw Exception('Approval request not found: $requestId');
    }

    final req = _requests[index];
    final updated = req.copyWith(
      status: 'approved',
      approverId: approverId ?? 'usr-approver',
      approverName: approverName,
      approvedAt: DateTime.now(),
      approvalNotes: notes,
      updatedAt: DateTime.now(),
    );

    _requests[index] = updated;

    // Log to Audit Trail (Phase 20)
    AuditTrailService.instance.logEvent(
      action: 'VERIFY',
      module: req.transactionType,
      recordId: req.recordId,
      recordTitle: 'Approved: ${req.title}',
      userName: approverName,
      showroomId: req.showroomId,
      showroomName: req.showroomName,
      beforeData: {'status': 'pending'},
      afterData: {
        'status': 'approved',
        'approver': approverName,
        'notes': notes,
      },
      severity: 'info',
    );

    // Dispatch Notification (Phase 18)
    NotificationService.instance.sendNotification(
      AppNotificationEntity(
        id: 'notif_appr_ok_${DateTime.now().millisecondsSinceEpoch}',
        category: 'booking',
        priority: 'normal',
        title: 'Request Approved: ${req.recordReference ?? req.recordId}',
        message: 'Your ${req.transactionType} request has been approved by $approverName.',
        actionRoute: '/approvals',
        showroomId: req.showroomId,
        createdAt: DateTime.now(),
      ),
    );

    return updated;
  }

  Future<ApprovalRequestEntity> rejectRequest(
    String requestId, {
    required String rejectedBy,
    String? rejectorId,
    required String reason,
  }) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      throw Exception('Approval request not found: $requestId');
    }

    final req = _requests[index];
    final updated = req.copyWith(
      status: 'rejected',
      approverId: rejectorId ?? 'usr-approver',
      approverName: rejectedBy,
      approvedAt: DateTime.now(),
      rejectionReason: reason,
      updatedAt: DateTime.now(),
    );

    _requests[index] = updated;

    // Log to Audit Trail (Phase 20)
    AuditTrailService.instance.logEvent(
      action: 'REJECT',
      module: req.transactionType,
      recordId: req.recordId,
      recordTitle: 'Rejected: ${req.title}',
      userName: rejectedBy,
      showroomId: req.showroomId,
      showroomName: req.showroomName,
      beforeData: {'status': 'pending'},
      afterData: {
        'status': 'rejected',
        'rejected_by': rejectedBy,
        'reason': reason,
      },
      severity: 'warning',
    );

    // Dispatch Notification (Phase 18)
    NotificationService.instance.sendNotification(
      AppNotificationEntity(
        id: 'notif_appr_rej_${DateTime.now().millisecondsSinceEpoch}',
        category: 'booking',
        priority: 'high',
        title: 'Request Rejected: ${req.recordReference ?? req.recordId}',
        message: 'Your ${req.transactionType} was declined by $rejectedBy. Reason: $reason',
        actionRoute: '/approvals',
        showroomId: req.showroomId,
        createdAt: DateTime.now(),
      ),
    );

    return updated;
  }

  // ─────────────────────────────────────────────────────────
  // Analytics & Metrics
  // ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getApprovalMetrics({String? showroomId}) async {
    final scoped = showroomId == null
        ? _requests
        : _requests.where((r) => r.showroomId == null || r.showroomId == showroomId).toList();

    final pending = scoped.where((r) => r.isPending).length;
    final approved = scoped.where((r) => r.isApproved).length;
    final rejected = scoped.where((r) => r.isRejected).length;

    final typeDistribution = <String, int>{};
    for (final r in scoped) {
      typeDistribution[r.transactionType] = (typeDistribution[r.transactionType] ?? 0) + 1;
    }

    return {
      'total': scoped.length,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'rulesCount': _rules.length,
      'distribution': typeDistribution,
    };
  }

  // ─────────────────────────────────────────────────────────
  // Pre-Seeded Default Rules & Sample Requests
  // ─────────────────────────────────────────────────────────

  void _initSeededRules() {
    final now = DateTime.now();
    _rules.addAll([
      ApprovalRuleModel(
        id: 'rule-01',
        transactionType: 'expense',
        name: 'Operating Expenses Sign-off',
        description: 'Showroom operational expense vouchers exceeding ₹10,000 require manager approval.',
        thresholdAmount: 10000.00,
        requiredRole: 'showroom_manager',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      ApprovalRuleModel(
        id: 'rule-02',
        transactionType: 'discount',
        name: 'Retail Special Discount Limit',
        description: 'Sales discounts exceeding standard showroom limit of ₹5,000 require Sales Manager sign-off.',
        thresholdAmount: 5000.00,
        requiredRole: 'sales_manager',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      ApprovalRuleModel(
        id: 'rule-03',
        transactionType: 'purchase',
        name: 'OEM Factory Purchase Order',
        description: 'Direct vehicle procurement orders exceeding ₹1,00,000 require executive CFO authorization.',
        thresholdAmount: 100000.00,
        requiredRole: 'cfo',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      ApprovalRuleModel(
        id: 'rule-04',
        transactionType: 'payment',
        name: 'Supplier Outgoing Remittance',
        description: 'Bank disbursements and vendor payments exceeding ₹50,000 require senior accountant review.',
        thresholdAmount: 50000.00,
        requiredRole: 'accountant',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      ApprovalRuleModel(
        id: 'rule-05',
        transactionType: 'stock_adjustment',
        name: 'Damaged & Transit Scrap Authorization',
        description: 'All inventory write-offs, scrap tagging, and physical count discrepancies require branch sign-off.',
        thresholdAmount: 0.00,
        requiredRole: 'showroom_manager',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      ApprovalRuleModel(
        id: 'rule-06',
        transactionType: 'stock_transfer',
        name: 'Inter-Showroom Vehicle Transfer',
        description: 'Transfer of showroom vehicles between branches requires dispatching branch manager authorization.',
        thresholdAmount: 0.00,
        requiredRole: 'showroom_manager',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
    ]);
  }

  void _initSeededRequests() {
    final now = DateTime.now();

    _requests.addAll([
      ApprovalRequestModel(
        id: 'req-001',
        ruleId: 'rule-02',
        transactionType: 'discount',
        recordId: 'BK-2026-0042',
        recordReference: 'BK-2026-0042',
        title: 'Special Festival Discount: Speedster 250',
        description: 'Customer requested ₹7,500 festive discount on Speedster 250 against competitor quote.',
        amount: 7500.00,
        requesterId: 'usr-sales-01',
        requesterName: 'Aditya Mehta',
        requesterRole: 'Sales Executive',
        showroomId: 'sr-mumbai-01',
        showroomName: 'MYBIKE Mumbai Central',
        status: 'pending',
        urgency: 'high',
        payload: {
          'booking_ref': 'BK-2026-0042',
          'model': 'Speedster 250',
          'ex_showroom': 185000.00,
          'requested_discount': 7500.00,
          'margin_retained': '11.8%',
        },
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      ApprovalRequestModel(
        id: 'req-002',
        ruleId: 'rule-06',
        transactionType: 'stock_transfer',
        recordId: 'TRF-2026-0015',
        recordReference: 'TRF-2026-0015',
        title: 'Vehicle Transfer: Mumbai Central → Pune Hub',
        description: 'Transfer 1x Cruiser 350 (Matte Black) to fulfill urgent customer booking in Pune.',
        amount: null,
        requesterId: 'usr-stock-02',
        requesterName: 'Vikram Singh',
        requesterRole: 'Inventory Executive',
        showroomId: 'sr-mumbai-01',
        showroomName: 'MYBIKE Mumbai Central',
        status: 'pending',
        urgency: 'normal',
        payload: {
          'vin': 'MD2A12345E6789012',
          'origin': 'MYBIKE Mumbai Central',
          'destination': 'MYBIKE Pune Hub',
          'vehicle': 'Cruiser 350 Matte Black',
        },
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      ApprovalRequestModel(
        id: 'req-003',
        ruleId: 'rule-01',
        transactionType: 'expense',
        recordId: 'VCH-EXP-0082',
        recordReference: 'VCH-EXP-0082',
        title: 'Service Bay Hydraulic Lift Maintenance',
        description: 'Scheduled preventive maintenance and seal replacement for workshop bike lifts 1 & 2.',
        amount: 14200.00,
        requesterId: 'usr-service-03',
        requesterName: 'Ramesh Sawant',
        requesterRole: 'Workshop Manager',
        showroomId: 'sr-mumbai-01',
        showroomName: 'MYBIKE Mumbai Central',
        status: 'pending',
        urgency: 'normal',
        payload: {
          'vendor': 'HydroTech Hydraulic Services',
          'invoice_no': 'HT/2026/089',
          'cost_head': 'Workshop Equipment Repairs',
        },
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      ApprovalRequestModel(
        id: 'req-004',
        ruleId: 'rule-03',
        transactionType: 'purchase',
        recordId: 'PO-2026-0028',
        recordReference: 'PO-2026-0028',
        title: 'OEM Bulk Riding Gear & Helmets Batch',
        description: 'Procurement of 50x ISI Certified Full-Face Helmets and 25x Riding Gloves from Vega.',
        amount: 125000.00,
        requesterId: 'usr-stock-02',
        requesterName: 'Vikram Singh',
        requesterRole: 'Inventory Manager',
        showroomId: 'sr-mumbai-01',
        showroomName: 'MYBIKE Mumbai Central',
        status: 'approved',
        urgency: 'normal',
        approverId: 'usr-cfo-01',
        approverName: 'Moiz Bohra (Admin)',
        approvedAt: now.subtract(const Duration(days: 1)),
        approvalNotes: 'Approved as per seasonal accessory inventory plan.',
        payload: {
          'supplier': 'Vega Auto Accessories Ltd',
          'items_count': 75,
          'gstin': '27AABCV1234F1Z9',
        },
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ApprovalRequestModel(
        id: 'req-005',
        ruleId: 'rule-04',
        transactionType: 'payment',
        recordId: 'PMT-2026-0034',
        recordReference: 'PMT-2026-0034',
        title: 'Unscheduled Cash Payout Claim',
        description: 'Customer exchange vehicle advance adjustment without original RTO NOC document.',
        amount: 18500.00,
        requesterId: 'usr-sales-01',
        requesterName: 'Aditya Mehta',
        requesterRole: 'Sales Executive',
        showroomId: 'sr-pune-02',
        showroomName: 'MYBIKE Pune Hub',
        status: 'rejected',
        urgency: 'critical',
        approverId: 'usr-cfo-01',
        approverName: 'Senior Accountant',
        approvedAt: now.subtract(const Duration(days: 1)),
        rejectionReason: 'Exchange payout cannot be sanctioned without Form 35 Bank Hypothecation NOC clearance.',
        payload: {
          'customer_id': 'cust-02',
          'vehicle_model': 'Used Pulsar 150',
          'missing_docs': ['Form 35 NOC'],
        },
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }
}
