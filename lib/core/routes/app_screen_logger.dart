import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Screen and Controller information model
class ScreenInfo {
  final String screenName;
  final String controllerName;
  final String? description;

  const ScreenInfo({
    required this.screenName,
    required this.controllerName,
    this.description,
  });
}

/// Centralized Screen & Controller Logger for MYBIKE ERP
/// Automatically prints Screen Name and Controller (Cubit/Service) Name to console.
class AppScreenLogger {
  AppScreenLogger._();

  static String? _lastLoggedRoute;

  /// Centralized mapping of routes & paths to Screen and Controller
  static final Map<String, ScreenInfo> _registry = {
    // ─── Authentication & Onboarding ───
    '/': const ScreenInfo(
      screenName: 'SplashScreen',
      controllerName: 'AuthCubit',
      description: 'App Launch & Session Check',
    ),
    '/login': const ScreenInfo(
      screenName: 'LoginScreen',
      controllerName: 'AuthCubit',
      description: 'User Authentication Screen',
    ),
    '/showroom-selection': const ScreenInfo(
      screenName: 'ShowroomSelectionScreen',
      controllerName: 'AuthCubit',
      description: 'Showroom Branch Switcher',
    ),

    // ─── Dashboard ───
    '/dashboard': const ScreenInfo(
      screenName: 'DashboardScreen',
      controllerName: 'DashboardCubit',
      description: 'Executive Metrics & Sales Overview',
    ),

    // ─── Showroom Management ───
    '/showrooms': const ScreenInfo(
      screenName: 'ShowroomListScreen',
      controllerName: 'ShowroomCubit',
      description: 'Showroom Branches List',
    ),
    '/showrooms/create': const ScreenInfo(
      screenName: 'ShowroomFormScreen',
      controllerName: 'ShowroomFormCubit',
      description: 'Create / Edit Showroom Branch',
    ),
    '/showrooms/:showroomId': const ScreenInfo(
      screenName: 'ShowroomDetailScreen',
      controllerName: 'ShowroomDetailCubit',
      description: 'Showroom Branch Profile',
    ),

    // ─── User & Role Management ───
    '/users': const ScreenInfo(
      screenName: 'UserListScreen',
      controllerName: 'UserManagementCubit',
      description: 'Staff & User Management Directory',
    ),
    '/users/create': const ScreenInfo(
      screenName: 'UserFormScreen',
      controllerName: 'UserFormCubit',
      description: 'Create / Edit Staff User Profile',
    ),
    '/users/:userId': const ScreenInfo(
      screenName: 'UserDetailScreen',
      controllerName: 'UserManagementService / UserDetailCubit',
      description: 'Staff User Profile View',
    ),
    '/roles': const ScreenInfo(
      screenName: 'RoleListScreen',
      controllerName: 'RoleManagementCubit',
      description: 'RBAC Roles & Permissions Management',
    ),

    // ─── Vehicle Catalog ───
    '/vehicles': const ScreenInfo(
      screenName: 'VehicleListScreen',
      controllerName: 'VehicleCatalogCubit',
      description: 'Vehicle Master Catalog & Models',
    ),
    '/vehicles/create': const ScreenInfo(
      screenName: 'VehicleFormScreen',
      controllerName: 'VehicleFormCubit',
      description: 'Create / Edit Vehicle Model Specification',
    ),
    '/vehicles/:vehicleId': const ScreenInfo(
      screenName: 'VehicleDetailScreen',
      controllerName: 'VehicleDetailCubit',
      description: 'Vehicle Model & Variants Details',
    ),
    '/vehicles/:vehicleId/edit': const ScreenInfo(
      screenName: 'VehicleFormScreen',
      controllerName: 'VehicleFormCubit',
      description: 'Edit Vehicle Model Specification',
    ),

    // ─── Inventory & Stock Management ───
    '/inventory': const ScreenInfo(
      screenName: 'InventoryListScreen',
      controllerName: 'VehicleInventoryCubit',
      description: 'Serialized Vehicle Inventory Stock List',
    ),
    '/inventory/inward': const ScreenInfo(
      screenName: 'StockInwardScreen',
      controllerName: 'StockInwardCubit',
      description: 'Factory Goods Receipt Note (GRN) Inward',
    ),
    '/inventory/transfer': const ScreenInfo(
      screenName: 'StockTransferScreen',
      controllerName: 'StockTransferCubit',
      description: 'Inter-Showroom Stock Transfer Dispatch/Receive',
    ),
    '/inventory/:vehicleId': const ScreenInfo(
      screenName: 'VehicleInventoryDetailScreen',
      controllerName: 'VehicleInventoryDetailCubit',
      description: 'Serialized Vehicle Unit (VIN) Dossier',
    ),

    // ─── Customer & CRM ───
    '/customers': const ScreenInfo(
      screenName: 'CustomerListScreen',
      controllerName: 'CustomerListCubit',
      description: 'Customer Master Directory',
    ),
    '/customers/create': const ScreenInfo(
      screenName: 'CustomerFormScreen',
      controllerName: 'CustomerFormCubit',
      description: 'Create / Edit Customer Profile',
    ),
    '/customers/:customerId': const ScreenInfo(
      screenName: 'CustomerDetailScreen',
      controllerName: 'CustomerDetailCubit',
      description: 'Customer 360 Profile & Ledger',
    ),
    '/leads': const ScreenInfo(
      screenName: 'LeadPipelineScreen',
      controllerName: 'LeadPipelineCubit',
      description: 'CRM Lead Kanban Pipeline',
    ),
    '/bookings': const ScreenInfo(
      screenName: 'BookingListScreen',
      controllerName: 'BookingListCubit',
      description: 'Customer Booking Orders & Vehicle Allocation',
    ),

    // ─── Sales & Invoicing ───
    '/sales': const ScreenInfo(
      screenName: 'SalesInvoiceListScreen',
      controllerName: 'SalesInvoiceListCubit',
      description: 'GST Tax Invoices & Sales Orders',
    ),
    '/sales/create': const ScreenInfo(
      screenName: 'BookingWizardScreen',
      controllerName: 'BookingWizardCubit',
      description: 'New Vehicle Sales & Invoice Wizard',
    ),
    '/sales/:invoiceId': const ScreenInfo(
      screenName: 'SalesInvoiceDetailScreen',
      controllerName: 'SalesInvoiceDetailCubit',
      description: 'Tax Invoice Dossier & Document Viewer',
    ),
    '/sales/:invoiceId/delivery': const ScreenInfo(
      screenName: 'DeliveryChallanScreen',
      controllerName: 'DeliveryChallanCubit',
      description: 'Vehicle Delivery Challan & Gate Pass',
    ),

    // ─── Accounting Foundation ───
    '/accounting': const ScreenInfo(
      screenName: 'ChartOfAccountsScreen',
      controllerName: 'ChartOfAccountsCubit',
      description: 'General Ledger Chart of Accounts',
    ),
    '/accounting/chart-of-accounts': const ScreenInfo(
      screenName: 'ChartOfAccountsScreen',
      controllerName: 'ChartOfAccountsCubit',
      description: 'Chart of Accounts Tree View',
    ),
    '/accounting/journals': const ScreenInfo(
      screenName: 'JournalEntryListScreen',
      controllerName: 'JournalEntryListCubit',
      description: 'Double-Entry Journal Entries Register',
    ),
    '/accounting/journals/create': const ScreenInfo(
      screenName: 'JournalEntryFormScreen',
      controllerName: 'JournalEntryFormCubit',
      description: 'New Double-Entry Journal Voucher',
    ),
    '/accounting/trial-balance': const ScreenInfo(
      screenName: 'TrialBalanceScreen',
      controllerName: 'TrialBalanceCubit',
      description: 'Trial Balance & Financial Report',
    ),

    // ─── Finance Module ───
    '/finance': const ScreenInfo(
      screenName: 'FinanceDashboardScreen',
      controllerName: 'FinanceDashboardCubit',
      description: 'Cash Flow & Accounts Receivable/Payable',
    ),
    '/finance/vouchers': const ScreenInfo(
      screenName: 'VoucherListScreen',
      controllerName: 'VoucherListCubit',
      description: 'Payment, Receipt & Contra Vouchers',
    ),
    '/finance/vouchers/create': const ScreenInfo(
      screenName: 'VoucherFormScreen',
      controllerName: 'VoucherFormCubit',
      description: 'Record Payment / Receipt Voucher',
    ),
    '/finance/outstandings': const ScreenInfo(
      screenName: 'OutstandingLedgerScreen',
      controllerName: 'OutstandingLedgerCubit',
      description: 'Aging Analysis & Customer Outstandings',
    ),
    '/finance/payments': const ScreenInfo(
      screenName: 'VoucherListScreen (Payments)',
      controllerName: 'VoucherListCubit',
      description: 'Payment Vouchers Register',
    ),
    '/finance/receipts': const ScreenInfo(
      screenName: 'VoucherListScreen (Receipts)',
      controllerName: 'VoucherListCubit',
      description: 'Receipt Vouchers Register',
    ),
    '/finance/expenses': const ScreenInfo(
      screenName: 'VoucherListScreen (Expenses)',
      controllerName: 'VoucherListCubit',
      description: 'Expense Vouchers Register',
    ),

    // ─── GST & Tax Module ───
    '/gst': const ScreenInfo(
      screenName: 'GstDashboardScreen',
      controllerName: 'GstDashboardCubit',
      description: 'GST Compliance & Tax Summary',
    ),
    '/gst/rates': const ScreenInfo(
      screenName: 'GstRateConfigScreen',
      controllerName: 'GstRateConfigCubit',
      description: 'HSN/SAC Code & Tax Rate Configuration',
    ),
    '/gst/gstr-1': const ScreenInfo(
      screenName: 'Gstr1ReportScreen',
      controllerName: 'Gstr1ReportCubit',
      description: 'GSTR-1 Outward Supplies Return',
    ),
    '/gst/gstr-3b': const ScreenInfo(
      screenName: 'Gstr3bReportScreen',
      controllerName: 'Gstr3bReportCubit',
      description: 'GSTR-3B Monthly Return Filing',
    ),

    // ─── Reports & DMS & System ───
    '/reports': const ScreenInfo(
      screenName: 'ReportsHubScreen',
      controllerName: 'ReportsHubCubit',
      description: 'Analytics & Management Reports Hub',
    ),
    '/reports/:reportType': const ScreenInfo(
      screenName: 'ReportViewerScreen',
      controllerName: 'ReportViewerCubit',
      description: 'Interactive Report Data & Export',
    ),
    '/document/preview': const ScreenInfo(
      screenName: 'DocumentPreviewScreen',
      controllerName: 'DocumentExportService',
      description: 'PDF Document Preview & Print Service',
    ),
    '/notifications': const ScreenInfo(
      screenName: 'NotificationCenterScreen',
      controllerName: 'NotificationCubit',
      description: 'Activity & Alert Notifications',
    ),
    '/documents': const ScreenInfo(
      screenName: 'DocumentDmsHubScreen',
      controllerName: 'DocumentDmsCubit',
      description: 'Document Management (DMS) Repository',
    ),
    '/audit-logs': const ScreenInfo(
      screenName: 'AuditTrailScreen',
      controllerName: 'AuditTrailCubit',
      description: 'System Audit Trail & Security Logs',
    ),
    '/approvals': const ScreenInfo(
      screenName: 'ApprovalHubScreen',
      controllerName: 'ApprovalHubCubit',
      description: 'Multi-Level Approval Workflow Hub',
    ),
  };

