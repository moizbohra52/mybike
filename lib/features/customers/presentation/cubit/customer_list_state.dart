import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';

/// Customer List View State
class CustomerListState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<CustomerEntity> customers;
  final List<CustomerEntity> filteredCustomers;
  // Filters
  final String? selectedShowroomId;
  final String? selectedKycStatus;
  final String? selectedCustomerType;
  final String searchQuery;
  // KPIs
  final int totalCustomers;
  final int kycVerified;
  final int kycPending;
  final int newThisMonth;

  const CustomerListState({
    this.isLoading = false,
    this.error,
    this.customers = const [],
    this.filteredCustomers = const [],
    this.selectedShowroomId,
    this.selectedKycStatus,
    this.selectedCustomerType,
    this.searchQuery = '',
    this.totalCustomers = 0,
    this.kycVerified = 0,
    this.kycPending = 0,
    this.newThisMonth = 0,
  });

  CustomerListState copyWith({
    bool? isLoading,
    String? error,
    List<CustomerEntity>? customers,
    List<CustomerEntity>? filteredCustomers,
    String? selectedShowroomId,
    String? selectedKycStatus,
    String? selectedCustomerType,
    String? searchQuery,
    int? totalCustomers,
    int? kycVerified,
    int? kycPending,
    int? newThisMonth,
  }) {
    return CustomerListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      selectedShowroomId: selectedShowroomId ?? this.selectedShowroomId,
      selectedKycStatus: selectedKycStatus ?? this.selectedKycStatus,
      selectedCustomerType: selectedCustomerType ?? this.selectedCustomerType,
      searchQuery: searchQuery ?? this.searchQuery,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      kycVerified: kycVerified ?? this.kycVerified,
      kycPending: kycPending ?? this.kycPending,
      newThisMonth: newThisMonth ?? this.newThisMonth,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        customers,
        filteredCustomers,
        selectedShowroomId,
        selectedKycStatus,
        selectedCustomerType,
        searchQuery,
        totalCustomers,
        kycVerified,
        kycPending,
        newThisMonth,
      ];
}
