import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/customer_management_service.dart';
import '../../domain/entities/customer_entity.dart';
import 'customer_list_state.dart';

/// Customer List Cubit
///
/// Manages the customer list view with KPI computation,
/// search, and multi-filter support.
class CustomerListCubit extends Cubit<CustomerListState> {
  final CustomerManagementService _service;

  CustomerListCubit({CustomerManagementService? service})
      : _service = service ?? CustomerManagementService.instance,
        super(const CustomerListState());

  /// Load all customers
  Future<void> loadCustomers() async {
    emit(state.copyWith(isLoading: true));
    try {
      final customers = await _service.fetchCustomers();
      final kpis = _computeKpis(customers);
      emit(state.copyWith(
        isLoading: false,
        customers: customers,
        filteredCustomers: customers,
        totalCustomers: kpis['total'],
        kycVerified: kpis['verified'],
        kycPending: kpis['pending'],
        newThisMonth: kpis['newThisMonth'],
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Apply filters to the customer list
  void applyFilters({
    String? showroomId,
    String? kycStatus,
    String? customerType,
    String? searchQuery,
  }) {
    final newShowroom = showroomId ?? state.selectedShowroomId;
    final newKyc = kycStatus ?? state.selectedKycStatus;
    final newType = customerType ?? state.selectedCustomerType;
    final newSearch = searchQuery ?? state.searchQuery;

    var filtered = List<CustomerEntity>.from(state.customers);

    if (newShowroom != null && newShowroom.isNotEmpty) {
      filtered = filtered.where((c) => c.showroomId == newShowroom).toList();
    }
    if (newKyc != null && newKyc.isNotEmpty) {
      filtered = filtered.where((c) => c.kycStatus == newKyc).toList();
    }
    if (newType != null && newType.isNotEmpty) {
      filtered = filtered.where((c) => c.customerType == newType).toList();
    }
    if (newSearch.isNotEmpty) {
      final s = newSearch.toLowerCase();
      filtered = filtered.where((c) =>
          c.fullName.toLowerCase().contains(s) ||
          c.mobilePrimary.contains(s) ||
          c.customerNumber.toLowerCase().contains(s) ||
          (c.email?.toLowerCase().contains(s) ?? false)).toList();
    }

    emit(state.copyWith(
      filteredCustomers: filtered,
      selectedShowroomId: showroomId,
      selectedKycStatus: kycStatus,
      selectedCustomerType: customerType,
      searchQuery: searchQuery,
    ));
  }

  /// Clear all filters
  void clearFilters() {
    emit(state.copyWith(
      filteredCustomers: state.customers,
      selectedShowroomId: '',
      selectedKycStatus: '',
      selectedCustomerType: '',
      searchQuery: '',
    ));
  }

  /// Search customers by name/mobile/number
  void search(String query) {
    applyFilters(searchQuery: query);
  }

  Map<String, int> _computeKpis(List<CustomerEntity> customers) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    return {
      'total': customers.length,
      'verified': customers.where((c) => c.isKycVerified).length,
      'pending': customers.where((c) => c.isKycPending || c.isKycPartial).length,
      'newThisMonth': customers.where((c) => c.createdAt.isAfter(monthStart)).length,
    };
  }
}
