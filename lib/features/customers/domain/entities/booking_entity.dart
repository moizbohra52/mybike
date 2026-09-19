import 'package:equatable/equatable.dart';

/// Vehicle Booking Domain Entity
///
/// Represents a customer booking with token advance in the Indian
/// two-wheeler dealership context. Tracks the full lifecycle:
/// Pending → Confirmed → Allocated → Ready for Delivery → Delivered.
class BookingEntity extends Equatable {
  final String id;
  final String showroomId;
  final String customerId;
  final String? leadId;
  final String bookingNumber; // e.g. "BK-IND-MAIN-2026-0001"
  final String variantId;
  final String colorId;
  final String? allocatedVehicleId;
  final String status; // 'pending', 'confirmed', 'allocated', 'ready_for_delivery', 'delivered', 'cancelled', 'refunded'
  // Payment
  final double bookingAmount;
  final String? paymentMode; // 'cash', 'upi', 'neft', 'cheque', 'card'
  final String? paymentReference;
  // Pricing
  final double exShowroomPrice;
  final double onRoadPrice;
  // Delivery
  final DateTime? expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  // Finance
  final bool financeRequired;
  final String? financeProvider;
  final double loanAmount;
  // Exchange
  final bool exchangeVehicle;
  final String? exchangeDetails;
  // Cancellation
  final String? cancelledReason;
  final DateTime? cancelledAt;
  // Staff
  final String? bookedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ─── Hydrated Fields ───
  final String? customerName;
  final String? variantName;
  final String? colorName;
  final String? colorHex;
  final String? modelName;
  final String? allocatedVin;
  final String? bookedByName;
  final String? showroomName;

  const BookingEntity({
    required this.id,
    required this.showroomId,
    required this.customerId,
    this.leadId,
    required this.bookingNumber,
    required this.variantId,
    required this.colorId,
    this.allocatedVehicleId,
    this.status = 'pending',
    this.bookingAmount = 0.0,
    this.paymentMode,
    this.paymentReference,
    this.exShowroomPrice = 0.0,
    this.onRoadPrice = 0.0,
    this.expectedDeliveryDate,
    this.actualDeliveryDate,
    this.financeRequired = false,
    this.financeProvider,
    this.loanAmount = 0.0,
    this.exchangeVehicle = false,
    this.exchangeDetails,
    this.cancelledReason,
    this.cancelledAt,
    this.bookedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    // Hydrated
    this.customerName,
    this.variantName,
    this.colorName,
    this.colorHex,
    this.modelName,
    this.allocatedVin,
    this.bookedByName,
    this.showroomName,
  });

  // ─── Computed Helpers ───

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isAllocated => status == 'allocated';
  bool get isReadyForDelivery => status == 'ready_for_delivery';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isRefunded => status == 'refunded';

  /// Active bookings (not cancelled, not refunded)
  bool get isActive => !isCancelled && !isRefunded;

  /// Whether a VIN has been allocated
  bool get hasVehicleAllocated => allocatedVehicleId != null && allocatedVehicleId!.isNotEmpty;

  /// Balance pending after token advance
  double get pendingAmount => onRoadPrice - bookingAmount;

  /// Finance coverage percentage
  double get financeCoveragePercent {
    if (!financeRequired || onRoadPrice == 0) return 0.0;
    return (loanAmount / onRoadPrice) * 100;
  }

  /// Days until expected delivery
  int? get daysToDelivery {
    if (expectedDeliveryDate == null) return null;
    return expectedDeliveryDate!.difference(DateTime.now()).inDays;
  }

  /// Whether delivery is overdue
  bool get isDeliveryOverdue {
    if (expectedDeliveryDate == null || isDelivered || isCancelled) return false;
    return DateTime.now().isAfter(expectedDeliveryDate!);
  }

  /// Human-readable status label
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'allocated':
        return 'Allocated';
      case 'ready_for_delivery':
        return 'Ready for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  /// Payment mode display label
  String get paymentModeLabel {
    switch (paymentMode) {
      case 'cash':
        return 'Cash';
      case 'upi':
        return 'UPI';
      case 'neft':
        return 'NEFT';
      case 'cheque':
        return 'Cheque';
      case 'card':
        return 'Card';
      default:
        return paymentMode ?? 'Unknown';
    }
  }

  /// Format INR amount
  static String formatInr(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    }
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    }
    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  BookingEntity copyWith({
    String? id,
    String? showroomId,
    String? customerId,
    String? leadId,
    String? bookingNumber,
    String? variantId,
    String? colorId,
    String? allocatedVehicleId,
    String? status,
    double? bookingAmount,
    String? paymentMode,
    String? paymentReference,
    double? exShowroomPrice,
    double? onRoadPrice,
    DateTime? expectedDeliveryDate,
    DateTime? actualDeliveryDate,
    bool? financeRequired,
    String? financeProvider,
    double? loanAmount,
    bool? exchangeVehicle,
    String? exchangeDetails,
    String? cancelledReason,
    DateTime? cancelledAt,
    String? bookedBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerName,
    String? variantName,
    String? colorName,
    String? colorHex,
    String? modelName,
    String? allocatedVin,
    String? bookedByName,
    String? showroomName,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      showroomId: showroomId ?? this.showroomId,
      customerId: customerId ?? this.customerId,
      leadId: leadId ?? this.leadId,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      variantId: variantId ?? this.variantId,
      colorId: colorId ?? this.colorId,
      allocatedVehicleId: allocatedVehicleId ?? this.allocatedVehicleId,
      status: status ?? this.status,
      bookingAmount: bookingAmount ?? this.bookingAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentReference: paymentReference ?? this.paymentReference,
      exShowroomPrice: exShowroomPrice ?? this.exShowroomPrice,
      onRoadPrice: onRoadPrice ?? this.onRoadPrice,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      financeRequired: financeRequired ?? this.financeRequired,
      financeProvider: financeProvider ?? this.financeProvider,
      loanAmount: loanAmount ?? this.loanAmount,
      exchangeVehicle: exchangeVehicle ?? this.exchangeVehicle,
      exchangeDetails: exchangeDetails ?? this.exchangeDetails,
      cancelledReason: cancelledReason ?? this.cancelledReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      bookedBy: bookedBy ?? this.bookedBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName ?? this.customerName,
      variantName: variantName ?? this.variantName,
      colorName: colorName ?? this.colorName,
      colorHex: colorHex ?? this.colorHex,
      modelName: modelName ?? this.modelName,
      allocatedVin: allocatedVin ?? this.allocatedVin,
      bookedByName: bookedByName ?? this.bookedByName,
      showroomName: showroomName ?? this.showroomName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        showroomId,
        customerId,
        leadId,
        bookingNumber,
        variantId,
        colorId,
        allocatedVehicleId,
        status,
        bookingAmount,
        paymentMode,
        paymentReference,
        exShowroomPrice,
        onRoadPrice,
        expectedDeliveryDate,
        actualDeliveryDate,
        financeRequired,
        financeProvider,
        loanAmount,
        exchangeVehicle,
        exchangeDetails,
        cancelledReason,
        cancelledAt,
        bookedBy,
        notes,
        createdAt,
        updatedAt,
      ];
}
