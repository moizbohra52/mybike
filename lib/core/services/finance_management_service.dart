import 'accounting_management_service.dart';
import '../../features/finance/domain/entities/finance_voucher_entity.dart';
import '../../features/finance/domain/entities/party_outstanding_entity.dart';
import '../../features/accounting/domain/entities/journal_entry_entity.dart';
import '../../features/accounting/domain/entities/journal_line_entity.dart';

/// Finance Management Service
///
/// Handles Cash & Bank accounts, Payments, Receipts, Contra transfers,
/// Credit/Debit Notes, Outstandings aging analysis, and real-time
/// synchronization with the Double-Entry General Ledger.
class FinanceManagementService {
  FinanceManagementService._();
  static final FinanceManagementService instance = FinanceManagementService._();

  final AccountingManagementService _accountingService = AccountingManagementService.instance;

  // ═══════════════════════════════════════════════════════════════════
  // DEV SEED DATA — REALISTIC INDIAN TWO-WHEELER DEALERSHIP
  // ═══════════════════════════════════════════════════════════════════

  static final DateTime _now = DateTime.now();
  static final DateTime _twoDaysAgo = _now.subtract(const Duration(days: 2));
  static final DateTime _tenDaysAgo = _now.subtract(const Duration(days: 10));
  static final DateTime _twentyDaysAgo = _now.subtract(const Duration(days: 20));

  static const String _mumbaiId = 'showroom-mumbai-main';
  static const String _puneId = 'showroom-pune-west';

