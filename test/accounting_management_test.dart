import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/accounting_management_service.dart';
import 'package:mybike/features/accounting/data/models/account_model.dart';
import 'package:mybike/features/accounting/data/models/journal_entry_model.dart';
import 'package:mybike/features/accounting/domain/entities/account_entity.dart';
import 'package:mybike/features/accounting/domain/entities/journal_entry_entity.dart';
import 'package:mybike/features/accounting/domain/entities/journal_line_entity.dart';
import 'package:mybike/features/accounting/domain/entities/trial_balance_item_entity.dart';
import 'package:mybike/features/accounting/presentation/cubit/chart_of_accounts_cubit.dart';
import 'package:mybike/features/accounting/presentation/cubit/journal_entry_form_cubit.dart';
import 'package:mybike/features/accounting/presentation/cubit/journal_entry_list_cubit.dart';
import 'package:mybike/features/accounting/presentation/cubit/trial_balance_cubit.dart';

void main() {
  setUp(() {
    AccountingManagementService.instance.resetDevData();
  });

  group('Accounting Foundation — Domain Entities & Models', () {
    test('AccountEntity and AccountModel JSON serialization and properties', () {
      final now = DateTime(2026, 2, 1);
      final account = AccountEntity(
        id: 'acc-test-1',
        showroomId: 'showroom-mumbai-main',
        accountCode: '1010',
        accountName: 'Cash on Hand - Cashier Drawer',
        accountType: 'asset',
        subType: 'cash',
        currentBalance: 25000.0,
        isSystemAccount: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(account.isAsset, isTrue);
      expect(account.isLiability, isFalse);
      expect(account.isEquity, isFalse);
      expect(account.typeDisplayLabel, equals('Asset'));
      expect(account.formattedCodeAndName, equals('1010 - Cash on Hand - Cashier Drawer'));

      final json = AccountModel.toJson(account);
      final fromJson = AccountModel.fromJson(json);

      expect(fromJson.id, equals('acc-test-1'));
      expect(fromJson.accountCode, equals('1010'));
      expect(fromJson.accountName, equals('Cash on Hand - Cashier Drawer'));
      expect(fromJson.accountType, equals('asset'));
      expect(fromJson.subType, equals('cash'));
      expect(fromJson.currentBalance, equals(25000.0));
      expect(fromJson.isSystemAccount, isTrue);
    });

    test('JournalLineEntity and JournalEntryEntity validation and serialization', () {
      final now = DateTime(2026, 2, 1);
      final lines = [
        JournalLineEntity(
          id: 'line-1',
          journalEntryId: 'entry-1',
          accountId: 'acc-1010',
          accountCode: '1010',
          accountName: 'Cash on Hand',
          accountType: 'asset',
          debitAmount: 50000.0,
          creditAmount: 0.0,
          description: 'Booking advance cash receipt',
          createdAt: now,
        ),
        JournalLineEntity(
          id: 'line-2',
          journalEntryId: 'entry-1',
          accountId: 'acc-2010',
          accountCode: '2010',
          accountName: 'Customer Advances',
          accountType: 'liability',
          debitAmount: 0.0,
          creditAmount: 50000.0,
          description: 'Advance for Apache RTR 160 4V',
          createdAt: now,
        ),
      ];

      final entry = JournalEntryEntity(
        id: 'entry-1',
        showroomId: 'showroom-mumbai-main',
        entryNumber: 'JRN-MUM-2026-00001',
        entryDate: now,
        referenceType: 'payment_receipt',
        status: 'posted',
        narration: 'Customer booking advance receipt',
        totalDebit: 50000.0,
        totalCredit: 50000.0,
        lines: lines,
        createdAt: now,
        updatedAt: now,
      );

      expect(entry.checkBalance, isTrue);
      expect(entry.totalDebit, equals(50000.0));
      expect(entry.totalCredit, equals(50000.0));
      expect(entry.isPosted, isTrue);
      expect(entry.isReversed, isFalse);
      expect(entry.isDraft, isFalse);
      expect(entry.referenceTypeLabel, equals('Payment Receipt'));

      final json = JournalEntryModel.toJson(entry);
      final fromJson = JournalEntryModel.fromJson(json, lines: entry.lines);

      expect(fromJson.id, equals('entry-1'));
      expect(fromJson.entryNumber, equals('JRN-MUM-2026-00001'));
      expect(fromJson.lines.length, equals(2));
      expect(fromJson.totalDebit, equals(50000.0));
      expect(fromJson.totalCredit, equals(50000.0));
      expect(fromJson.status, equals('posted'));
    });

    test('TrialBalanceItemEntity calculations for debit and credit balances', () {
      const debitItem = TrialBalanceItemEntity(
        accountId: 'acc-1010',
        accountCode: '1010',
        accountName: 'Cash on Hand',
        accountType: 'asset',
        debitBalance: 75000.0,
        creditBalance: 0.0,
      );

      expect(debitItem.debitBalance, equals(75000.0));
      expect(debitItem.creditBalance, equals(0.0));
      expect(debitItem.isDebit, isTrue);
      expect(debitItem.isCredit, isFalse);

      const creditItem = TrialBalanceItemEntity(
        accountId: 'acc-4010',
        accountCode: '4010',
        accountName: 'Two-Wheeler Sales Revenue',
        accountType: 'revenue',
        debitBalance: 0.0,
        creditBalance: 1200000.0,
      );

      expect(creditItem.creditBalance, equals(1200000.0));
      expect(creditItem.isCredit, isTrue);
      expect(creditItem.isDebit, isFalse);
    });
  });

  group('AccountingManagementService — Core General Ledger & Double Entry', () {
    test('Service initializes with standard Indian dealership Chart of Accounts', () async {
      final service = AccountingManagementService.instance;
      final accounts = await service.fetchAccounts();

      expect(accounts, isNotEmpty);
      expect(accounts.any((a) => a.accountType == 'asset'), isTrue);
      expect(accounts.any((a) => a.accountType == 'liability'), isTrue);
      expect(accounts.any((a) => a.accountType == 'equity'), isTrue);
      expect(accounts.any((a) => a.accountType == 'revenue'), isTrue);
      expect(accounts.any((a) => a.accountType == 'expense'), isTrue);

      // Verify specific dealership accounts
      expect(accounts.any((a) => a.accountCode == '1010'), isTrue); // Cash
      expect(accounts.any((a) => a.accountCode == '1020'), isTrue); // Bank Current A/c
      expect(accounts.any((a) => a.accountCode == '1040'), isTrue); // Vehicle Inventory
      expect(accounts.any((a) => a.accountCode == '2020'), isTrue); // GST Output Liability
      expect(accounts.any((a) => a.accountCode == '4010'), isTrue); // Vehicle Sales
    });

    test('Creating a custom account persists in the Chart of Accounts', () async {
      final service = AccountingManagementService.instance;
      final newAccount = await service.createAccount(
        AccountEntity(
          id: '',
          accountCode: '1099',
          accountName: 'HDFC Bank - Point of Sale Terminal',
          accountType: 'asset',
          subType: 'bank',
          openingBalance: 15000.0,
          currentBalance: 15000.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      expect(newAccount.accountCode, equals('1099'));
      expect(newAccount.accountName, equals('HDFC Bank - Point of Sale Terminal'));
      expect(newAccount.currentBalance, equals(15000.0));

      final retrieved = await service.fetchAccountById(newAccount.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.accountCode, equals('1099'));
    });

    test('Unbalanced journal entry throws Exception on creation', () async {
      final service = AccountingManagementService.instance;

      expect(
        () => service.createJournalEntry(
          JournalEntryEntity(
            id: '',
            showroomId: 'showroom-mumbai-main',
            entryNumber: '',
            entryDate: DateTime.now(),
            narration: 'Unbalanced entry test',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          [
            JournalLineEntity(
              id: 'l1',
              journalEntryId: '',
              accountId: 'acc-1010',
              debitAmount: 10000.0,
              creditAmount: 0.0,
              createdAt: DateTime.now(),
            ),
            JournalLineEntity(
              id: 'l2',
              journalEntryId: '',
              accountId: 'acc-4010',
              debitAmount: 0.0,
              creditAmount: 8000.0, // Mismatch of 2000!
              createdAt: DateTime.now(),
            ),
          ],
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Posting a balanced journal entry updates account balances accurately', () async {
      final service = AccountingManagementService.instance;

      final cashBefore = (await service.fetchAccountById('acc-1010'))!.currentBalance;
      final revenueBefore = (await service.fetchAccountById('acc-4010'))!.currentBalance;

      final entry = await service.createJournalEntry(
        JournalEntryEntity(
          id: '',
          showroomId: 'showroom-mumbai-main',
          entryNumber: '',
          entryDate: DateTime.now(),
          referenceType: 'payment_receipt',
          narration: 'Cash sale of vehicle accessory',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        [
          JournalLineEntity(
            id: 'l1',
            journalEntryId: '',
            accountId: 'acc-1010',
            debitAmount: 5000.0,
            creditAmount: 0.0,
            createdAt: DateTime.now(),
          ),
          JournalLineEntity(
            id: 'l2',
            journalEntryId: '',
            accountId: 'acc-4010',
            debitAmount: 0.0,
            creditAmount: 5000.0,
            createdAt: DateTime.now(),
          ),
        ],
        autoPost: true,
      );

      expect(entry.status, equals('posted'));

      final cashAfter = (await service.fetchAccountById('acc-1010'))!.currentBalance;
      final revenueAfter = (await service.fetchAccountById('acc-4010'))!.currentBalance;

      // Cash is an Asset (debit increases balance)
      expect(cashAfter, equals(cashBefore + 5000.0));
      // Vehicle Sales is Revenue (credit increases balance)
      expect(revenueAfter, equals(revenueBefore + 5000.0));
    });

    test('Anti-Tamper Reversal creates offsetting voucher and restores account balances', () async {
      final service = AccountingManagementService.instance;

      final initialCash = (await service.fetchAccountById('acc-1010'))!.currentBalance;
      final initialRevenue = (await service.fetchAccountById('acc-4010'))!.currentBalance;

      // 1. Post original voucher
      final original = await service.createJournalEntry(
        JournalEntryEntity(
          id: '',
          showroomId: 'showroom-mumbai-main',
          entryNumber: 'JRN-TEST-ORIG-001',
          entryDate: DateTime.now(),
          referenceType: 'payment_receipt',
          narration: 'Accidental duplicate cash receipt',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        [
          JournalLineEntity(
            id: 'l1',
            journalEntryId: '',
            accountId: 'acc-1010',
            debitAmount: 12000.0,
            creditAmount: 0.0,
            createdAt: DateTime.now(),
          ),
          JournalLineEntity(
            id: 'l2',
            journalEntryId: '',
            accountId: 'acc-4010',
            debitAmount: 0.0,
            creditAmount: 12000.0,
            createdAt: DateTime.now(),
          ),
        ],
        autoPost: true,
      );

      expect((await service.fetchAccountById('acc-1010'))!.currentBalance, equals(initialCash + 12000.0));

      // 2. Perform anti-tamper reversal
      final reversal = await service.reverseJournalEntry(
        original.id,
        reason: 'Duplicate entry correction as per audit note #42',
        reversedBy: 'Chief Auditor',
      );

      expect(reversal.entryNumber.startsWith('REV-'), isTrue);
      expect(reversal.status, equals('posted'));
      expect(reversal.narration, contains('Reversal of'));

      // Check original voucher marked as reversed
      final originalUpdated = await service.fetchJournalEntryById(original.id);
      expect(originalUpdated!.status, equals('reversed'));
      expect(originalUpdated.reversedEntryId, equals(reversal.id));

      // 3. Verify balances are completely restored to pre-transaction levels
      final restoredCash = (await service.fetchAccountById('acc-1010'))!.currentBalance;
      final restoredRevenue = (await service.fetchAccountById('acc-4010'))!.currentBalance;

      expect(restoredCash, equals(initialCash));
      expect(restoredRevenue, equals(initialRevenue));
    });

    test('Real-time Trial Balance satisfies fundamental accounting equation (Sum Debit == Sum Credit)', () async {
      final service = AccountingManagementService.instance;

      // Seed another transaction to ensure varied balances
      await service.createJournalEntry(
        JournalEntryEntity(
          id: '',
          showroomId: 'showroom-mumbai-main',
          entryNumber: '',
          entryDate: DateTime.now(),
          referenceType: 'expense',
          narration: 'Showroom Rent Payment',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        [
          JournalLineEntity(
            id: 'l1',
            journalEntryId: '',
            accountId: 'acc-6010', // Showroom Facility Rent & Lease
            debitAmount: 35000.0,
            creditAmount: 0.0,
            createdAt: DateTime.now(),
          ),
          JournalLineEntity(
            id: 'l2',
            journalEntryId: '',
            accountId: 'acc-1020', // HDFC Bank Current A/c
            debitAmount: 0.0,
            creditAmount: 35000.0,
            createdAt: DateTime.now(),
          ),
        ],
        autoPost: true,
      );

      final trialBalance = await service.generateTrialBalance();

      final items = trialBalance['items'] as List<TrialBalanceItemEntity>;
      final isBalanced = trialBalance['isBalanced'] as bool;
      final totalDebit = trialBalance['totalDebit'] as double;
      final totalCredit = trialBalance['totalCredit'] as double;
      final difference = trialBalance['difference'] as double;

      expect(items, isNotEmpty);
      expect(isBalanced, isTrue);
      expect(difference, lessThan(0.01));
      expect(totalDebit, equals(totalCredit));
    });
  });

  group('Accounting Foundation — Presentation Cubits', () {
    test('ChartOfAccountsCubit loads accounts and filters by category and query', () async {
      final cubit = ChartOfAccountsCubit(service: AccountingManagementService.instance);

      await cubit.loadAccounts();
      expect(cubit.state.accounts, isNotEmpty);
      expect(cubit.state.isLoading, isFalse);

      // Filter by category Asset
      cubit.filterByType('asset');
      expect(cubit.state.filteredAccounts.every((a) => a.accountType == 'asset'), isTrue);

      // Search by query
      cubit.searchAccounts('HDFC');
      expect(cubit.state.filteredAccounts.any((a) => a.accountName.contains('HDFC')), isTrue);

      cubit.clearFilters();
      expect(cubit.state.filteredAccounts.length, equals(cubit.state.accounts.length));

      cubit.close();
    });

    test('JournalEntryListCubit loads entries and manages post and reversal actions', () async {
      final service = AccountingManagementService.instance;
      final cubit = JournalEntryListCubit(service: service);

      await cubit.loadJournals();
      expect(cubit.state.journals, isNotEmpty);
      expect(cubit.state.isLoading, isFalse);

      // Find first posted entry to test reversal
      final posted = cubit.state.journals.firstWhere((e) => e.status == 'posted');
      final success = await cubit.reverseEntry(posted.id, reason: 'Test audit reversal');
      expect(success, isTrue);

      // Entries should be reloaded and state should reflect change
      final reversedEntry = cubit.state.journals.firstWhere((e) => e.id == posted.id);
      expect(reversedEntry.status, equals('reversed'));

      cubit.close();
    });

    test('JournalEntryFormCubit validates unbalanced lines and submits balanced vouchers', () async {
      final service = AccountingManagementService.instance;
      final cubit = JournalEntryFormCubit(service: service);

      await cubit.init();

      expect(cubit.state.lines.length, equals(2));
      expect(cubit.state.isBalanced, isFalse);

      // Set header
      cubit.updateHeader(narration: 'Two-Wheeler Booking Advance Cash');

      // Set line 1
      cubit.updateLine(
        0,
        accountId: 'acc-1010',
        debit: 20000.0,
        credit: 0.0,
      );

      // Line 2
      cubit.updateLine(
        1,
        accountId: 'acc-4010',
        debit: 0.0,
        credit: 20000.0,
      );

      expect(cubit.state.isBalanced, isTrue);
      expect(cubit.state.totalDebit, equals(20000.0));
      expect(cubit.state.totalCredit, equals(20000.0));
      expect(cubit.state.isValid, isTrue);

      final success = await cubit.submitJournal(autoPost: true);
      expect(success, isTrue);
      expect(cubit.state.savedEntry, isNotNull);
      expect(cubit.state.savedEntry!.status, equals('posted'));

      cubit.close();
    });

    test('TrialBalanceCubit loads real-time statement with balanced columns', () async {
      final service = AccountingManagementService.instance;
      final cubit = TrialBalanceCubit(service: service);

      await cubit.loadTrialBalance();
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.items, isNotEmpty);
      expect(cubit.state.isBalanced, isTrue);
      expect(cubit.state.totalDebit, greaterThan(0));
      expect(cubit.state.totalDebit, equals(cubit.state.totalCredit));

      cubit.close();
    });
  });
}
