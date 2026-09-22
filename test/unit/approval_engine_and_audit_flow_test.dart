import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/approval_workflow_service.dart';
import 'package:mybike/core/services/audit_trail_service.dart';
import 'package:mybike/features/approvals/domain/entities/approval_filter_criteria.dart';
import 'package:mybike/features/audit/domain/entities/audit_filter_criteria.dart';

void main() {
  group('Phase 25 — Unit Tests: Dealership Approval Engine & Audit Flows', () {
    late ApprovalWorkflowService approvalService;
    late AuditTrailService auditService;

    setUp(() {
      approvalService = ApprovalWorkflowService.instance;
      auditService = AuditTrailService.instance;
    });

    test('1. Policy threshold evaluation for discount, PO, and credit transactions', () async {
      // Test rule check for high-value sales discount
      final discountRule = approvalService.checkApprovalRequired(
        transactionType: 'discount',
        amount: 15000.0,
        showroomId: 'ind-central-01',
      );
      // Discount > 10,000 requires manager sign-off
      expect(discountRule, isNotNull);

      // Low discount <= threshold does not trigger approval
      final lowDiscountRule = approvalService.checkApprovalRequired(
        transactionType: 'discount',
        amount: 2000.0,
        showroomId: 'ind-central-01',
      );
      expect(lowDiscountRule, isNull);

      // High purchase order (> 100,000)
      final poRule = approvalService.checkApprovalRequired(
        transactionType: 'purchase',
        amount: 500000.0,
      );
      expect(poRule, isNotNull);
    });

    test('2. Submit approval request with automated audit trail and notification hooks', () async {
      final initialLogs = await auditService.fetchLogs(const AuditFilterCriteria());
      final initialAuditCount = initialLogs.length;

      final request = await approvalService.submitApprovalRequest(
        transactionType: 'discount',
        recordId: 'inv-test-999',
        recordReference: 'INV-2026-999',
        title: 'Special Festival Discount ₹15,000 on EV Pro',
        description: 'Customer requested festive price match',
        amount: 15000.0,
        requesterName: 'Aarav Sharma',
        requesterRole: 'Sales Executive',
        showroomId: 'ind-central-01',
        showroomName: 'MYBIKE Central',
        urgency: 'high',
      );

      expect(request.id.isNotEmpty, isTrue);
      expect(request.status, equals('pending'));
      expect(request.amount, equals(15000.0));
      expect(request.urgency, equals('high'));

      // Check audit trail was automatically created
      final latestLogs = await auditService.fetchLogs(const AuditFilterCriteria());
      expect(latestLogs.length, greaterThan(initialAuditCount));
      final matchingLog = latestLogs.firstWhere((l) => l.recordId == 'inv-test-999');
      expect(matchingLog.action, equals('CREATE'));
      expect(matchingLog.userName, equals('Aarav Sharma'));
    });

    test('3. Approve workflow transition updates status and records audit verification', () async {
      // Submit a fresh request
      final request = await approvalService.submitApprovalRequest(
        transactionType: 'credit_sale',
        recordId: 'cred-test-101',
        recordReference: 'SO-2026-101',
        title: 'Extended Credit Period 45 Days',
        description: 'Corporate client institutional order',
        amount: 750000.0,
        requesterName: 'Rohan Gupta',
        showroomId: 'ind-west-02',
        showroomName: 'MYBIKE West',
      );

      final approved = await approvalService.approveRequest(
        request.id,
        approverName: 'Vikram Mehta (General Manager)',
        notes: 'Approved based on verified credit limit and past payment track record.',
      );

      expect(approved.status, equals('approved'));
      expect(approved.approverName, equals('Vikram Mehta (General Manager)'));
      expect(approved.approvalNotes, contains('verified credit limit'));
      expect(approved.approvedAt, isNotNull);

      // Verify audit trail logged the approval
      final allLogs = await auditService.fetchLogs(const AuditFilterCriteria());
      final latestAudit = allLogs.firstWhere((l) => l.recordId == 'cred-test-101' && l.action == 'VERIFY');
      expect(latestAudit.userName, equals('Vikram Mehta (General Manager)'));
    });

    test('4. Reject workflow transition records rejection reason and audit event', () async {
      final request = await approvalService.submitApprovalRequest(
        transactionType: 'stock_adjustment',
        recordId: 'adj-test-555',
        recordReference: 'ADJ-2026-555',
        title: 'Vehicle Damage Write-off',
        description: 'Transit minor scratch write-off request',
        amount: 25000.0,
        requesterName: 'Pooja Verma',
        showroomId: 'ind-south-03',
        showroomName: 'MYBIKE South',
      );

      final rejected = await approvalService.rejectRequest(
        request.id,
        rejectedBy: 'Priya Patel (Auditor)',
        reason: 'Damages are covered under transit insurance. Claim insurance instead of write-off.',
      );

      expect(rejected.status, equals('rejected'));
      expect(rejected.approverName, equals('Priya Patel (Auditor)'));
      expect(rejected.rejectionReason, contains('transit insurance'));

      // Verify audit trail logged rejection
      final allLogs = await auditService.fetchLogs(const AuditFilterCriteria());
      final latestAudit = allLogs.firstWhere((l) => l.recordId == 'adj-test-555' && l.action == 'REJECT');
      expect(latestAudit.userName, equals('Priya Patel (Auditor)'));
    });

    test('5. Multi-criteria filtering of approval requests', () async {
      final pendingOnly = await approvalService.fetchRequests(
        const ApprovalFilterCriteria(status: 'pending'),
      );
      expect(pendingOnly.every((r) => r.status == 'pending'), isTrue);

      final approvedOnly = await approvalService.fetchRequests(
        const ApprovalFilterCriteria(status: 'approved'),
      );
      expect(approvedOnly.every((r) => r.status == 'approved'), isTrue);

      final searchFilter = await approvalService.fetchRequests(
        const ApprovalFilterCriteria(searchQuery: 'Special Festival Discount'),
      );
      expect(searchFilter.isNotEmpty, isTrue);
    });

    test('6. Dynamic Approval Rules configuration and threshold update', () async {
      final rules = await approvalService.getRules();
      expect(rules.isNotEmpty, isTrue);

      final firstRule = rules.first;
      final updated = firstRule.copyWith(
        thresholdAmount: 25000.0,
      );

      await approvalService.updateRule(updated);

      final reloadedRules = await approvalService.getRules();
      final target = reloadedRules.firstWhere((r) => r.id == firstRule.id);
      expect(target.thresholdAmount, equals(25000.0));
    });
  });
}
