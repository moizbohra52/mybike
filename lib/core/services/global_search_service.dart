import 'package:flutter/material.dart';
import '../../core/routes/route_names.dart';
import '../../core/services/approval_workflow_service.dart';
import '../../core/services/document_management_service.dart';
import '../../core/services/finance_management_service.dart';
import '../../features/approvals/domain/entities/approval_filter_criteria.dart';
import '../../features/documents/domain/entities/document_filter_criteria.dart';

enum SearchCategory {
  vehicles,
  customers,
  salesAndBookings,
  inventory,
  finance,
  documents,
  approvals,
  system,
}

extension SearchCategoryExtension on SearchCategory {
  String get label {
    switch (this) {
      case SearchCategory.vehicles:
        return 'Vehicles & Models';
      case SearchCategory.customers:
        return 'Customers & Leads';
      case SearchCategory.salesAndBookings:
        return 'Sales & Bookings';
      case SearchCategory.inventory:
        return 'Inventory & Stock';
      case SearchCategory.finance:
        return 'Finance & Vouchers';
      case SearchCategory.documents:
        return 'Document DMS';
      case SearchCategory.approvals:
        return 'Approval Requests';
      case SearchCategory.system:
        return 'System & Settings';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchCategory.vehicles:
        return Icons.two_wheeler_outlined;
      case SearchCategory.customers:
        return Icons.people_outline_rounded;
      case SearchCategory.salesAndBookings:
        return Icons.receipt_long_outlined;
      case SearchCategory.inventory:
        return Icons.inventory_2_outlined;
      case SearchCategory.finance:
        return Icons.account_balance_wallet_outlined;
      case SearchCategory.documents:
        return Icons.folder_shared_outlined;
      case SearchCategory.approvals:
        return Icons.verified_user_outlined;
      case SearchCategory.system:
        return Icons.settings_outlined;
    }
  }
}

class GlobalSearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final SearchCategory category;
  final String? badgeText;
  final Color? badgeColor;
  final String routePath;
  final String? routeName;
  final Map<String, dynamic>? routeParams;

  const GlobalSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.badgeText,
    this.badgeColor,
    required this.routePath,
    this.routeName,
    this.routeParams,
  });
}

/// Cross-Entity Dealership Global Search Service (Command Palette)
class GlobalSearchService {
  static final GlobalSearchService instance = GlobalSearchService._internal();

  factory GlobalSearchService() => instance;

  GlobalSearchService._internal();

  final List<String> _recentSearches = [];
  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  void addRecentSearch(String query) {
    final clean = query.trim();
    if (clean.isEmpty) return;
    _recentSearches.remove(clean);
    _recentSearches.insert(0, clean);
    if (_recentSearches.length > 8) {
      _recentSearches.removeLast();
    }
  }

  void clearRecentSearches() {
    _recentSearches.clear();
  }

  Future<List<GlobalSearchResultItem>> search(String query, {String? showroomId}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final List<GlobalSearchResultItem> results = [];

    // 1. Search Approvals (Phase 21)
    try {
      final approvals = await ApprovalWorkflowService.instance.fetchRequests(
        const ApprovalFilterCriteria(),
      );
      for (final app in approvals) {
        if (app.title.toLowerCase().contains(q) ||
            app.id.toLowerCase().contains(q) ||
            (app.recordReference?.toLowerCase().contains(q) ?? false) ||
            (app.requesterName?.toLowerCase().contains(q) ?? false)) {
          results.add(GlobalSearchResultItem(
            id: app.id,
            title: app.title,
            subtitle: 'Ref: ${app.recordReference ?? app.id} • ${app.requesterName ?? "Staff"} (${app.status.toUpperCase()})',
            category: SearchCategory.approvals,
            badgeText: app.transactionType.toUpperCase(),
            badgeColor: app.isPending ? Colors.orange : (app.isApproved ? Colors.green : Colors.red),
            routePath: '/approvals',
            routeName: RouteNames.approvals,
          ));
        }
      }
    } catch (_) {}

    // 2. Search Documents (Phase 19)
    try {
      final documents = await DocumentManagementService.instance.fetchDocuments(
        const DocumentFilterCriteria(),
      );
      for (final doc in documents) {
        if (doc.fileName.toLowerCase().contains(q) ||
            doc.documentType.toLowerCase().contains(q) ||
            doc.entityId.toLowerCase().contains(q) ||
            (doc.documentNumber?.toLowerCase().contains(q) ?? false)) {
          results.add(GlobalSearchResultItem(
            id: doc.id,
            title: doc.fileName,
            subtitle: '${doc.documentType.toUpperCase()} • Entity: ${doc.entityId} • ${doc.verificationStatus.toUpperCase()}',
            category: SearchCategory.documents,
            badgeText: doc.documentType.toUpperCase(),
            badgeColor: Colors.blueGrey,
            routePath: '/documents',
            routeName: RouteNames.documents,
          ));
        }
      }
    } catch (_) {}

    // 3. Search Finance Vouchers (Phase 13)
    try {
      final vouchers = await FinanceManagementService.instance.fetchVouchers();
      for (final v in vouchers) {
        if (v.voucherNumber.toLowerCase().contains(q) ||
            v.partyName.toLowerCase().contains(q) ||
            v.voucherType.toLowerCase().contains(q) ||
            v.narration.toLowerCase().contains(q)) {
          results.add(GlobalSearchResultItem(
            id: v.id,
            title: '${v.voucherNumber} — ${v.partyName}',
            subtitle: '${v.voucherType.toUpperCase()} • ₹${v.amount.toStringAsFixed(2)} • ${v.narration}',
            category: SearchCategory.finance,
            badgeText: v.voucherType.toUpperCase(),
            badgeColor: Colors.teal,
            routePath: '/finance/vouchers',
            routeName: RouteNames.vouchers,
          ));
        }
      }
    } catch (_) {}

    // 4. Seeded Vehicle & Customer quick hits
    _addStaticOrDynamicMatches(results, q);

    return results;
  }

