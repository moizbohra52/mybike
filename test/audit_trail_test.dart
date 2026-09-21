import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/audit_trail_service.dart';
import 'package:mybike/features/audit/data/models/audit_log_model.dart';
import 'package:mybike/features/audit/domain/entities/audit_filter_criteria.dart';
import 'package:mybike/features/audit/domain/entities/audit_log_entity.dart';
import 'package:mybike/features/audit/presentation/cubit/audit_log_cubit.dart';
import 'package:mybike/features/audit/presentation/cubit/audit_log_state.dart';

void main() {
  group('Phase 20: Audit Logs & Compliance Engine Tests', () {
    late AuditTrailService service;

    setUp(() {
      service = AuditTrailService.instance;
    });

    // ─────────────────────────────────────────────────────────
    // 1. Entity & Model Tests
    // ─────────────────────────────────────────────────────────
    group('AuditLogEntity & Model', () {
      test('AuditLogModel correctly serializes and deserializes JSON', () {
        final now = DateTime.now();
        final model = AuditLogModel(
          id: 'test-aud-01',
          userId: 'usr-101',
          userName: 'Alice Smith',
          userEmail: 'alice@mybike.in',
          action: 'UPDATE',
          module: 'sales',
          recordId: 'INV-2026-00099',
          recordTitle: 'Tax Invoice #99',
          showroomId: 'sr-01',
          showroomName: 'Mumbai Central',
          beforeData: {'status': 'pending', 'discount': 0},
          afterData: {'status': 'approved', 'discount': 5000},
          severity: 'warning',
          createdAt: now,
        );

        final json = model.toJson();
        expect(json['id'], 'test-aud-01');
        expect(json['action'], 'UPDATE');
        expect(json['module'], 'sales');
        expect(json['severity'], 'warning');
        expect(json['old_data'], {'status': 'pending', 'discount': 0});
        expect(json['new_data'], {'status': 'approved', 'discount': 5000});

        final reconstructed = AuditLogModel.fromJson(json);
        expect(reconstructed.id, model.id);
        expect(reconstructed.userId, model.userId);
        expect(reconstructed.action, model.action);
        expect(reconstructed.beforeData?['discount'], 0);
        expect(reconstructed.afterData?['discount'], 5000);
      });

      test('computeDiff calculates before and after field differences accurately', () {
        final now = DateTime.now();
        final log = AuditLogEntity(
          id: 'test-aud-diff',
          action: 'UPDATE',
          module: 'inventory',
          recordId: 'VIN-999',
          beforeData: {
            'location': 'Warehouse A',
            'status': 'in_transit',
            'fuel_litres': 2,
          },
          afterData: {
            'location': 'Showroom Floor',
            'status': 'ready_for_sale',
            'fuel_litres': 2, // Unchanged
          },
          createdAt: now,
        );

        final diffs = log.computeDiff();
        expect(diffs.length, 2);

        final locationDiff = diffs.firstWhere((d) => d.fieldName == 'location');
        expect(locationDiff.oldValue, 'Warehouse A');
        expect(locationDiff.newValue, 'Showroom Floor');

        final statusDiff = diffs.firstWhere((d) => d.fieldName == 'status');
        expect(statusDiff.oldValue, 'in_transit');
        expect(statusDiff.newValue, 'ready_for_sale');
      });

      test('Entity helper getters work accurately', () {
        final now = DateTime.now();
        final log = AuditLogEntity(
          id: 'test-helpers',
          action: 'CREATE',
          module: 'sales',
          recordId: 'REC-1',
          severity: 'critical',
          createdAt: now,
        );

        expect(log.isCreate, isTrue);
        expect(log.isUpdate, isFalse);
        expect(log.isCritical, isTrue);
        expect(log.moduleLabel, 'Sales & Invoices');
        expect(log.formattedDate.isNotEmpty, isTrue);
        expect(log.formattedTime.isNotEmpty, isTrue);
        expect(log.relativeTime, 'Just now');
      });
    });

    // ─────────────────────────────────────────────────────────
    // 2. Filter Criteria Tests
    // ─────────────────────────────────────────────────────────
    group('AuditFilterCriteria', () {
      test('copyWith and clear flags behave properly', () {
        const criteria = AuditFilterCriteria(
          module: 'sales',
          action: 'UPDATE',
          severity: 'critical',
        );

        final updated = criteria.copyWith(
          clearModule: true,
          clearSeverity: true,
          action: 'DELETE',
        );

        expect(updated.module, 'all');
        expect(updated.severity, 'all');
        expect(updated.action, 'DELETE');
      });
    });

    // ─────────────────────────────────────────────────────────
    // 3. AuditTrailService Tests
    // ─────────────────────────────────────────────────────────
    group('AuditTrailService', () {
      test('Pre-seeded audit logs are present and span multiple modules', () async {
        final logs = await service.fetchLogs(const AuditFilterCriteria());
        expect(logs.isNotEmpty, isTrue);

        final modules = logs.map((l) => l.module).toSet();
        expect(modules.contains('sales'), isTrue);
        expect(modules.contains('finance'), isTrue);
        expect(modules.contains('inventory'), isTrue);
        expect(modules.contains('documents'), isTrue);
        expect(modules.contains('accounting'), isTrue);
      });

      test('Filters logs by module and action', () async {
        final salesLogs = await service.fetchLogs(
          const AuditFilterCriteria(module: 'sales'),
        );
        for (final log in salesLogs) {
          expect(log.module, 'sales');
        }

        final createLogs = await service.fetchLogs(
          const AuditFilterCriteria(action: 'CREATE'),
        );
        for (final log in createLogs) {
          expect(log.action, 'CREATE');
        }
      });

      test('Filters logs by search query', () async {
        final searchResults = await service.fetchLogs(
          const AuditFilterCriteria(searchQuery: 'moiz'),
        );
        expect(searchResults.isNotEmpty, isTrue);
        for (final log in searchResults) {
          final match = (log.userName?.toLowerCase().contains('moiz') ?? false) ||
              (log.userEmail?.toLowerCase().contains('moiz') ?? false);
          expect(match, isTrue);
        }
      });

      test('Records new audit event via logEvent and calculates metrics', () async {
        final logged = await service.logEvent(
          userId: 'usr-tester-99',
          userName: 'QA Automation',
          action: 'STATUS_CHANGE',
          module: 'customers',
          recordId: 'CUST-QA-99',
          recordTitle: 'Lead Converted to Booking',
          beforeData: {'stage': 'inquiry'},
          afterData: {'stage': 'booked'},
          severity: 'info',
        );

        expect(logged.action, 'STATUS_CHANGE');
        expect(logged.module, 'customers');
        expect(logged.recordId, 'CUST-QA-99');

        final metrics = await service.getAuditMetrics();
        expect(metrics['total'], greaterThan(0));
        expect(metrics['today'], greaterThan(0));
        expect(metrics['uniqueUsers'], greaterThan(0));
      });

      test('Exports audit logs as CSV formatted string', () async {
        final csv = await service.exportLogsCsv(const AuditFilterCriteria());
        expect(csv.isNotEmpty, isTrue);
        expect(csv.contains('Timestamp'), isTrue);
        expect(csv.contains('Action'), isTrue);
        expect(csv.contains('Module'), isTrue);
        expect(csv.contains('Record ID'), isTrue);
      });
    });

    // ─────────────────────────────────────────────────────────
    // 4. Cubit Tests
    // ─────────────────────────────────────────────────────────
    group('AuditLogCubit', () {
      test('Loads logs, updates filters, and records events', () async {
        final cubit = AuditLogCubit(service: service);
        expect(cubit.state, isA<AuditLogInitial>());

        await cubit.loadLogs();
        expect(cubit.state, isA<AuditLogLoaded>());

        final loaded = cubit.state as AuditLogLoaded;
        expect(loaded.logs.isNotEmpty, isTrue);
        expect(loaded.metrics['total'], greaterThan(0));

        // Update module filter
        await cubit.setModule('finance');
        final financeLoaded = cubit.state as AuditLogLoaded;
        for (final log in financeLoaded.logs) {
          expect(log.module, 'finance');
        }

        // Update action filter
        await cubit.setAction('CREATE');
        final actionLoaded = cubit.state as AuditLogLoaded;
        for (final log in actionLoaded.logs) {
          expect(log.action, 'CREATE');
        }

        // Search
        await cubit.setSearch('invoice');
        expect(cubit.state, isA<AuditLogLoaded>());

        // Log event via cubit
        await cubit.logEvent(
          action: 'EXPORT',
          module: 'reports',
          recordId: 'REP-GST-01',
          recordTitle: 'GSTR-1 Monthly Export',
        );

        expect(cubit.state, isA<AuditLogLoaded>());

        await cubit.close();
      });
    });
  });
}