  static final List<FinanceVoucherEntity> _devVouchers = [
    // 1. Payment Voucher: OEM Stock Purchase (Honda)
    FinanceVoucherEntity(
      id: 'vch-001',
      showroomId: _mumbaiId,
      voucherNumber: 'PMT-MUM-2026-00001',
      voucherType: 'payment',
      voucherDate: _twentyDaysAgo,
      partyType: 'oem',
      partyId: 'oem-honda',
      partyName: 'Honda Motorcycle & Scooter India Pvt Ltd',
      partyPhone: '+91 22 6677 8800',
      paymentMode: 'bank_transfer',
      sourceAccountId: 'acc-1020', // HDFC Bank
      destinationAccountId: 'acc-2010', // Sundry Creditors
      amount: 1500000.0,
      taxDeductedTds: 0.0,
      netAmount: 1500000.0,
      referenceNumber: 'RTGS-HDFC-994821034',
      referenceDate: _twentyDaysAgo,
      bankName: 'HDFC Bank',
      narration: 'Batch payment for 10 units Honda Shine 125 stock shipment',
      status: 'posted',
      journalEntryId: 'jrn-pmt-001',
      createdAt: _twentyDaysAgo,
      updatedAt: _twentyDaysAgo,
      showroomName: 'Mumbai Flagship',
      sourceAccountName: 'HDFC Bank Current A/c (Operations)',
      destinationAccountName: 'Sundry Creditors — OEMs (Honda / Ather / TVS)',
    ),

    // 2. Receipt Voucher: Customer Advance (Cashier Drawer)
    FinanceVoucherEntity(
      id: 'vch-002',
      showroomId: _mumbaiId,
      voucherNumber: 'RCT-MUM-2026-00001',
      voucherType: 'receipt',
      voucherDate: _tenDaysAgo,
      partyType: 'customer',
      partyId: 'cust-101',
      partyName: 'Ankit Verma',
      partyPhone: '+91 98201 23456',
      paymentMode: 'cash',
      sourceAccountId: 'acc-2030', // Customer Advance Booking Deposits
      destinationAccountId: 'acc-1010', // Cash on Hand
      amount: 15000.0,
      taxDeductedTds: 0.0,
      netAmount: 15000.0,
      referenceNumber: 'CASH-REC-001',
      referenceDate: _tenDaysAgo,
      narration: 'Booking token advance receipt for TVS Apache RTR 160 4V',
      status: 'posted',
      journalEntryId: 'jrn-rct-001',
      createdAt: _tenDaysAgo,
      updatedAt: _tenDaysAgo,
      showroomName: 'Mumbai Flagship',
      sourceAccountName: 'Customer Advance Booking Deposits',
      destinationAccountName: 'Cash on Hand (Showroom Drawers)',
    ),

    // 3. Contra Transfer: Cash Deposit to Bank
    FinanceVoucherEntity(
      id: 'vch-003',
      showroomId: _mumbaiId,
      voucherNumber: 'CNT-MUM-2026-00001',
      voucherType: 'contra',
      voucherDate: _twoDaysAgo,
      partyType: 'bank',
      partyId: 'bank-hdfc',
      partyName: 'HDFC Bank Operations Deposit',
      paymentMode: 'cash',
      sourceAccountId: 'acc-1010', // Cash on Hand
      destinationAccountId: 'acc-1020', // HDFC Bank
      amount: 50000.0,
      taxDeductedTds: 0.0,
      netAmount: 50000.0,
      referenceNumber: 'CHQ-DEP-773412',
      referenceDate: _twoDaysAgo,
      bankName: 'HDFC Bank - Fort Branch',
      narration: 'Cashier daily showroom excess cash deposit to HDFC Current Account',
      status: 'posted',
      journalEntryId: 'jrn-cnt-001',
      createdAt: _twoDaysAgo,
      updatedAt: _twoDaysAgo,
      showroomName: 'Mumbai Flagship',
      sourceAccountName: 'Cash on Hand (Showroom Drawers)',
      destinationAccountName: 'HDFC Bank Current A/c (Operations)',
    ),

    // 4. Petty Cash Expense Voucher: Showroom Utility & Refreshments
    FinanceVoucherEntity(
      id: 'vch-004',
      showroomId: _mumbaiId,
      voucherNumber: 'EXP-MUM-2026-00001',
      voucherType: 'expense',
      voucherDate: _twoDaysAgo,
      partyType: 'other',
      partyName: 'City Power Corporation & Refreshments',
      paymentMode: 'cash',
      sourceAccountId: 'acc-1010', // Cash on Hand
      destinationAccountId: 'acc-6030', // Electricity & Utilities
      amount: 4500.0,
      taxDeductedTds: 0.0,
      netAmount: 4500.0,
      referenceNumber: 'BILL-UTIL-4421',
      referenceDate: _twoDaysAgo,
      narration: 'Emergency water dispenser recharge and client tea/coffee supplies',
      status: 'posted',
      journalEntryId: 'jrn-exp-001',
      createdAt: _twoDaysAgo,
      updatedAt: _twoDaysAgo,
      showroomName: 'Mumbai Flagship',
      sourceAccountName: 'Cash on Hand (Showroom Drawers)',
      destinationAccountName: 'Showroom Electricity & Utilities',
    ),

    // 5. Credit Note: Customer Accessory Price Adjustment
    FinanceVoucherEntity(
      id: 'vch-005',
      showroomId: _puneId,
      voucherNumber: 'CRN-PUN-2026-00001',
      voucherType: 'credit_note',
      voucherDate: _twoDaysAgo,
      partyType: 'customer',
      partyId: 'cust-102',
      partyName: 'Priya Sharma',
      partyPhone: '+91 98330 45678',
      paymentMode: 'clearing',
      sourceAccountId: 'acc-1030', // Sundry Debtors
      destinationAccountId: 'acc-4020', // Sales Revenue Accessories
      amount: 2500.0,
      taxDeductedTds: 0.0,
      netAmount: 2500.0,
      referenceNumber: 'INV-2026-00042',
      referenceDate: _twoDaysAgo,
      narration: 'Credit note issued for complimentary seat cover discount after delivery',
      status: 'posted',
      journalEntryId: 'jrn-crn-001',
      createdAt: _twoDaysAgo,
      updatedAt: _twoDaysAgo,
      showroomName: 'Pune West Hub',
      sourceAccountName: 'Sundry Debtors (Customer Receivables)',
      destinationAccountName: 'Sales Revenue — Accessories Pack & Helmets',
    ),

    // 6. Debit Note: Transit Damage Claim on OEM
    FinanceVoucherEntity(
      id: 'vch-006',
      showroomId: _mumbaiId,
      voucherNumber: 'DBN-MUM-2026-00001',
      voucherType: 'debit_note',
      voucherDate: _twoDaysAgo,
      partyType: 'oem',
      partyId: 'oem-tvs',
      partyName: 'TVS Motor Company Ltd',
      paymentMode: 'clearing',
      sourceAccountId: 'acc-2010', // Sundry Creditors
      destinationAccountId: 'acc-1040', // Vehicle Inventory
      amount: 8000.0,
      taxDeductedTds: 0.0,
      netAmount: 8000.0,
      referenceNumber: 'CHALLAN-INW-8891',
      referenceDate: _twoDaysAgo,
      narration: 'Debit note debiting OEM ledger for rear panel transit paint scratch',
      status: 'posted',
      journalEntryId: 'jrn-dbn-001',
      createdAt: _twoDaysAgo,
      updatedAt: _twoDaysAgo,
      showroomName: 'Mumbai Flagship',
      sourceAccountName: 'Sundry Creditors — OEMs (Honda / Ather / TVS)',
      destinationAccountName: 'Vehicle Inventory — Petrol Motorcycles',
    ),
  ];