  /// Match a concrete route path (e.g. '/inventory/c2537bc2-...') to a registered ScreenInfo
  static ScreenInfo? resolveScreenInfo(String path) {
    // 1. Direct match
    if (_registry.containsKey(path)) {
      return _registry[path];
    }

    // 2. Clean query params
    final cleanPath = path.split('?').first;
    if (_registry.containsKey(cleanPath)) {
      return _registry[cleanPath];
    }

    // 3. Match parameterized routes
    for (final entry in _registry.entries) {
      final pattern = entry.key;
      if (!pattern.contains(':')) continue;

      final regexPattern = '^' +
          pattern.replaceAllMapped(RegExp(r':([a-zA-Z0-9_]+)'), (m) => r'[^/]+') +
          r'$';
      if (RegExp(regexPattern).hasMatch(cleanPath)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Print structured information to the console
  static void logScreen({
    required String screenName,
    required String controllerName,
    String? route,
    String? description,
  }) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final border = '═' * 66;

    debugPrint('''
╔$border╗
║ 📱 [SCREEN OPENED]                        ⏰ $timestamp
║ 🔹 Screen:     $screenName
║ 🎮 Controller: $controllerName
${route != null ? '║ 📍 Route:      $route\n' : ''}${description != null ? '║ ℹ️  Info:       $description\n' : ''}╚$border╝''');
  }

  /// Log route navigation based on path
  static void logRoute(String path) {
    if (_lastLoggedRoute == path) return;
    _lastLoggedRoute = path;

    final info = resolveScreenInfo(path);
    if (info != null) {
      logScreen(
        screenName: info.screenName,
        controllerName: info.controllerName,
        route: path,
        description: info.description,
      );
    } else {
      logScreen(
        screenName: 'UnknownScreen ($path)',
        controllerName: 'UnknownController',
        route: path,
      );
    }
  }
}

/// NavigatorObserver that monitors all screen transitions and prints screen & controller
class AppScreenNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logRoute(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _logRoute(previousRoute);
    }
  }

  void _logRoute(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      AppScreenLogger.logRoute(name);
    }
  }
}
