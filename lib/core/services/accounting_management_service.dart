import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import 'supabase_service.dart';
import '../../features/accounting/domain/entities/account_entity.dart';
import '../../features/accounting/domain/entities/journal_entry_entity.dart';
import '../../features/accounting/domain/entities/journal_line_entity.dart';
import '../../features/accounting/domain/entities/trial_balance_item_entity.dart';
import '../../features/accounting/data/models/account_model.dart';

/// Accounting Management Service
///
/// Handles Chart of Accounts (COA), double-entry journal vouchers, general ledger,
/// anti-tamper reversals, and trial balance calculations for MYBIKE.
class AccountingManagementService {
  AccountingManagementService._();
  static final AccountingManagementService instance = AccountingManagementService._();

  bool get _isSupabaseLive =>
      SupabaseConfig.isConfigured && SupabaseService.client != null;

  // ═══════════════════════════════════════════════════════════════════
  // DEV SEED DATA — INDIAN TWO-WHEELER DEALERSHIP STANDARD
  // ═══════════════════════════════════════════════════════════════════

  static final DateTime _now = DateTime.now();
  static final DateTime _monthAgo = _now.subtract(const Duration(days: 30));
  static final DateTime _fiveDaysAgo = _now.subtract(const Duration(days: 5));

  static const String _mumbaiId = 'showroom-mumbai-main';
  static const String _puneId = 'showroom-pune-west';

