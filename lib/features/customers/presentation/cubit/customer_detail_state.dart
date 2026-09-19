import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/customer_document_entity.dart';
import '../../domain/entities/lead_entity.dart';
import '../../domain/entities/booking_entity.dart';

/// Customer Detail View State
class CustomerDetailState extends Equatable {
  final bool isLoading;
  final String? error;
  final CustomerEntity? customer;
  final List<CustomerDocumentEntity> documents;
  final List<LeadEntity> leads;
  final List<BookingEntity> bookings;

  const CustomerDetailState({
    this.isLoading = false,
    this.error,
    this.customer,
    this.documents = const [],
    this.leads = const [],
    this.bookings = const [],
  });

  CustomerDetailState copyWith({
    bool? isLoading,
    String? error,
    CustomerEntity? customer,
    List<CustomerDocumentEntity>? documents,
    List<LeadEntity>? leads,
    List<BookingEntity>? bookings,
  }) {
    return CustomerDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      customer: customer ?? this.customer,
      documents: documents ?? this.documents,
      leads: leads ?? this.leads,
      bookings: bookings ?? this.bookings,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, customer, documents, leads, bookings];
}
