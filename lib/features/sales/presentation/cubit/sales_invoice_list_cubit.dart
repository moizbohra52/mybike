import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/sales_management_service.dart';
import '../../domain/entities/sales_invoice_entity.dart';
import 'sales_invoice_list_state.dart';

/// Sales Invoice List Cubit
///
/// Manages GST sales invoices, computed financial KPIs, filtering, and search.
class SalesInvoiceListCubit extends Cubit<SalesInvoiceListState> {
  final SalesManagementService _service;

  SalesInvoiceListCubit({SalesManagementService? service})
      : _service = service ?? SalesManagementService.instance,
        super(const SalesInvoiceListState());

  /// Load all invoices
  Future<void> loadInvoices() async {
    emit(state.copyWith(isLoading: true));
    try {
      final invoices = await _service.fetchInvoices();
      final kpis = _computeKpis(invoices);
      emit(state.copyWith(
        isLoading: false,
        invoices: invoices,
        filteredInvoices: invoices,
        totalRevenue: kpis['totalRevenue'] as double,
        totalGstCollected: kpis['totalGst'] as double,
        totalInvoices: kpis['totalCount'] as int,
        pendingDeliveries: kpis['pendingDeliveries'] as int,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Apply filters
  void applyFilters({
    String? showroomId,
    String? status,
    String? searchQuery,
  }) {
    final newShowroom = showroomId ?? state.selectedShowroomId;
    final newStatus = status ?? state.selectedStatus;
    final newSearch = searchQuery ?? state.searchQuery;

    var filtered = List<SalesInvoiceEntity>.from(state.invoices);

    if (newShowroom != null && newShowroom.isNotEmpty) {
      filtered = filtered.where((i) => i.showroomId == newShowroom).toList();
    }
    if (newStatus != null && newStatus.isNotEmpty) {
      filtered = filtered.where((i) => i.status == newStatus).toList();
    }
    if (newSearch.isNotEmpty) {
      final s = newSearch.toLowerCase();
      filtered = filtered.where((i) =>
          i.invoiceNumber.toLowerCase().contains(s) ||
          i.vin.toLowerCase().contains(s) ||
          (i.modelName?.toLowerCase().contains(s) ?? false) ||
          (i.variantName?.toLowerCase().contains(s) ?? false) ||
          (i.customerName?.toLowerCase().contains(s) ?? false) ||
          (i.customerMobile?.contains(s) ?? false)).toList();
    }

    emit(state.copyWith(
      filteredInvoices: filtered,
      selectedShowroomId: showroomId,
      selectedStatus: status,
      searchQuery: searchQuery,
    ));
  }

  /// Search
  void search(String query) {
    applyFilters(searchQuery: query);
  }

  /// Clear filters
  void clearFilters() {
    emit(state.copyWith(
      filteredInvoices: state.invoices,
      selectedShowroomId: '',
      selectedStatus: '',
      searchQuery: '',
    ));
  }

  Map<String, dynamic> _computeKpis(List<SalesInvoiceEntity> list) {
    final revenue = list.fold<double>(0.0, (sum, i) => sum + i.totalOnRoadPrice);
    final totalGst = list.fold<double>(0.0, (sum, i) => sum + i.totalGst);
    final pendingDeliveries = list.where((i) => i.isIssued && !i.isDelivered).length;

    return {
      'totalRevenue': revenue,
      'totalGst': totalGst,
      'totalCount': list.length,
      'pendingDeliveries': pendingDeliveries,
    };
  }
}
