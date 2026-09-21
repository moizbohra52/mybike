import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/approval_workflow_service.dart';
import 'package:mybike/core/services/audit_trail_service.dart';
import 'package:mybike/core/services/notification_service.dart';
import 'package:mybike/features/approvals/domain/entities/approval_filter_criteria.dart';
import 'package:mybike/features/approvals/presentation/cubit/approval_list_cubit.dart';
import 'package:mybike/features/approvals/presentation/cubit/approval_list_state.dart';
import 'package:mybike/features/approvals/presentation/cubit/approval_rules_cubit.dart';
import 'package:mybike/features/approvals/presentation/cubit/approval_rules_state.dart';
import 'package:mybike/features/audit/domain/entities/audit_filter_criteria.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApprovalWorkflowService service;
  late AuditTrailService auditService;
  late NotificationService notificationService;

  setUp(() {
    service = ApprovalWorkflowService.instance;
    auditService = AuditTrailService.instance;
    notificationService = NotificationService.instance;
  });

  group('Phase 21: Approval Workflow Service - Policy Evaluation', () {
    test('loads pre-seeded rules covering automotive dealership workflows', () async {
      final rules = await service.getRules();
      expect(rules.length, greaterThanOrEqualTo(6));

      final types = rules.map((r) => r.transactionType).toSet();
      expect(types, contains('expense'));
      expect(types, contains('discount'));
      expect(types, contains('purchase'));
      expect(types, contains('payment'));
      expect(types, contains('stock_adjustment'));
      expect(types, contains('stock_transfer'));
    });

    test('checkApprovalRequired flags transactions exceeding threshold', () {
      // 1. Discount test: threshold is ₹5,000
      final smallDiscountRule = service.checkApprovalRequired(
        transactionType: 'discount',
        amount: 2500,
      );
      expect(smallDiscountRule, isNull);

      final largeDiscountRule = service.checkApprovalRequired(
        transactionType: 'discount',
        amount: 7500,
      );
      expect(largeDiscountRule, isNotNull);
      expect(largeDiscountRule!.transactionType, equals('discount'));

      // 2. Expense test: threshold is ₹10,000
      final smallExpense = service.checkApprovalRequired(
        transactionType: 'expense',
        amount: 4000,
      );
      expect(smallExpense, isNull);

      final largeExpense = service.checkApprovalRequired(
        transactionType: 'expense',
        amount: 25000,
      );
      expect(largeExpense, isNotNull);
      expect(largeExpense!.thresholdAmount, equals(10000.0));

      // 3. Stock Adjustment: threshold is 0 (all require manager sign-off)
      final stockAdjRule = service.checkApprovalRequired(
        transactionType: 'stock_adjustment',
        amount: 0,
      );
      expect(stockAdjRule, isNotNull);
      expect(stockAdjRule!.thresholdAmount, equals(0.0));
    });

    test('updateRule updates threshold amount and required role', () async {
      final rules = await service.getRules();
      final expenseRule = rules.firstWhere((r) => r.transactionType == 'expense');

      final updated = expenseRule.copyWith(
        thresholdAmount: 15000.0,
        requiredRole: 'Finance Director',
      );
      await service.updateRule(updated);

      final refreshedRules = await service.getRules();
      final refreshed = refreshedRules.firstWhere((r) => r.id == expenseRule.id);
      expect(refreshed.thresholdAmount, equals(15000.0));
      expect(refreshed.requiredRole, equals('Finance Director'));

      // Reset back for subsequent tests
      await service.updateRule(expenseRule);
    });
  });

  group('Phase 21: Request Submission, Audit Logs & Notifications Integration', () {
    test('submitApprovalRequest triggers audit trail and notification hooks', () async {
      final initialLogs = await auditService.fetchLogs(const AuditFilterCriteria());
      final initialNotifications = await notificationService.fetchNotifications();

      final req = await service.submitApprovalRequest(
        transactionType: 'expense',
        recordId: 'EXP-TEST-99',
        recordReference: 'VOUCH-TEST-99',
        title: 'New Service Equipment Acquisition',
        description: 'Purchase of diagnostic OBD scanner for workshop bay 3',
        amount: 48000.0,
        requesterName: 'Workshop Supervisor',
        requesterRole: 'Service Head',
        showroomId: 'sh-01',
        showroomName: 'Downtown Flagship',
        urgency: 'high',
        payload: {
          'vendor': 'Bosch Diagnostics',
          'item': 'OBD-II Pro Scanner',
          'cost': 48000.0,
        },
      );

      expect(req.id, isNotEmpty);
      expect(req.isPending, isTrue);
      expect(req.title, equals('New Service Equipment Acquisition'));
      expect(req.amount, equals(48000.0));

      // Verify Audit Trail (Phase 20 integration)
      final afterLogs = await auditService.fetchLogs(const AuditFilterCriteria());
      expect(afterLogs.length, greaterThan(initialLogs.length));
      final matchingLog = afterLogs.firstWhere((l) => l.recordId == 'EXP-TEST-99');
      expect(matchingLog.action, equals('CREATE'));
      expect(matchingLog.userName, equals('Workshop Supervisor'));

      // Verify Notification Dispatch (Phase 18 integration)
      final afterNotifications = await notificationService.fetchNotifications();
      expect(afterNotifications.length, greaterThan(initialNotifications.length));
      expect(
        afterNotifications.any((n) => n.title.contains('Approval Required: New Service Equipment Acquisition')),
        isTrue,
      );
    });

    test('approveRequest transitions state and records manager authorization audit', () async {
      // Create request to approve
      final req = await service.submitApprovalRequest(
        transactionType: 'discount',
        recordId: 'DISC-TEST-01',
        recordReference: 'INV-TEST-01',
        title: 'High Festival Discount Authorization',
        amount: 8000.0,
        requesterName: 'Sales Rep Alice',
        requesterRole: 'Sales Executive',
        urgency: 'high',
      );

      final approved = await service.approveRequest(
        req.id,
        approverName: 'General Manager Bob',
        notes: 'Approved as per Diwali promotional guidelines',
      );

      expect(approved.isApproved, isTrue);
      expect(approved.isPending, isFalse);
      expect(approved.approverName, equals('General Manager Bob'));
      expect(approved.approvalNotes, equals('Approved as per Diwali promotional guidelines'));
      expect(approved.approvedAt, isNotNull);

      // Verify Audit Trail logged VERIFY action
      final logs = await auditService.fetchLogs(const AuditFilterCriteria());
      final verifyLog = logs.firstWhere((l) => l.recordId == 'DISC-TEST-01' && l.action == 'VERIFY');
      expect(verifyLog.userName, equals('General Manager Bob'));
    });

    test('rejectRequest requires reason and records rejection audit event', () async {
      // Create request to reject
      final req = await service.submitApprovalRequest(
        transactionType: 'purchase',
        recordId: 'PURCH-TEST-01',
        recordReference: 'PO-TEST-01',
        title: 'Bulk Helmet Stock Purchase',
        amount: 60000.0,
        requesterName: 'Store In-charge Charlie',
        urgency: 'normal',
      );

      final rejected = await service.rejectRequest(
        req.id,
        rejectedBy: 'Finance Head David',
        reason: 'Monthly accessory procurement budget already exceeded',
      );

      expect(rejected.isRejected, isTrue);
      expect(rejected.isPending, isFalse);
      expect(rejected.approverName, equals('Finance Head David'));
      expect(rejected.rejectionReason, equals('Monthly accessory procurement budget already exceeded'));

      // Verify Audit Trail logged REJECT action
      final logs = await auditService.fetchLogs(const AuditFilterCriteria());
      final rejectLog = logs.firstWhere((l) => l.recordId == 'PURCH-TEST-01' && l.action == 'REJECT');
      expect(rejectLog.userName, equals('Finance Head David'));
    });
  });

  group('Phase 21: Query Filtering & Search Criteria', () {
    test('filters requests by transactionType, status, and urgency', () async {
      // Fetch only pending
      final pendingOnly = await service.fetchRequests(const ApprovalFilterCriteria(status: 'pending'));
      for (final r in pendingOnly) {
        expect(r.isPending, isTrue);
      }

      // Fetch only approved
      final approvedOnly = await service.fetchRequests(const ApprovalFilterCriteria(status: 'approved'));
      for (final r in approvedOnly) {
        expect(r.isApproved, isTrue);
      }

      // Fetch only discount
      final discounts = await service.fetchRequests(const ApprovalFilterCriteria(transactionType: 'discount'));
      for (final r in discounts) {
        expect(r.transactionType, equals('discount'));
      }

      // Search by text
      final searchResults = await service.fetchRequests(
        const ApprovalFilterCriteria(searchQuery: 'Festival Discount'),
      );
      expect(searchResults.isNotEmpty, isTrue);
    });
  });

  group('Phase 21: State Management Cubit Tests', () {
    test('ApprovalListCubit loads requests and computes KPI metrics', () async {
      final cubit = ApprovalListCubit(service: service);
      expect(cubit.state, isA<ApprovalListInitial>());

      await cubit.loadRequests();
      expect(cubit.state, isA<ApprovalListLoaded>());

      final state = cubit.state as ApprovalListLoaded;
      expect(state.requests, isNotEmpty);
      expect(state.pendingCount, greaterThanOrEqualTo(1));
      expect(state.approvedCount, greaterThanOrEqualTo(1));

      // Test filtering
      await cubit.setTransactionType('expense');
      final filteredState = cubit.state as ApprovalListLoaded;
      for (final r in filteredState.requests) {
        expect(r.transactionType, equals('expense'));
      }

      await cubit.close();
    });

    test('ApprovalRulesCubit loads rules and saves updates', () async {
      final rulesCubit = ApprovalRulesCubit(service: service);
      await rulesCubit.loadRules();

      expect(rulesCubit.state, isA<ApprovalRulesLoaded>());
      final state = rulesCubit.state as ApprovalRulesLoaded;
      expect(state.rules, isNotEmpty);

      final firstRule = state.rules.first;
      final updated = firstRule.copyWith(isActive: !firstRule.isActive);
      await rulesCubit.updateRule(updated);

      final updatedState = rulesCubit.state as ApprovalRulesLoaded;
      final matched = updatedState.rules.firstWhere((r) => r.id == firstRule.id);
      expect(matched.isActive, equals(!firstRule.isActive));
      expect(updatedState.successMessage, isNotNull);

      // Revert
      await rulesCubit.updateRule(firstRule);
      await rulesCubit.close();
    });
  });
}
