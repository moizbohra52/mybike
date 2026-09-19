import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/customer_management_service.dart';
import '../../domain/entities/booking_entity.dart';
import 'booking_management_state.dart';

/// Booking Management Cubit
///
/// Manages the booking list view with financial KPIs,
/// status filtering, and delivery tracking.
class BookingManagementCubit extends Cubit<BookingManagementState> {
  final CustomerManagementService _service;

  BookingManagementCubit({CustomerManagementService? service})
      : _service = service ?? CustomerManagementService.instance,
        super(const BookingManagementState());

  /// Load all bookings
  Future<void> loadBookings() async {
    emit(state.copyWith(isLoading: true));
    try {
      final bookings = await _service.fetchBookings();
      final kpis = _computeKpis(bookings);
      emit(state.copyWith(
        isLoading: false,
        bookings: bookings,
        filteredBookings: bookings,
        activeBookings: kpis['active'] as int,
        pendingDelivery: kpis['pendingDelivery'] as int,
        totalBookingValue: kpis['totalValue'] as double,
        deliveredThisMonth: kpis['deliveredMonth'] as int,
        cancelledCount: kpis['cancelled'] as int,
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

    var filtered = List<BookingEntity>.from(state.bookings);

    if (newShowroom != null && newShowroom.isNotEmpty) {
      filtered = filtered.where((b) => b.showroomId == newShowroom).toList();
    }
    if (newStatus != null && newStatus.isNotEmpty) {
      filtered = filtered.where((b) => b.status == newStatus).toList();
    }
    if (newSearch.isNotEmpty) {
      final s = newSearch.toLowerCase();
      filtered = filtered.where((b) =>
          b.bookingNumber.toLowerCase().contains(s) ||
          (b.customerName?.toLowerCase().contains(s) ?? false)).toList();
    }

    emit(state.copyWith(
      filteredBookings: filtered,
      selectedShowroomId: showroomId,
      selectedStatus: status,
      searchQuery: searchQuery,
    ));
  }

  /// Clear all filters
  void clearFilters() {
    emit(state.copyWith(
      filteredBookings: state.bookings,
      selectedShowroomId: '',
      selectedStatus: '',
      searchQuery: '',
    ));
  }

  /// Search bookings
  void search(String query) {
    applyFilters(searchQuery: query);
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      await _service.cancelBooking(bookingId, reason);
      await loadBookings();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Map<String, dynamic> _computeKpis(List<BookingEntity> bookings) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final active = bookings.where((b) => b.isActive && !b.isDelivered).toList();
    final pendingDelivery = bookings.where((b) =>
        b.isActive && !b.isDelivered && (b.isAllocated || b.isReadyForDelivery || b.isConfirmed)).toList();
    final totalValue = active.fold<double>(0.0, (sum, b) => sum + b.onRoadPrice);
    final deliveredMonth = bookings.where((b) =>
        b.isDelivered && b.actualDeliveryDate != null && b.actualDeliveryDate!.isAfter(monthStart)).length;
    final cancelled = bookings.where((b) => b.isCancelled).length;

    return {
      'active': active.length,
      'pendingDelivery': pendingDelivery.length,
      'totalValue': totalValue,
      'deliveredMonth': deliveredMonth,
      'cancelled': cancelled,
    };
  }
}