  static final List<PartyOutstandingEntity> _devCustomerReceivables = [
    PartyOutstandingEntity(
      partyId: 'cust-101',
      partyName: 'Ankit Verma',
      partyType: 'customer',
      phone: '+91 98201 23456',
      email: 'ankit.verma@example.com',
      showroomId: _mumbaiId,
      showroomName: 'Mumbai Flagship',
      totalInvoiced: 215799.98,
      totalSettled: 150000.0,
      outstandingBalance: 65799.98,
      bucket0To30: 65799.98,
      bucket31To60: 0.0,
      bucket61To90: 0.0,
      bucket90Plus: 0.0,
      latestInvoiceDate: _tenDaysAgo,
    ),
    PartyOutstandingEntity(
      partyId: 'cust-102',
      partyName: 'Priya Sharma',
      partyType: 'customer',
      phone: '+91 98330 45678',
      email: 'priya.sharma@example.com',
      showroomId: _puneId,
      showroomName: 'Pune West Hub',
      totalInvoiced: 154999.0,
      totalSettled: 120000.0,
      outstandingBalance: 34999.0,
      bucket0To30: 34999.0,
      bucket31To60: 0.0,
      bucket61To90: 0.0,
      bucket90Plus: 0.0,
      latestInvoiceDate: _twoDaysAgo,
    ),
    PartyOutstandingEntity(
      partyId: 'cust-103',
      partyName: 'Vikram Malhotra',
      partyType: 'customer',
      phone: '+91 98111 22334',
      email: 'vikram.m@example.com',
      showroomId: _mumbaiId,
      showroomName: 'Mumbai Flagship',
      totalInvoiced: 185000.0,
      totalSettled: 100000.0,
      outstandingBalance: 85000.0,
      bucket0To30: 0.0,
      bucket31To60: 85000.0,
      bucket61To90: 0.0,
      bucket90Plus: 0.0,
      latestInvoiceDate: _twentyDaysAgo,
    ),
    PartyOutstandingEntity(
      partyId: 'cust-104',
      partyName: 'Rajesh Patel',
      partyType: 'customer',
      phone: '+91 97222 33445',
      email: 'rajesh.patel@example.com',
      showroomId: _mumbaiId,
      showroomName: 'Mumbai Flagship',
      totalInvoiced: 142000.0,
      totalSettled: 50000.0,
      outstandingBalance: 92000.0,
      bucket0To30: 0.0,
      bucket31To60: 0.0,
      bucket61To90: 92000.0,
      bucket90Plus: 0.0,
      latestInvoiceDate: _now.subtract(const Duration(days: 75)),
    ),
    PartyOutstandingEntity(
      partyId: 'cust-105',
      partyName: 'Sunita Rao',
      partyType: 'customer',
      phone: '+91 99887 76655',
      email: 'sunita.rao@example.com',
      showroomId: _puneId,
      showroomName: 'Pune West Hub',
      totalInvoiced: 110000.0,
      totalSettled: 67799.0,
      outstandingBalance: 42201.0,
      bucket0To30: 0.0,
      bucket31To60: 0.0,
      bucket61To90: 0.0,
      bucket90Plus: 42201.0,
      latestInvoiceDate: _now.subtract(const Duration(days: 120)),
    ),
  ];

