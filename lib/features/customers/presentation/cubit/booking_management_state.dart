import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_entity.dart';

/// Booking Management View State
class BookingManagementState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<BookingEntity> bookings;
  final List<BookingEntity> filteredBookings;
  // Filters
  final String? selectedShowroomId;
  final String? selectedStatus;
  final String searchQuery;
  // KPIs
  final int activeBookings;
  final int pendingDelivery;
  final double totalBookingValue;
  final int deliveredThisMonth;
  final int cancelledCount;

  const BookingManagementState({
    this.isLoading = false,
    this.error,
    this.bookings = const [],
    this.filteredBookings = const [],
    this.selectedShowroomId,
    this.selectedStatus,
    this.searchQuery = '',
    this.activeBookings = 0,
    this.pendingDelivery = 0,
    this.totalBookingValue = 0.0,
    this.deliveredThisMonth = 0,
    this.cancelledCount = 0,
  });

  BookingManagementState copyWith({
    bool? isLoading,
    String? error,
    List<BookingEntity>? bookings,
    List<BookingEntity>? filteredBookings,
    String? selectedShowroomId,
    String? selectedStatus,
    String? searchQuery,
    int? activeBookings,
    int? pendingDelivery,
    double? totalBookingValue,
    int? deliveredThisMonth,
    int? cancelledCount,
  }) {
    return BookingManagementState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      bookings: bookings ?? this.bookings,
      filteredBookings: filteredBookings ?? this.filteredBookings,
      selectedShowroomId: selectedShowroomId ?? this.selectedShowroomId,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      activeBookings: activeBookings ?? this.activeBookings,
      pendingDelivery: pendingDelivery ?? this.pendingDelivery,
      totalBookingValue: totalBookingValue ?? this.totalBookingValue,
      deliveredThisMonth: deliveredThisMonth ?? this.deliveredThisMonth,
      cancelledCount: cancelledCount ?? this.cancelledCount,
    );
  }

  @override
  List<Object?> get props => [
        isLoading, error, bookings, filteredBookings,
        selectedShowroomId, selectedStatus, searchQuery,
        activeBookings, pendingDelivery, totalBookingValue, deliveredThisMonth, cancelledCount,
      ];
}
