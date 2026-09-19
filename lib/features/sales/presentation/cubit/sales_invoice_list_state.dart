import 'package:equatable/equatable.dart';
import '../../domain/entities/sales_invoice_entity.dart';

class SalesInvoiceListState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<SalesInvoiceEntity> invoices;
  final List<SalesInvoiceEntity> filteredInvoices;
  final String? selectedShowroomId;
  final String? selectedStatus;
  final String searchQuery;

  // KPI Metrics
  final double totalRevenue;
  final double totalGstCollected;
  final int totalInvoices;
  final int pendingDeliveries;

  const SalesInvoiceListState({
    this.isLoading = false,
    this.error,
    this.invoices = const [],
    this.filteredInvoices = const [],
    this.selectedShowroomId,
    this.selectedStatus,
    this.searchQuery = '',
    this.totalRevenue = 0.0,
    this.totalGstCollected = 0.0,
    this.totalInvoices = 0,
    this.pendingDeliveries = 0,
  });

  SalesInvoiceListState copyWith({
    bool? isLoading,
    String? error,
    List<SalesInvoiceEntity>? invoices,
    List<SalesInvoiceEntity>? filteredInvoices,
    String? selectedShowroomId,
    String? selectedStatus,
    String? searchQuery,
    double? totalRevenue,
    double? totalGstCollected,
    int? totalInvoices,
    int? pendingDeliveries,
  }) {
    return SalesInvoiceListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      invoices: invoices ?? this.invoices,
      filteredInvoices: filteredInvoices ?? this.filteredInvoices,
      selectedShowroomId: selectedShowroomId ?? this.selectedShowroomId,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalGstCollected: totalGstCollected ?? this.totalGstCollected,
      totalInvoices: totalInvoices ?? this.totalInvoices,
      pendingDeliveries: pendingDeliveries ?? this.pendingDeliveries,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        invoices,
        filteredInvoices,
        selectedShowroomId,
        selectedStatus,
        searchQuery,
        totalRevenue,
        totalGstCollected,
        totalInvoices,
        pendingDeliveries,
      ];
}