  static final List<PartyOutstandingEntity> _devSupplierPayables = [
    PartyOutstandingEntity(
      partyId: 'oem-honda',
      partyName: 'Honda Motorcycle & Scooter India Pvt Ltd',
      partyType: 'supplier',
      phone: '+91 22 6677 8800',
      email: 'orders@honda2wheelersindia.com',
      showroomId: _mumbaiId,
      showroomName: 'Mumbai Flagship',
      totalInvoiced: 4500000.0,
      totalSettled: 3000000.0,
      outstandingBalance: 1500000.0,
      bucket0To30: 1500000.0,
      bucket31To60: 0.0,
      bucket61To90: 0.0,
      bucket90Plus: 0.0,
      latestInvoiceDate: _tenDaysAgo,
    ),
    PartyOutstandingEntity(
      partyId: 'oem-ather',
      partyName: 'Ather Energy Pvt Ltd',
      partyType: 'supplier',
      phone: '+91 80 6633 4455',
      email: 'dealer.ops@atherenergy.com',
      showroomId: _puneId,
      showroomName: 'Pune West Hub',
      totalInvoiced: 2800000.0,
      totalSettled: 1850000.0,
      outstandingBalance: 950000.0,
      bucket0To30: 950000.0,
      bucket31To60: 0.0,
      bucket61To90: 0.0,
      bucket90Plus: 0.0,
      latestInvoiceDate: _twoDaysAgo,
    ),
    PartyOutstandingEntity(
      partyId: 'oem-tvs',
      partyName: 'TVS Motor Company Ltd',
      partyType: 'supplier',
      phone: '+91 44 2833 2111',
      email: 'dealersupport@tvsmotor.com',
      showroomId: _mumbaiId,
      showroomName: 'Mumbai Flagship',
      totalInvoiced: 1600000.0,
      totalSettled: 1100000.0,
      outstandingBalance: 500000.0,
      bucket0To30: 0.0,
      bucket31To60: 500000.0,
      bucket61To90: 0.0,
      bucket90Plus: 0.0,
      latestInvoiceDate: _twentyDaysAgo,
    ),
    PartyOutstandingEntity(
      partyId: 'supp-parts',
      partyName: 'Apex Two-Wheeler Accessories Hub',
      partyType: 'supplier',
      phone: '+91 22 2455 6677',
      email: 'sales@apexhelmets.in',
      showroomId: _mumbaiId,
      showroomName: 'Mumbai Flagship',
      totalInvoiced: 320000.0,
      totalSettled: 170000.0,
      outstandingBalance: 150000.0,
      bucket0To30: 0.0,
      bucket31To60: 0.0,
      bucket61To90: 150000.0,
      bucket90Plus: 0.0,
      latestInvoiceDate: _now.subtract(const Duration(days: 70)),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════
  // STATE STORE (IN-MEMORY DEV MODE)
  // ═══════════════════════════════════════════════════════════════════

  late List<FinanceVoucherEntity> _vouchers = List.from(_devVouchers);
  late List<PartyOutstandingEntity> _customers = List.from(_devCustomerReceivables);
  late List<PartyOutstandingEntity> _suppliers = List.from(_devSupplierPayables);
  int _voucherSeq = 7;

  /// Reset in-memory dev state (used for test isolation)
  void resetDevData() {
    _vouchers = List.from(_devVouchers);
    _customers = List.from(_devCustomerReceivables);
    _suppliers = List.from(_devSupplierPayables);
    _voucherSeq = 7;
  }

  // ═══════════════════════════════════════════════════════════════════
  // CASH & BANK BALANCES (QUERIED DIRECTLY FROM GENERAL LEDGER)
  // ═══════════════════════════════════════════════════════════════════

  /// Get liquid asset balances (Cash and Bank accounts)
  Future<Map<String, dynamic>> getLiquidBalances({String? showroomId}) async {
    final accounts = await _accountingService.fetchAccounts(showroomId: showroomId);
    
    final cashAccounts = accounts.where((a) => a.subType == 'cash').toList();
    final bankAccounts = accounts.where((a) => a.subType == 'bank').toList();

    final totalCash = cashAccounts.fold<double>(0.0, (sum, a) => sum + a.currentBalance);
    final totalBank = bankAccounts.fold<double>(0.0, (sum, a) => sum + a.currentBalance);
    final totalLiquid = totalCash + totalBank;

    return {
      'totalLiquid': totalLiquid,
      'totalCash': totalCash,
      'totalBank': totalBank,
      'cashAccounts': cashAccounts,
      'bankAccounts': bankAccounts,
    };
  }

  // ═══════════════════════════════════════════════════════════════════
  // VOUCHER MANAGEMENT & AUTOMATIC DOUBLE-ENTRY POSTING
  // ═══════════════════════════════════════════════════════════════════

  /// Fetch vouchers with optional filtering
  Future<List<FinanceVoucherEntity>> fetchVouchers({
    String? showroomId,
    String? voucherType,
    String? status,
    String? search,
  }) async {
    var result = List<FinanceVoucherEntity>.from(_vouchers);

    if (showroomId != null && showroomId.isNotEmpty) {
      result = result.where((v) => v.showroomId == showroomId).toList();
    }
    if (voucherType != null && voucherType.isNotEmpty && voucherType != 'all') {
      result = result.where((v) => v.voucherType == voucherType).toList();
    }
    if (status != null && status.isNotEmpty && status != 'all') {
      result = result.where((v) => v.status == status).toList();
    }
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      result = result.where((v) =>
          v.voucherNumber.toLowerCase().contains(s) ||
          v.partyName.toLowerCase().contains(s) ||
          (v.referenceNumber?.toLowerCase().contains(s) ?? false)).toList();
    }

    // Sort descending by date
    result.sort((a, b) => b.voucherDate.compareTo(a.voucherDate));
    return result;
  }

  /// Create and post a Financial Voucher with automatic General Ledger integration
  Future<FinanceVoucherEntity> createVoucher(
    FinanceVoucherEntity voucher, {
    bool autoPostToGL = true,
  }) async {
    if (voucher.amount <= 0) {
      throw ArgumentError('Voucher amount must be strictly positive.');
    }

    final prefix = _getVoucherPrefix(voucher.voucherType);
    final voucherNumber = voucher.voucherNumber.isNotEmpty
        ? voucher.voucherNumber
        : '$prefix-DEV-${_voucherSeq.toString().padLeft(5, '0')}';
    _voucherSeq++;

    final voucherId = 'vch-${DateTime.now().millisecondsSinceEpoch}';

    String? createdJournalId;

    // ─── AUTOMATIC GENERAL LEDGER DOUBLE-ENTRY INTEGRATION ───
    if (autoPostToGL && voucher.sourceAccountId != null && voucher.destinationAccountId != null) {
      final glEntry = await _postCorrespondingJournalEntry(
        voucherId: voucherId,
        voucherNumber: voucherNumber,
        voucher: voucher,
      );
      createdJournalId = glEntry.id;
    }

    final newVoucher = voucher.copyWith(
      id: voucherId,
      voucherNumber: voucherNumber,
      status: 'posted',
      journalEntryId: createdJournalId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _vouchers.insert(0, newVoucher);
    return newVoucher;
  }

  /// Internal handler: Maps financial voucher into a balanced Double-Entry Journal Voucher
  Future<JournalEntryEntity> _postCorrespondingJournalEntry({
    required String voucherId,
    required String voucherNumber,
    required FinanceVoucherEntity voucher,
  }) async {
    final srcAcct = await _accountingService.fetchAccountById(voucher.sourceAccountId!);
    final destAcct = await _accountingService.fetchAccountById(voucher.destinationAccountId!);

    if (srcAcct == null || destAcct == null) {
      throw ArgumentError('Specified source or destination account does not exist in Chart of Accounts.');
    }

    // Determine Debit and Credit assignment based on voucher nature
    // - PAYMENT / EXPENSE:
    //   Debit: Destination (Vendor / Expense / Liability)
    //   Credit: Source (Cash / Bank)
    // - RECEIPT:
    //   Debit: Destination (Cash / Bank)
    //   Credit: Source (Customer / Debtors / Advance)
    // - CONTRA:
    //   Debit: Destination (Receiving Cash or Bank)
    //   Credit: Source (Sending Cash or Bank)
    // - CREDIT NOTE:
    //   Debit: Destination (Sales Return / Discount)
    //   Credit: Source (Customer Debtors)
    // - DEBIT NOTE:
    //   Debit: Source (Vendor Payable)
    //   Credit: Destination (Purchase Return / Cost Adjustment)

    String debitAccountId;
    String debitAccountName;
    String debitAccountCode;
    String debitAccountType;

    String creditAccountId;
    String creditAccountName;
    String creditAccountCode;
    String creditAccountType;

    if (voucher.isPayment || voucher.isExpense) {
      debitAccountId = destAcct.id;
      debitAccountName = destAcct.accountName;
      debitAccountCode = destAcct.accountCode;
      debitAccountType = destAcct.accountType;

      creditAccountId = srcAcct.id;
      creditAccountName = srcAcct.accountName;
      creditAccountCode = srcAcct.accountCode;
      creditAccountType = srcAcct.accountType;
    } else if (voucher.isReceipt || voucher.isContra) {
      debitAccountId = destAcct.id;
      debitAccountName = destAcct.accountName;
      debitAccountCode = destAcct.accountCode;
      debitAccountType = destAcct.accountType;

      creditAccountId = srcAcct.id;
      creditAccountName = srcAcct.accountName;
      creditAccountCode = srcAcct.accountCode;
      creditAccountType = srcAcct.accountType;
    } else if (voucher.isCreditNote) {
      debitAccountId = destAcct.id;
      debitAccountName = destAcct.accountName;
      debitAccountCode = destAcct.accountCode;
      debitAccountType = destAcct.accountType;

      creditAccountId = srcAcct.id;
      creditAccountName = srcAcct.accountName;
      creditAccountCode = srcAcct.accountCode;
      creditAccountType = srcAcct.accountType;
    } else {
      // Debit Note
      debitAccountId = srcAcct.id;
      debitAccountName = srcAcct.accountName;
      debitAccountCode = srcAcct.accountCode;
      debitAccountType = srcAcct.accountType;

      creditAccountId = destAcct.id;
      creditAccountName = destAcct.accountName;
      creditAccountCode = destAcct.accountCode;
      creditAccountType = destAcct.accountType;
    }

    final lines = [
      JournalLineEntity(
        id: 'line-dr-${DateTime.now().microsecondsSinceEpoch}',
        journalEntryId: '',
        accountId: debitAccountId,
        accountCode: debitAccountCode,
        accountName: debitAccountName,
        accountType: debitAccountType,
        debitAmount: voucher.netAmount,
        creditAmount: 0.0,
        description: '${voucher.typeLabel}: ${voucher.partyName}',
        createdAt: DateTime.now(),
      ),
      JournalLineEntity(
        id: 'line-cr-${DateTime.now().microsecondsSinceEpoch}',
        journalEntryId: '',
        accountId: creditAccountId,
        accountCode: creditAccountCode,
        accountName: creditAccountName,
        accountType: creditAccountType,
        debitAmount: 0.0,
        creditAmount: voucher.netAmount,
        description: '${voucher.typeLabel} via ${voucher.paymentModeLabel}',
        createdAt: DateTime.now(),
      ),
    ];

    final journalEntry = JournalEntryEntity(
      id: '',
      showroomId: voucher.showroomId,
      entryNumber: 'JRN-$voucherNumber',
      entryDate: voucher.voucherDate,
      referenceType: voucher.voucherType,
      referenceId: voucherNumber,
      narration: voucher.narration.isNotEmpty
          ? voucher.narration
          : '${voucher.typeLabel} for ${voucher.partyName} via ${voucher.paymentModeLabel}',
      totalDebit: voucher.netAmount,
      totalCredit: voucher.netAmount,
      isBalanced: true,
      status: 'posted',
      postedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      showroomName: voucher.showroomName,
    );

    return await _accountingService.createJournalEntry(
      journalEntry,
      lines,
      autoPost: true,
    );
  }

  String _getVoucherPrefix(String type) {
    switch (type) {
      case 'payment':
        return 'PMT';
      case 'receipt':
        return 'RCT';
      case 'contra':
        return 'CNT';
      case 'expense':
        return 'EXP';
      case 'credit_note':
        return 'CRN';
      case 'debit_note':
        return 'DBN';
      default:
        return 'VCH';
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // OUTSTANDINGS & AGING ANALYSIS (RECEIVABLES & PAYABLES)
  // ═══════════════════════════════════════════════════════════════════

  /// Fetch Customer Receivables (Sundry Debtors) with Aging breakdown
  Future<List<PartyOutstandingEntity>> fetchCustomerReceivables({String? showroomId}) async {
    var list = List<PartyOutstandingEntity>.from(_customers);
    if (showroomId != null && showroomId.isNotEmpty) {
      list = list.where((p) => p.showroomId == null || p.showroomId == showroomId).toList();
    }
    list.sort((a, b) => b.outstandingBalance.compareTo(a.outstandingBalance));
    return list;
  }

  /// Fetch Supplier/OEM Payables (Sundry Creditors) with Aging breakdown
  Future<List<PartyOutstandingEntity>> fetchSupplierPayables({String? showroomId}) async {
    var list = List<PartyOutstandingEntity>.from(_suppliers);
    if (showroomId != null && showroomId.isNotEmpty) {
      list = list.where((p) => p.showroomId == null || p.showroomId == showroomId).toList();
    }
    list.sort((a, b) => b.outstandingBalance.compareTo(a.outstandingBalance));
    return list;
  }

  /// Aggregate total receivables and payables KPIs
  Future<Map<String, dynamic>> getOutstandingsSummary({String? showroomId}) async {
    final receivables = await fetchCustomerReceivables(showroomId: showroomId);
    final payables = await fetchSupplierPayables(showroomId: showroomId);

    final totalReceivable = receivables.fold<double>(0.0, (s, r) => s + r.outstandingBalance);
    final totalPayable = payables.fold<double>(0.0, (s, p) => s + p.outstandingBalance);

    final overdueReceivables = receivables.fold<double>(
      0.0,
      (s, r) => s + (r.bucket31To60 + r.bucket61To90 + r.bucket90Plus),
    );

    final overduePayables = payables.fold<double>(
      0.0,
      (s, p) => s + (p.bucket31To60 + p.bucket61To90 + p.bucket90Plus),
    );

    return {
      'totalReceivable': totalReceivable,
      'totalPayable': totalPayable,
      'netWorkingBalance': totalReceivable - totalPayable,
      'overdueReceivables': overdueReceivables,
      'overduePayables': overduePayables,
      'receivablesCount': receivables.length,
      'payablesCount': payables.length,
    };
  }
}
