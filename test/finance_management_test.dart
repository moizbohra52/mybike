import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/accounting_management_service.dart';
import 'package:mybike/core/services/finance_management_service.dart';
import 'package:mybike/features/finance/domain/entities/finance_voucher_entity.dart';
import 'package:mybike/features/finance/domain/entities/party_outstanding_entity.dart';
import 'package:mybike/features/finance/data/models/finance_voucher_model.dart';
import 'package:mybike/features/finance/presentation/cubit/finance_dashboard_cubit.dart';
import 'package:mybike/features/finance/presentation/cubit/voucher_list_cubit.dart';
import 'package:mybike/features/finance/presentation/cubit/voucher_form_cubit.dart';
import 'package:mybike/features/finance/presentation/cubit/outstanding_cubit.dart';

void main() {
  setUp(() {
    AccountingManagementService.instance.resetDevData();
    FinanceManagementService.instance.resetDevData();
  });

  group('Finance Module — Domain Entities & Data Models', () {
    test('FinanceVoucherEntity and FinanceVoucherModel serialization and properties', () {
      final now = DateTime(2026, 2, 1);
      final voucher = FinanceVoucherEntity(
        id: 'vch-test-1',
        showroomId: 'showroom-mumbai-main',
        voucherNumber: 'PMT-MUM-2026-00001',
        voucherType: 'payment',
        voucherDate: now,
        partyType: 'supplier',
        partyId: 'oem-honda',
        partyName: 'Honda Motorcycle & Scooter India Pvt Ltd',
        partyPhone: '+91 22 6677 8800',
        paymentMode: 'bank_transfer',
        sourceAccountId: 'acc-1020',
        destinationAccountId: 'acc-2010',
        amount: 250000.0,
        taxDeductedTds: 5000.0,
        netAmount: 245000.0,
        referenceNumber: 'RTGS-HDFC-99128',
        referenceDate: now,
        bankName: 'HDFC Bank',
        narration: 'Payment for stock shipment',
        status: 'posted',
        journalEntryId: 'jrn-test-1',
        createdAt: now,
        updatedAt: now,
      );

      expect(voucher.isPayment, isTrue);
      expect(voucher.isReceipt, isFalse);
      expect(voucher.isContra, isFalse);
      expect(voucher.isPosted, isTrue);
      expect(voucher.typeLabel, equals('Payment Voucher'));
      expect(voucher.paymentModeLabel, equals('Bank Transfer (NEFT/RTGS)'));

      final json = FinanceVoucherModel.toJson(voucher);
      final fromJson = FinanceVoucherModel.fromJson(json);

      expect(fromJson.id, equals('vch-test-1'));
      expect(fromJson.voucherNumber, equals('PMT-MUM-2026-00001'));
      expect(fromJson.voucherType, equals('payment'));
      expect(fromJson.amount, equals(250000.0));
      expect(fromJson.taxDeductedTds, equals(5000.0));
      expect(fromJson.netAmount, equals(245000.0));
      expect(fromJson.paymentMode, equals('bank_transfer'));
    });

    test('PartyOutstandingEntity calculations and aging categorization', () {
      const party = PartyOutstandingEntity(
        partyId: 'cust-001',
        partyName: 'Ankit Verma',
        partyType: 'customer',
        phone: '+91 98201 23456',
        totalInvoiced: 200000.0,
        totalSettled: 150000.0,
        outstandingBalance: 50000.0,
        bucket0To30: 30000.0,
        bucket31To60: 20000.0,
        bucket61To90: 0.0,
        bucket90Plus: 0.0,
      );

      expect(party.isReceivable, isTrue);
      expect(party.isPayable, isFalse);
      expect(party.hasOverdue, isTrue);
      expect(party.outstandingBalance, equals(50000.0));
    });
  });

  group('FinanceManagementService — Core Financial Workflows & GL Integration', () {
    test('Service retrieves real-time liquid balances from Chart of Accounts', () async {
      final service = FinanceManagementService.instance;
      final liquid = await service.getLiquidBalances();

      expect(liquid['totalLiquid'], greaterThan(0));
      expect(liquid['totalCash'], greaterThan(0));
      expect(liquid['totalBank'], greaterThan(0));
      expect(liquid['cashAccounts'], isNotEmpty);
      expect(liquid['bankAccounts'], isNotEmpty);
      expect(liquid['totalLiquid'], equals(liquid['totalCash'] + liquid['totalBank']));
    });

    test('Recording a Payment Voucher posts double-entry transaction and reduces bank balance', () async {
      final financeService = FinanceManagementService.instance;
      final accountingService = AccountingManagementService.instance;

      final bankBefore = (await accountingService.fetchAccountById('acc-1020'))!.currentBalance;
      final creditorBefore = (await accountingService.fetchAccountById('acc-2010'))!.currentBalance;

      final voucher = await financeService.createVoucher(
        FinanceVoucherEntity(
          id: '',
          showroomId: 'showroom-mumbai-main',
          voucherNumber: '',
          voucherType: 'payment',
          voucherDate: DateTime.now(),
          partyType: 'supplier',
          partyId: 'oem-honda',
          partyName: 'Honda Motorcycle Ltd',
          paymentMode: 'bank_transfer',
          sourceAccountId: 'acc-1020', // Bank Credit
          destinationAccountId: 'acc-2010', // Creditor Debit
          amount: 50000.0,
          netAmount: 50000.0,
          narration: 'Vendor partial invoice payment',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        autoPostToGL: true,
      );

      expect(voucher.status, equals('posted'));
      expect(voucher.journalEntryId, isNotNull);
      expect(voucher.voucherNumber.startsWith('PMT-'), isTrue);

      final bankAfter = (await accountingService.fetchAccountById('acc-1020'))!.currentBalance;
      final creditorAfter = (await accountingService.fetchAccountById('acc-2010'))!.currentBalance;

      // Bank is Asset: Credit decreases balance
      expect(bankAfter, equals(bankBefore - 50000.0));
      // Creditor is Liability: Debit decreases balance
      expect(creditorAfter, equals(creditorBefore - 50000.0));
    });

    test('Recording a Receipt Voucher increases cash drawer balance', () async {
      final financeService = FinanceManagementService.instance;
      final accountingService = AccountingManagementService.instance;

      final cashBefore = (await accountingService.fetchAccountById('acc-1010'))!.currentBalance;

      final voucher = await financeService.createVoucher(
        FinanceVoucherEntity(
          id: '',
          showroomId: 'showroom-mumbai-main',
          voucherNumber: '',
          voucherType: 'receipt',
          voucherDate: DateTime.now(),
          partyType: 'customer',
          partyId: 'cust-101',
          partyName: 'Ankit Verma',
          paymentMode: 'cash',
          sourceAccountId: 'acc-2030', // Customer Advance Credit
          destinationAccountId: 'acc-1010', // Cash on Hand Debit
          amount: 10000.0,
          netAmount: 10000.0,
          narration: 'Cash token advance receipt',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        autoPostToGL: true,
      );

      expect(voucher.status, equals('posted'));
      expect(voucher.voucherNumber.startsWith('RCT-'), isTrue);

      final cashAfter = (await accountingService.fetchAccountById('acc-1010'))!.currentBalance;
      // Cash is Asset: Debit increases balance
      expect(cashAfter, equals(cashBefore + 10000.0));
    });

    test('Contra Transfer shifts funds between Cash and Bank while preserving total liquid assets', () async {
      final financeService = FinanceManagementService.instance;
      final accountingService = AccountingManagementService.instance;

      final liquidBefore = (await financeService.getLiquidBalances())['totalLiquid'] as double;
      final cashBefore = (await accountingService.fetchAccountById('acc-1010'))!.currentBalance;
      final bankBefore = (await accountingService.fetchAccountById('acc-1020'))!.currentBalance;

      // Deposit ₹25,000 Cash into Bank
      final voucher = await financeService.createVoucher(
        FinanceVoucherEntity(
          id: '',
          showroomId: 'showroom-mumbai-main',
          voucherNumber: '',
          voucherType: 'contra',
          voucherDate: DateTime.now(),
          partyType: 'bank',
          partyName: 'HDFC Bank Fort Branch',
          paymentMode: 'cash',
          sourceAccountId: 'acc-1010', // Cash Drawer Credit (decrease)
          destinationAccountId: 'acc-1020', // Bank Debit (increase)
          amount: 25000.0,
          netAmount: 25000.0,
          narration: 'Cash drawer surplus deposit to HDFC Current Account',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        autoPostToGL: true,
      );

      expect(voucher.voucherNumber.startsWith('CNT-'), isTrue);

      final cashAfter = (await accountingService.fetchAccountById('acc-1010'))!.currentBalance;
      final bankAfter = (await accountingService.fetchAccountById('acc-1020'))!.currentBalance;
      final liquidAfter = (await financeService.getLiquidBalances())['totalLiquid'] as double;

      expect(cashAfter, equals(cashBefore - 25000.0));
      expect(bankAfter, equals(bankBefore + 25000.0));
      expect(liquidAfter, equals(liquidBefore)); // Total liquid capital invariant preserved!
    });

    test('Outstandings summary calculates receivables, payables, and aging breakdown', () async {
      final service = FinanceManagementService.instance;

      final receivables = await service.fetchCustomerReceivables();
      final payables = await service.fetchSupplierPayables();
      final summary = await service.getOutstandingsSummary();

      expect(receivables, isNotEmpty);
      expect(payables, isNotEmpty);
      expect(summary['totalReceivable'], greaterThan(0));
      expect(summary['totalPayable'], greaterThan(0));
      expect(summary['receivablesCount'], equals(receivables.length));
      expect(summary['payablesCount'], equals(payables.length));
    });
  });

  group('Finance Module — Presentation Cubits', () {
    test('FinanceDashboardCubit loads KPIs, liquid positions, and recent vouchers', () async {
      final cubit = FinanceDashboardCubit();

      await cubit.loadDashboard();
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.totalLiquid, greaterThan(0));
      expect(cubit.state.cashAccounts, isNotEmpty);
      expect(cubit.state.bankAccounts, isNotEmpty);
      expect(cubit.state.recentVouchers, isNotEmpty);

      cubit.close();
    });

    test('VoucherListCubit loads vouchers and filters by type, status, and search query', () async {
      final cubit = VoucherListCubit();

      await cubit.loadVouchers();
      expect(cubit.state.vouchers, isNotEmpty);

      // Filter by payment type
      cubit.filterByType('payment');
      expect(cubit.state.filteredVouchers.every((v) => v.voucherType == 'payment'), isTrue);

      // Filter by contra type
      cubit.filterByType('contra');
      expect(cubit.state.filteredVouchers.every((v) => v.voucherType == 'contra'), isTrue);

      // Search query across all vouchers
      cubit.filterByType('all');
      cubit.searchVouchers('Honda');
      expect(cubit.state.filteredVouchers.any((v) => v.partyName.contains('Honda')), isTrue);

      cubit.clearFilters();
      expect(cubit.state.filteredVouchers.length, equals(cubit.state.vouchers.length));

      cubit.close();
    });

    test('VoucherFormCubit validates form and submits posted financial voucher', () async {
      final cubit = VoucherFormCubit();

      await cubit.init(voucherType: 'payment');
      expect(cubit.state.availableAccounts, isNotEmpty);
      expect(cubit.state.voucherType, equals('payment'));
      expect(cubit.state.isValid, isFalse); // Amount and party not yet set

      cubit.updateField(
        partyName: 'Ather Energy Parts Hub',
        amount: 35000.0,
        narration: 'Spare parts advance payment',
      );

      expect(cubit.state.amount, equals(35000.0));
      expect(cubit.state.isValid, isTrue);

      final success = await cubit.submitVoucher(autoPostToGL: true);
      expect(success, isTrue);
      expect(cubit.state.savedVoucher, isNotNull);
      expect(cubit.state.savedVoucher!.voucherNumber.startsWith('PMT-'), isTrue);

      cubit.close();
    });

    test('OutstandingCubit switches tabs and searches receivables and payables', () async {
      final cubit = OutstandingCubit();

      await cubit.loadOutstandings();
      expect(cubit.state.customerReceivables, isNotEmpty);
      expect(cubit.state.supplierPayables, isNotEmpty);
      expect(cubit.state.isReceivablesTab, isTrue);

      // Switch to Payables
      cubit.switchTab('payables');
      expect(cubit.state.isReceivablesTab, isFalse);

      // Search
      cubit.searchParties('Honda');
      expect(cubit.state.filteredPayables.any((p) => p.partyName.contains('Honda')), isTrue);

      cubit.close();
    });
  });
}