  void _addStaticOrDynamicMatches(List<GlobalSearchResultItem> results, String q) {
    // Realistic Dealership Inventory, Vehicles, Customers & Navigation
    final staticCatalog = [
      GlobalSearchResultItem(
        id: 'veh-activa-6g',
        title: 'Honda Activa 6G Premium',
        subtitle: '109.51 cc • Rebel Red Metallic • On-road ₹88,400',
        category: SearchCategory.vehicles,
        badgeText: 'SCOOTER',
        badgeColor: Colors.indigo,
        routePath: '/vehicles',
        routeName: RouteNames.vehicles,
      ),
      GlobalSearchResultItem(
        id: 'veh-shine-125',
        title: 'Honda CB Shine 125 Disc',
        subtitle: '123.94 cc • Geny Grey Metallic • On-road ₹94,200',
        category: SearchCategory.vehicles,
        badgeText: 'COMMUTER',
        badgeColor: Colors.indigo,
        routePath: '/vehicles',
        routeName: RouteNames.vehicles,
      ),
      GlobalSearchResultItem(
        id: 'veh-jupiter-110',
        title: 'TVS Jupiter 110 ZX SmartXonnect',
        subtitle: '109.7 cc • Matte Black • On-road ₹92,000',
        category: SearchCategory.vehicles,
        badgeText: 'SCOOTER',
        badgeColor: Colors.indigo,
        routePath: '/vehicles',
        routeName: RouteNames.vehicles,
      ),
      GlobalSearchResultItem(
        id: 'cust-amit-sharma',
        title: 'Amit Sharma',
        subtitle: '+91 98230 45678 • Pune Downtown • 2 Active Bookings',
        category: SearchCategory.customers,
        badgeText: 'CUSTOMER',
        badgeColor: Colors.blue,
        routePath: '/customers',
        routeName: RouteNames.customers,
      ),
      GlobalSearchResultItem(
        id: 'cust-priya-patel',
        title: 'Priya Patel',
        subtitle: '+91 97123 88990 • Ahmedabad • Invoiced (Activa 6G)',
        category: SearchCategory.customers,
        badgeText: 'CUSTOMER',
        badgeColor: Colors.blue,
        routePath: '/customers',
        routeName: RouteNames.customers,
      ),
      GlobalSearchResultItem(
        id: 'inv-part-oil-filter',
        title: 'Genuine Engine Oil Filter - 110cc',
        subtitle: 'SKU: HON-OF-110 • Current Stock: 84 Units • Workshop Bay A',
        category: SearchCategory.inventory,
        badgeText: 'SPARE PART',
        badgeColor: Colors.deepOrange,
        routePath: '/inventory',
        routeName: RouteNames.inventory,
      ),
      GlobalSearchResultItem(
        id: 'inv-part-brake-pad',
        title: 'Front Disc Brake Pad Set (K-Series)',
        subtitle: 'SKU: BRK-PAD-DSC • Current Stock: 16 Units (Low Stock)',
        category: SearchCategory.inventory,
        badgeText: 'SPARE PART',
        badgeColor: Colors.deepOrange,
        routePath: '/inventory',
        routeName: RouteNames.inventory,
      ),
      GlobalSearchResultItem(
        id: 'nav-audit-trail',
        title: 'Enterprise Audit Trail & Compliance Log',
        subtitle: 'View system mutations, deleted entries, and compliance diffs',
        category: SearchCategory.system,
        badgeText: 'SECURITY',
        badgeColor: Colors.purple,
        routePath: '/audit-logs',
        routeName: RouteNames.auditLogs,
      ),
      GlobalSearchResultItem(
        id: 'nav-gst-dashboard',
        title: 'GST & Tax Dashboard (GSTR-1, GSTR-3B)',
        subtitle: 'Direct GST tax calculation and return filing summary',
        category: SearchCategory.finance,
        badgeText: 'GST TAX',
        badgeColor: Colors.teal,
        routePath: '/gst',
        routeName: RouteNames.gstDashboard,
      ),
    ];

    for (final item in staticCatalog) {
      if (item.title.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q) ||
          (item.badgeText?.toLowerCase().contains(q) ?? false)) {
        results.add(item);
      }
    }
  }
}
