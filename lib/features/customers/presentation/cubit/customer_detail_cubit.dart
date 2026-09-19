import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/customer_management_service.dart';
import 'customer_detail_state.dart';

/// Customer Detail Cubit
///
/// Loads a single customer profile with their KYC documents,
/// associated leads, and booking history.
class CustomerDetailCubit extends Cubit<CustomerDetailState> {
  final CustomerManagementService _service;

  CustomerDetailCubit({CustomerManagementService? service})
      : _service = service ?? CustomerManagementService.instance,
        super(const CustomerDetailState());

  /// Load customer profile with all related data
  Future<void> loadCustomer(String customerId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final results = await Future.wait([
        _service.fetchCustomerById(customerId),
        _service.fetchCustomerDocuments(customerId),
        _service.fetchLeads(search: null), // Filtered below
        _service.fetchBookings(customerId: customerId),
      ]);

      final customer = results[0] as dynamic;
      final documents = results[1] as dynamic;
      final allLeads = results[2] as dynamic;
      final bookings = results[3] as dynamic;

      // Filter leads for this customer
      final customerLeads = (allLeads as List).where((l) => l.customerId == customerId).toList();

      emit(state.copyWith(
        isLoading: false,
        customer: customer,
        documents: List.from(documents as List),
        leads: List.from(customerLeads),
        bookings: List.from(bookings as List),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Verify a KYC document
  Future<void> verifyDocument(String docId) async {
    try {
      await _service.verifyDocument(docId);
      if (state.customer != null) {
        await loadCustomer(state.customer!.id);
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Reject a KYC document
  Future<void> rejectDocument(String docId, String reason) async {
    try {
      await _service.rejectDocument(docId, reason);
      if (state.customer != null) {
        await loadCustomer(state.customer!.id);
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Update KYC status
  Future<void> updateKycStatus(String status) async {
    if (state.customer == null) return;
    try {
      await _service.updateKycStatus(state.customer!.id, status);
      await loadCustomer(state.customer!.id);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
