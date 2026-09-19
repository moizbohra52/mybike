import '../../domain/entities/booking_entity.dart';

/// Booking Data Model — Supabase JSON ↔ Entity mapper
class BookingModel {
  const BookingModel._();

  static BookingEntity fromJson(Map<String, dynamic> json) {
    return BookingEntity(
      id: json['id'] as String,
      showroomId: json['showroom_id'] as String,
      customerId: json['customer_id'] as String,
      leadId: json['lead_id'] as String?,
      bookingNumber: json['booking_number'] as String,
      variantId: json['variant_id'] as String,
      colorId: json['color_id'] as String,
      allocatedVehicleId: json['allocated_vehicle_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      bookingAmount: (json['booking_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMode: json['payment_mode'] as String?,
      paymentReference: json['payment_reference'] as String?,
      exShowroomPrice: (json['ex_showroom_price'] as num?)?.toDouble() ?? 0.0,
      onRoadPrice: (json['on_road_price'] as num?)?.toDouble() ?? 0.0,
      expectedDeliveryDate: json['expected_delivery_date'] != null
          ? DateTime.parse(json['expected_delivery_date'] as String)
          : null,
      actualDeliveryDate: json['actual_delivery_date'] != null
          ? DateTime.parse(json['actual_delivery_date'] as String)
          : null,
      financeRequired: json['finance_required'] as bool? ?? false,
      financeProvider: json['finance_provider'] as String?,
      loanAmount: (json['loan_amount'] as num?)?.toDouble() ?? 0.0,
      exchangeVehicle: json['exchange_vehicle'] as bool? ?? false,
      exchangeDetails: json['exchange_details'] as String?,
      cancelledReason: json['cancelled_reason'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      bookedBy: json['booked_by'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // Hydrated fields
      customerName: json['customer_name'] as String?,
      variantName: json['variant_name'] as String?,
      colorName: json['color_name'] as String?,
      colorHex: json['color_hex'] as String?,
      modelName: json['model_name'] as String?,
      allocatedVin: json['allocated_vin'] as String?,
      bookedByName: json['booked_by_name'] as String?,
      showroomName: json['showroom_name'] as String?,
    );
  }

  static Map<String, dynamic> toJson(BookingEntity entity) {
    return {
      'id': entity.id,
      'showroom_id': entity.showroomId,
      'customer_id': entity.customerId,
      'lead_id': entity.leadId,
      'booking_number': entity.bookingNumber,
      'variant_id': entity.variantId,
      'color_id': entity.colorId,
      'allocated_vehicle_id': entity.allocatedVehicleId,
      'status': entity.status,
      'booking_amount': entity.bookingAmount,
      'payment_mode': entity.paymentMode,
      'payment_reference': entity.paymentReference,
      'ex_showroom_price': entity.exShowroomPrice,
      'on_road_price': entity.onRoadPrice,
      'expected_delivery_date': entity.expectedDeliveryDate?.toIso8601String().substring(0, 10),
      'actual_delivery_date': entity.actualDeliveryDate?.toIso8601String().substring(0, 10),
      'finance_required': entity.financeRequired,
      'finance_provider': entity.financeProvider,
      'loan_amount': entity.loanAmount,
      'exchange_vehicle': entity.exchangeVehicle,
      'exchange_details': entity.exchangeDetails,
      'cancelled_reason': entity.cancelledReason,
      'cancelled_at': entity.cancelledAt?.toIso8601String(),
      'booked_by': entity.bookedBy,
      'notes': entity.notes,
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> toInsertJson(BookingEntity entity) {
    final json = toJson(entity);
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    json.remove('customer_name');
    json.remove('variant_name');
    json.remove('color_name');
    json.remove('color_hex');
    json.remove('model_name');
    json.remove('allocated_vin');
    json.remove('booked_by_name');
    json.remove('showroom_name');
    return json;
  }
}