  static final List<AccountEntity> _devAccounts = [
    // ─── 1000s: ASSETS ───
    AccountEntity(
      id: 'acc-1010',
      accountCode: '1010',
      accountName: 'Cash on Hand (Showroom Drawers)',
      accountType: 'asset',
      subType: 'cash',
      openingBalance: 50000.0,
      currentBalance: 75000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-1020',
      accountCode: '1020',
      accountName: 'HDFC Bank Current A/c (Operations)',
      accountType: 'asset',
      subType: 'bank',
      openingBalance: 1500000.0,
      currentBalance: 2485000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-1021',
      accountCode: '1021',
      accountName: 'State Bank of India (Auto Loan Clearing)',
      accountType: 'asset',
      subType: 'bank',
      openingBalance: 500000.0,
      currentBalance: 950000.0,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-1030',
      accountCode: '1030',
      accountName: 'Sundry Debtors (Customer Receivables)',
      accountType: 'asset',
      subType: 'accounts_receivable',
      openingBalance: 250000.0,
      currentBalance: 320000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-1040',
      accountCode: '1040',
      accountName: 'Vehicle Inventory — Petrol Motorcycles',
      accountType: 'asset',
      subType: 'inventory',
      openingBalance: 3500000.0,
      currentBalance: 4200000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-1041',
      accountCode: '1041',
      accountName: 'Vehicle Inventory — Electric Scooters',
      accountType: 'asset',
      subType: 'inventory',
      openingBalance: 2000000.0,
      currentBalance: 2800000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-1050',
      accountCode: '1050',
      accountName: 'Spare Parts & Accessories Inventory',
      accountType: 'asset',
      subType: 'inventory',
      openingBalance: 450000.0,
      currentBalance: 520000.0,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-1060',
      accountCode: '1060',
      accountName: 'Input CGST Receivable (Tax Asset)',
      accountType: 'asset',
      subType: 'tax_asset',
      openingBalance: 85000.0,
      currentBalance: 120000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-1061',
      accountCode: '1061',
      accountName: 'Input SGST Receivable (Tax Asset)',
      accountType: 'asset',
      subType: 'tax_asset',
      openingBalance: 85000.0,
      currentBalance: 120000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),

    // ─── 2000s: LIABILITIES ───
    AccountEntity(
      id: 'acc-2010',
      accountCode: '2010',
      accountName: 'Sundry Creditors — OEMs (Honda / Ather / TVS)',
      accountType: 'liability',
      subType: 'accounts_payable',
      openingBalance: 2800000.0,
      currentBalance: 3100000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-2020',
      accountCode: '2020',
      accountName: 'Output CGST Payable (14% Petrol / 2.5% EV)',
      accountType: 'liability',
      subType: 'tax_payable',
      openingBalance: 110000.0,
      currentBalance: 165000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-2021',
      accountCode: '2021',
      accountName: 'Output SGST Payable (14% Petrol / 2.5% EV)',
      accountType: 'liability',
      subType: 'tax_payable',
      openingBalance: 110000.0,
      currentBalance: 165000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-2030',
      accountCode: '2030',
      accountName: 'Customer Advance Booking Deposits',
      accountType: 'liability',
      subType: 'advance_deposit',
      openingBalance: 150000.0,
      currentBalance: 210000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-2040',
      accountCode: '2040',
      accountName: 'RTO Road Tax & Registration Clearing A/c',
      accountType: 'liability',
      subType: 'clearing_account',
      openingBalance: 45000.0,
      currentBalance: 65000.0,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-2041',
      accountCode: '2041',
      accountName: 'Insurance Premium Collection Clearing A/c',
      accountType: 'liability',
      subType: 'clearing_account',
      openingBalance: 32000.0,
      currentBalance: 48000.0,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),

    // ─── 3000s: EQUITY ───
    AccountEntity(
      id: 'acc-3010',
      accountCode: '3010',
      accountName: 'Partner Capital / Promoter Equity',
      accountType: 'equity',
      subType: 'capital',
      openingBalance: 6421000.0,
      currentBalance: 6421000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-3020',
      accountCode: '3020',
      accountName: 'Retained Earnings / Dealership Surplus',
      accountType: 'equity',
      subType: 'retained_earnings',
      openingBalance: 850000.0,
      currentBalance: 1150000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),

    // ─── 4000s: REVENUE ───
    AccountEntity(
      id: 'acc-4010',
      accountCode: '4010',
      accountName: 'Sales Revenue — Petrol Two-Wheelers',
      accountType: 'revenue',
      subType: 'sales',
      openingBalance: 0.0,
      currentBalance: 1250000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-4011',
      accountCode: '4011',
      accountName: 'Sales Revenue — Electric Two-Wheelers',
      accountType: 'revenue',
      subType: 'sales',
      openingBalance: 0.0,
      currentBalance: 850000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-4020',
      accountCode: '4020',
      accountName: 'Sales Revenue — Accessories Pack & Helmets',
      accountType: 'revenue',
      subType: 'sales',
      openingBalance: 0.0,
      currentBalance: 78000.0,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-4030',
      accountCode: '4030',
      accountName: 'Auto Loan Subvention & Bank Finance Commission',
      accountType: 'revenue',
      subType: 'commission',
      openingBalance: 0.0,
      currentBalance: 65000.0,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-4031',
      accountCode: '4031',
      accountName: 'Comprehensive Insurance Referral Commission',
      accountType: 'revenue',
      subType: 'commission',
      openingBalance: 0.0,
      currentBalance: 42000.0,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),

    // ─── 5000s: COGS & 6000s: EXPENSES ───
    AccountEntity(
      id: 'acc-5010',
      accountCode: '5010',
      accountName: 'Cost of Goods Sold — Petrol Motorcycles',
      accountType: 'expense',
      subType: 'cogs',
      openingBalance: 0.0,
      currentBalance: 980000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-5011',
      accountCode: '5011',
      accountName: 'Cost of Goods Sold — Electric Scooters',
      accountType: 'expense',
      subType: 'cogs',
      openingBalance: 0.0,
      currentBalance: 670000.0,
      isSystemAccount: true,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-6010',
      accountCode: '6010',
      accountName: 'Showroom Facility Rent & Lease',
      accountType: 'expense',
      subType: 'operating_expense',
      openingBalance: 0.0,
      currentBalance: 125000.0,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-6020',
      accountCode: '6020',
      accountName: 'Staff Salaries, Sales Incentives & Wages',
      accountType: 'expense',
      subType: 'operating_expense',
      openingBalance: 0.0,
      currentBalance: 185000.0,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-6030',
      accountCode: '6030',
      accountName: 'Showroom Electricity & Utilities',
      accountType: 'expense',
      subType: 'operating_expense',
      openingBalance: 0.0,
      currentBalance: 24000.0,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
    AccountEntity(
      id: 'acc-6040',
      accountCode: '6040',
      accountName: 'Local Marketing, Signage & Digital Ads',
      accountType: 'expense',
      subType: 'operating_expense',
      openingBalance: 0.0,
      currentBalance: 35000.0,
      createdAt: _monthAgo,
      updatedAt: _now,
    ),
  ];

  static final List<JournalEntryEntity> _devJournals = [
    // 1. Initial Opening Balances Voucher
    JournalEntryEntity(
      id: 'jrn-001',
      showroomId: _mumbaiId,
      entryNumber: 'JRN-MUM-2026-00001',
      entryDate: _monthAgo,
      referenceType: 'manual',
      narration: 'Opening financial ledger balances for FY 2026-27 (Bank, Inventory vs Capital)',
      totalDebit: 6000000.0,
      totalCredit: 6000000.0,
      isBalanced: true,
      status: 'posted',
      postedAt: _monthAgo,
      createdAt: _monthAgo,
      updatedAt: _monthAgo,
      showroomName: 'Mumbai Flagship',
      lines: [
        JournalLineEntity(
          id: 'line-001',
          journalEntryId: 'jrn-001',
          accountId: 'acc-1020',
          accountCode: '1020',
          accountName: 'HDFC Bank Current A/c (Operations)',
          accountType: 'asset',
          description: 'HDFC Bank Opening Balance',
          debitAmount: 2000000.0,
          createdAt: _monthAgo,
        ),
        JournalLineEntity(
          id: 'line-002',
          journalEntryId: 'jrn-001',
          accountId: 'acc-1040',
          accountCode: '1040',
          accountName: 'Vehicle Inventory — Petrol Motorcycles',
          accountType: 'asset',
          description: 'Initial Honda & TVS floor stock',
          debitAmount: 4000000.0,
          createdAt: _monthAgo,
        ),
        JournalLineEntity(
          id: 'line-003',
          journalEntryId: 'jrn-001',
          accountId: 'acc-3010',
          accountCode: '3010',
          accountName: 'Partner Capital / Promoter Equity',
          accountType: 'equity',
          description: 'Promoter equity capital introduction',
          creditAmount: 6000000.0,
          createdAt: _monthAgo,
        ),
      ],
    ),

    // 2. Vehicle Sale Invoicing Voucher (Honda CB350)
    JournalEntryEntity(
      id: 'jrn-002',
      showroomId: _mumbaiId,
      entryNumber: 'JRN-MUM-2026-00002',
      entryDate: _fiveDaysAgo,
      referenceType: 'sales_invoice',
      referenceId: 'inv-001',
      narration: 'Accounting recognition for Sale of Honda CB350 under Invoice IND-MUM-INV-00184',
      totalDebit: 215799.98,
      totalCredit: 215799.98,
      isBalanced: true,
      status: 'posted',
      postedAt: _fiveDaysAgo,
      createdAt: _fiveDaysAgo,
      updatedAt: _fiveDaysAgo,
      showroomName: 'Mumbai Flagship',
      lines: [
        JournalLineEntity(
          id: 'line-004',
          journalEntryId: 'jrn-002',
          accountId: 'acc-1020',
          accountCode: '1020',
          accountName: 'HDFC Bank Current A/c (Operations)',
          accountType: 'asset',
          description: 'Full settlement received via Bank / UPI',
          debitAmount: 215799.98,
          createdAt: _fiveDaysAgo,
        ),
        JournalLineEntity(
          id: 'line-005',
          journalEntryId: 'jrn-002',
          accountId: 'acc-4010',
          accountCode: '4010',
          accountName: 'Sales Revenue — Petrol Two-Wheelers',
          accountType: 'revenue',
          description: 'Taxable Ex-showroom vehicle base',
          creditAmount: 168593.75,
          createdAt: _fiveDaysAgo,
        ),
        JournalLineEntity(
          id: 'line-006',
          journalEntryId: 'jrn-002',
          accountId: 'acc-2020',
          accountCode: '2020',
          accountName: 'Output CGST Payable (14% Petrol / 2.5% EV)',
          accountType: 'liability',
          description: 'Output CGST @ 14%',
          creditAmount: 23603.12,
          createdAt: _fiveDaysAgo,
        ),
        JournalLineEntity(
          id: 'line-007',
          journalEntryId: 'jrn-002',
          accountId: 'acc-2021',
          accountCode: '2021',
          accountName: 'Output SGST Payable (14% Petrol / 2.5% EV)',
          accountType: 'liability',
          description: 'Output SGST @ 14%',
          creditAmount: 23603.11,
          createdAt: _fiveDaysAgo,
        ),
      ],
    ),

    // 3. Electric Vehicle Sale Invoicing (Ather 450X)
    JournalEntryEntity(
      id: 'jrn-003',
      showroomId: _puneId,
      entryNumber: 'JRN-PUN-2026-00003',
      entryDate: _fiveDaysAgo,
      referenceType: 'sales_invoice',
      referenceId: 'inv-002',
      narration: 'Accounting recognition for Sale of Ather 450X under Invoice IND-PUN-INV-00042',
      totalDebit: 154999.0,
      totalCredit: 154999.0,
      isBalanced: true,
      status: 'posted',
      postedAt: _fiveDaysAgo,
      createdAt: _fiveDaysAgo,
      updatedAt: _fiveDaysAgo,
      showroomName: 'Pune West Hub',
      lines: [
        JournalLineEntity(
          id: 'line-008',
          journalEntryId: 'jrn-003',
          accountId: 'acc-1020',
          accountCode: '1020',
          accountName: 'HDFC Bank Current A/c (Operations)',
          accountType: 'asset',
          description: 'Customer payment received for EV',
          debitAmount: 154999.0,
          createdAt: _fiveDaysAgo,
        ),
        JournalLineEntity(
          id: 'line-009',
          journalEntryId: 'jrn-003',
          accountId: 'acc-4011',
          accountCode: '4011',
          accountName: 'Sales Revenue — Electric Two-Wheelers',
          accountType: 'revenue',
          description: 'Taxable EV Ex-showroom price',
          creditAmount: 147618.10,
          createdAt: _fiveDaysAgo,
        ),
        JournalLineEntity(
          id: 'line-010',
          journalEntryId: 'jrn-003',
          accountId: 'acc-2020',
          accountCode: '2020',
          accountName: 'Output CGST Payable (14% Petrol / 2.5% EV)',
          accountType: 'liability',
          description: 'Output CGST @ 2.5% (EV Concessional Rate)',
          creditAmount: 3690.45,
          createdAt: _fiveDaysAgo,
        ),
        JournalLineEntity(
          id: 'line-011',
          journalEntryId: 'jrn-003',
          accountId: 'acc-2021',
          accountCode: '2021',
          accountName: 'Output SGST Payable (14% Petrol / 2.5% EV)',
          accountType: 'liability',
          description: 'Output SGST @ 2.5% (EV Concessional Rate)',
          creditAmount: 3690.45,
          createdAt: _fiveDaysAgo,
        ),
      ],
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════
  // STATE STORE (IN-MEMORY DEV MODE)
  // ═══════════════════════════════════════════════════════════════════

  late List<AccountEntity> _accounts = List.from(_devAccounts);
  late List<JournalEntryEntity> _journals = List.from(_devJournals);
  int _journalSeq = 4;

  /// Reset in-memory dev state (used for testing isolation)
  void resetDevData() {
    _accounts = List.from(_devAccounts);
    _journals = List.from(_devJournals);
    _journalSeq = 4;
  }

  // ═══════════════════════════════════════════════════════════════════
  // CHART OF ACCOUNTS (COA) OPERATIONS
  // ═══════════════════════════════════════════════════════════════════

  /// Fetch all accounts with optional filtering
  Future<List<AccountEntity>> fetchAccounts({
    String? showroomId,
    String? accountType,
    String? search,
  }) async {
    if (!_isSupabaseLive) {
      await SupabaseService.devLatency();
      return _filterDevAccounts(showroomId: showroomId, accountType: accountType, search: search);
    }
    try {
      var query = SupabaseService.client!.from('chart_of_accounts').select();
      if (accountType != null && accountType.isNotEmpty) {
        query = query.eq('account_type', accountType);
      }
      final response = await query.order('account_code');
      final list = (response as List).map((j) => AccountModel.fromJson(j as Map<String, dynamic>)).toList();
      return _filterDevAccounts(source: list, showroomId: showroomId, accountType: accountType, search: search);
    } catch (e) {
      debugPrint('AccountingManagementService.fetchAccounts error: $e');
      return _filterDevAccounts(showroomId: showroomId, accountType: accountType, search: search);
    }
  }

  List<AccountEntity> _filterDevAccounts({
    List<AccountEntity>? source,
    String? showroomId,
    String? accountType,
    String? search,
  }) {
    var result = List<AccountEntity>.from(source ?? _accounts);
    if (showroomId != null && showroomId.isNotEmpty) {
      // Return accounts specific to showroom OR global corporate accounts (showroomId == null)
      result = result.where((a) => a.showroomId == null || a.showroomId == showroomId).toList();
    }
    if (accountType != null && accountType.isNotEmpty) {
      result = result.where((a) => a.accountType == accountType).toList();
    }
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      result = result.where((a) =>
          a.accountCode.toLowerCase().contains(s) ||
          a.accountName.toLowerCase().contains(s) ||
          a.subType.toLowerCase().contains(s)).toList();
    }
    return result;
  }

  /// Fetch account by ID
  Future<AccountEntity?> fetchAccountById(String id) async {
    return _accounts.cast<AccountEntity?>().firstWhere((a) => a!.id == id, orElse: () => null);
  }

  /// Create a new account
  Future<AccountEntity> createAccount(AccountEntity account) async {
    final newAccount = account.copyWith(
      id: 'acc-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _accounts.add(newAccount);
    return newAccount;
  }

  /// Update existing account
  Future<AccountEntity> updateAccount(AccountEntity account) async {
    final idx = _accounts.indexWhere((a) => a.id == account.id);
    if (idx >= 0) {
      final updated = account.copyWith(updatedAt: DateTime.now());
      _accounts[idx] = updated;
      return updated;
    }
    throw Exception('Account not found: ${account.id}');
  }

  // ═══════════════════════════════════════════════════════════════════
  // JOURNAL ENTRY & GENERAL LEDGER OPERATIONS
  // ═══════════════════════════════════════════════════════════════════

  /// Fetch journal vouchers
  Future<List<JournalEntryEntity>> fetchJournalEntries({
    String? showroomId,
    String? status,
    String? referenceType,
    DateTime? fromDate,
    DateTime? toDate,
    String? search,
  }) async {
    await SupabaseService.devLatency();
    var result = List<JournalEntryEntity>.from(_journals);
    if (showroomId != null && showroomId.isNotEmpty) {
      result = result.where((j) => j.showroomId == showroomId).toList();
    }
    if (status != null && status.isNotEmpty) {
      result = result.where((j) => j.status == status).toList();
    }
    if (referenceType != null && referenceType.isNotEmpty) {
      result = result.where((j) => j.referenceType == referenceType).toList();
    }
    if (fromDate != null) {
      result = result.where((j) => j.entryDate.isAfter(fromDate.subtract(const Duration(days: 1)))).toList();
    }
    if (toDate != null) {
      result = result.where((j) => j.entryDate.isBefore(toDate.add(const Duration(days: 1)))).toList();
    }
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      result = result.where((j) =>
          j.entryNumber.toLowerCase().contains(s) ||
          j.narration.toLowerCase().contains(s) ||
          (j.referenceId?.toLowerCase().contains(s) ?? false)).toList();
    }
    return result;
  }

  /// Fetch a single journal voucher by ID
  Future<JournalEntryEntity?> fetchJournalEntryById(String id) async {
    return _journals.cast<JournalEntryEntity?>().firstWhere((j) => j!.id == id, orElse: () => null);
  }

  /// Create and optionally post a Double-Entry Journal Voucher
  ///
  /// CRITICAL RULE: Enforces that Sum of Debits == Sum of Credits.
  Future<JournalEntryEntity> createJournalEntry(
    JournalEntryEntity entry,
    List<JournalLineEntity> lines, {
    bool autoPost = true,
  }) async {
    if (lines.isEmpty) {
      throw Exception('A journal entry must contain at least two line items (Debit and Credit).');
    }

    final totalDebit = lines.fold<double>(0.0, (sum, l) => sum + l.debitAmount);
    final totalCredit = lines.fold<double>(0.0, (sum, l) => sum + l.creditAmount);

    final difference = (totalDebit - totalCredit).abs();
    if (difference >= 0.01) {
      throw Exception(
        'Double-entry balance violation: Total Debits (₹${totalDebit.toStringAsFixed(2)}) does not equal Total Credits (₹${totalCredit.toStringAsFixed(2)}). Difference: ₹${difference.toStringAsFixed(2)}',
      );
    }

    final entryNumber = entry.entryNumber.isNotEmpty
        ? entry.entryNumber
        : 'JRN-DEV-${_journalSeq.toString().padLeft(5, '0')}';
    _journalSeq++;

    final entryId = 'jrn-${DateTime.now().millisecondsSinceEpoch}';

    final hydratedLines = lines.map((l) {
      final acct = _accounts.cast<AccountEntity?>().firstWhere((a) => a!.id == l.accountId, orElse: () => null);
      return l.copyWith(
        id: l.id.isNotEmpty ? l.id : 'line-${DateTime.now().microsecondsSinceEpoch}',
        journalEntryId: entryId,
        accountCode: acct?.accountCode,
        accountName: acct?.accountName,
        accountType: acct?.accountType,
        createdAt: DateTime.now(),
      );
    }).toList();

    final status = autoPost ? 'posted' : entry.status;

    final newEntry = entry.copyWith(
      id: entryId,
      entryNumber: entryNumber,
      totalDebit: totalDebit,
      totalCredit: totalCredit,
      isBalanced: true,
      status: status,
      postedAt: status == 'posted' ? DateTime.now() : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lines: hydratedLines,
    );

    _journals.insert(0, newEntry);

    // If posted, update current account balances
    if (status == 'posted') {
      _applyPostingBalanceUpdates(hydratedLines);
    }

    return newEntry;
  }

  /// Post a draft journal voucher to General Ledger
  Future<JournalEntryEntity> postJournalEntry(String id) async {
    final idx = _journals.indexWhere((j) => j.id == id);
    if (idx < 0) throw Exception('Journal entry not found: $id');
    final entry = _journals[idx];

    if (entry.status == 'posted') return entry;
    if (entry.status == 'reversed') throw Exception('Cannot post a reversed journal entry.');

    if (!entry.checkBalance) {
      throw Exception('Cannot post an unbalanced journal entry.');
    }

    final posted = entry.copyWith(
      status: 'posted',
      postedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _journals[idx] = posted;
    _applyPostingBalanceUpdates(posted.lines);

    return posted;
  }

  /// Strictly enforce audit-compliant anti-tamper reversal.
  ///
  /// Rule: Zero hard deletion. Reversing generates an inverted opposing voucher.
  Future<JournalEntryEntity> reverseJournalEntry(
    String id, {
    required String reason,
    required String reversedBy,
  }) async {
    final idx = _journals.indexWhere((j) => j.id == id);
    if (idx < 0) throw Exception('Journal entry not found: $id');
    final original = _journals[idx];

    if (original.status != 'posted') {
      throw Exception('Only posted journal entries can be reversed.');
    }

    // 1. Generate paired offsetting reversal lines (Swap Debit and Credit)
    final reversalLines = original.lines.map((line) {
      return line.copyWith(
        id: 'rev-line-${DateTime.now().microsecondsSinceEpoch}',
        debitAmount: line.creditAmount, // Invert
        creditAmount: line.debitAmount, // Invert
        description: 'Reversal: ${line.description ?? original.entryNumber}',
        createdAt: DateTime.now(),
      );
    }).toList();

    // 2. Create the Reversal Journal Voucher
    final reversalNumber = 'REV-${original.entryNumber}';
    final reversalEntry = JournalEntryEntity(
      id: 'jrn-rev-${DateTime.now().millisecondsSinceEpoch}',
      showroomId: original.showroomId,
      entryNumber: reversalNumber,
      entryDate: DateTime.now(),
      referenceType: 'reversal',
      referenceId: original.entryNumber,
      narration: 'Reversal of ${original.entryNumber}. Reason: $reason',
      totalDebit: original.totalCredit,
      totalCredit: original.totalDebit,
      isBalanced: true,
      status: 'posted',
      reversedEntryId: original.id,
      createdBy: reversedBy,
      postedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lines: reversalLines,
      showroomName: original.showroomName,
    );

    // 3. Mark original voucher as 'reversed'
    _journals[idx] = original.copyWith(
      status: 'reversed',
      reversedEntryId: reversalEntry.id,
      updatedAt: DateTime.now(),
    );

    // 4. Insert and post the reversal voucher
    _journals.insert(0, reversalEntry);
    _applyPostingBalanceUpdates(reversalLines);

    return reversalEntry;
  }

  /// Internal balance applicator
  void _applyPostingBalanceUpdates(List<JournalLineEntity> lines) {
    for (final line in lines) {
      final acctIdx = _accounts.indexWhere((a) => a.id == line.accountId);
      if (acctIdx >= 0) {
        final acct = _accounts[acctIdx];
        double delta;
        // Assets & Expenses: Debits increase, Credits decrease
        // Liabilities, Equity, Revenue: Credits increase, Debits decrease
        if (acct.isAsset || acct.isExpense) {
          delta = line.debitAmount - line.creditAmount;
        } else {
          delta = line.creditAmount - line.debitAmount;
        }

        _accounts[acctIdx] = acct.copyWith(
          currentBalance: acct.currentBalance + delta,
          updatedAt: DateTime.now(),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // TRIAL BALANCE GENERATOR
  // ═══════════════════════════════════════════════════════════════════

  /// Compute real-time Trial Balance statement
  Future<Map<String, dynamic>> generateTrialBalance({
    String? showroomId,
    DateTime? asOfDate,
  }) async {
    final accounts = await fetchAccounts(showroomId: showroomId);
    final items = <TrialBalanceItemEntity>[];
    double totalDebit = 0.0;
    double totalCredit = 0.0;

    for (final acct in accounts) {
      double debit = 0.0;
      double credit = 0.0;

      if (acct.isAsset || acct.isExpense) {
        if (acct.currentBalance >= 0) {
          debit = acct.currentBalance;
        } else {
          credit = acct.currentBalance.abs();
        }
      } else {
        if (acct.currentBalance >= 0) {
          credit = acct.currentBalance;
        } else {
          debit = acct.currentBalance.abs();
        }
      }

      totalDebit += debit;
      totalCredit += credit;

      items.add(TrialBalanceItemEntity(
        accountId: acct.id,
        accountCode: acct.accountCode,
        accountName: acct.accountName,
        accountType: acct.accountType,
        debitBalance: debit,
        creditBalance: credit,
      ));
    }

    final isBalanced = (totalDebit - totalCredit).abs() < 0.01;

    return {
      'items': items,
      'totalDebit': totalDebit,
      'totalCredit': totalCredit,
      'difference': (totalDebit - totalCredit).abs(),
      'isBalanced': isBalanced,
      'asOfDate': asOfDate ?? DateTime.now(),
    };
  }
}
