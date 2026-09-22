import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/accounting_management_service.dart';
import 'package:mybike/core/services/finance_management_service.dart';
import 'package:mybike/features/accounting/domain/entities/journal_entry_entity.dart';
import 'package:mybike/features/accounting/domain/entities/journal_line_entity.dart';
import 'package:mybike/features/finance/domain/entities/finance_voucher_entity.dart';

void main() {
  group('Phase 25 — Integration Test: Accounting & Financial Ledger Closing Workflows', () {
    late AccountingManagementService accountingService;
    late FinanceManagementService financeService;

    setUp(() {
      accountingService = AccountingManagementService.instance;
      financeService = FinanceManagementService.instance;
    });

    test('1. Double-Entry Imbalance Violation is strictly rejected', () async {
      final imbalancedEntry = JournalEntryEntity(
        id: '',
        showroomId: 'showroom-mumbai-main',
        entryNumber: 'JRN-TEST-IMBALANCED',
        entryDate: DateTime.now(),
        referenceType: 'manual',
        narration: 'Deliberately imbalanced entry testing validation guard',
        totalDebit: 100000.0,
        totalCredit: 80000.0,
        isBalanced: false,
        status: 'draft',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final lines = [
        JournalLineEntity(
          id: 'l1',
          journalEntryId: '',
          accountId: 'acc-1020',
          accountCode: '1020',
          accountName: 'HDFC Bank Current A/c',
          accountType: 'asset',
          debitAmount: 100000.0,
          creditAmount: 0.0,
          createdAt: DateTime.now(),
        ),
        JournalLineEntity(
          id: 'l2',
          journalEntryId: '',
          accountId: 'acc-4010',
          accountCode: '4010',
          accountName: 'Sales Revenue',
          accountType: 'revenue',
          debitAmount: 0.0,
          creditAmount: 80000.0, // Difference of ₹20,000!
          createdAt: DateTime.now(),
        ),
      ];

      expect(
        () async => await accountingService.createJournalEntry(imbalancedEntry, lines),
        throwsA(isA<Exception>()),
      );
    });

    test('2. Balanced Journal Entry Creation, Auto-Posting & Account Balance Propagation', () async {
      final accounts = await accountingService.fetchAccounts();
      final bankAccount = accounts.firstWhere((a) => a.accountCode == '1020');
      final revenueAccount = accounts.firstWhere((a) => a.accountCode == '4010');

      final initialBankBalance = bankAccount.currentBalance;
      final initialRevenueBalance = revenueAccount.currentBalance;

      final balancedEntry = JournalEntryEntity(
        id: '',
        showroomId: 'showroom-mumbai-main',
        entryNumber: 'JRN-TEST-BALANCED-01',
        entryDate: DateTime.now(),
        referenceType: 'manual',
        narration: 'Direct bank sale customer payment received',
        totalDebit: 150000.0,
        totalCredit: 150000.0,
        isBalanced: true,
        status: 'posted',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final lines = [
        JournalLineEntity(
          id: 'l1',
          journalEntryId: '',
          accountId: bankAccount.id,
          debitAmount: 150000.0,
          creditAmount: 0.0,
          createdAt: DateTime.now(),
        ),
        JournalLineEntity(
          id: 'l2',
          journalEntryId: '',
          accountId: revenueAccount.id,
          debitAmount: 0.0,
          creditAmount: 150000.0,
          createdAt: DateTime.now(),
        ),
      ];

      final created = await accountingService.createJournalEntry(balancedEntry, lines, autoPost: true);
      expect(created.id.isNotEmpty, isTrue);
      expect(created.status, equals('posted'));
      expect(created.totalDebit, equals(150000.0));
      expect(created.totalCredit, equals(150000.0));

      // Verify updated account balance in ledger
      final updatedBank = await accountingService.fetchAccountById(bankAccount.id);
      expect(updatedBank!.currentBalance, equals(initialBankBalance + 150000.0));

      final updatedRevenue = await accountingService.fetchAccountById(revenueAccount.id);
      expect(updatedRevenue!.currentBalance, equals(initialRevenueBalance + 150000.0));
    });

    test('3. Immutable Journal Entry Reversal preserves audit integrity', () async {
      final entries = await accountingService.fetchJournalEntries();
      final targetEntry = entries.firstWhere((e) => e.status == 'posted');

      final reversed = await accountingService.reverseJournalEntry(
        targetEntry.id,
        reason: 'Accounting rectification of duplicate voucher entry',
        reversedBy: 'Senior Auditor',
      );

      expect(reversed.id.isNotEmpty, isTrue);
      expect(reversed.referenceType, equals('reversal'));
      expect(reversed.referenceId, equals(targetEntry.entryNumber));
      expect(reversed.totalDebit, equals(targetEntry.totalCredit));
      expect(reversed.totalCredit, equals(targetEntry.totalDebit));
    });

    test('4. Trial Balance Double-Entry Equilibrium Verification', () async {
      final result = await accountingService.generateTrialBalance();
      expect(result['items'], isNotNull);

      final double totalDebits = result['totalDebit'] as double;
      final double totalCredits = result['totalCredit'] as double;
      final bool isBalanced = result['isBalanced'] as bool;

      expect(isBalanced, isTrue);
      final difference = (totalDebits - totalCredits).abs();
      expect(difference, lessThanOrEqualTo(1.0));
    });

    test('5. Finance Voucher Creation & Ledger Synchronization', () async {
      final newVoucher = FinanceVoucherEntity(
        id: 'vch-test-${DateTime.now().millisecondsSinceEpoch}',
        showroomId: 'showroom-mumbai-main',
        voucherNumber: 'RCT-FIN-2026-9001',
        voucherType: 'receipt',
        voucherDate: DateTime.now(),
        partyType: 'customer',
        partyId: 'cust-001',
        partyName: 'Rajesh Sharma',
        paymentMode: 'bank_transfer',
        sourceAccountId: 'acc-1020',
        destinationAccountId: 'acc-1030',
        amount: 85000.0,
        netAmount: 85000.0,
        referenceNumber: 'NEFT-HDFC-99112233',
        narration: 'Down payment for vehicle booking',
        status: 'posted',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdVoucher = await financeService.createVoucher(newVoucher);
      expect(createdVoucher.id.isNotEmpty, isTrue);
      expect(createdVoucher.status, equals('posted'));
      expect(createdVoucher.netAmount, equals(85000.0));
    });

    test('6. Party Outstanding & Aging Analysis Computation', () async {
      final receivables = await financeService.fetchCustomerReceivables();
      expect(receivables.isNotEmpty, isTrue);

      final payables = await financeService.fetchSupplierPayables();
      expect(payables.isNotEmpty, isTrue);

      final summary = await financeService.getOutstandingsSummary();
      expect(summary.containsKey('totalReceivable'), isTrue);
      expect(summary.containsKey('totalPayable'), isTrue);
    });
  });
}
