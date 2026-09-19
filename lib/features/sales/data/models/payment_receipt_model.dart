import '../../domain/entities/payment_receipt_entity.dart';

/// Payment Receipt Data Model
class PaymentReceiptModel {
  const PaymentReceiptModel._();

  static PaymentReceiptEntity fromJson(Map<String, dynamic> json) {
    return PaymentReceiptEntity(
      id: json['id'] as String,
      showroomId: json['showroom_id'] as String,
      customerId: json['customer_id'] as String,
      invoiceId: json['invoice_id'] as String?,
      bookingId: json['booking_id'] as String?,
      receiptNumber: json['receipt_number'] as String,
      receiptDate: DateTime.parse(json['receipt_date'] as String),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMode: json['payment_mode'] as String,
      paymentReference: json['payment_reference'] as String?,
      bankName: json['bank_name'] as String?,
      collectedBy: json['collected_by'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      customerName: json['customer_name'] as String?,
    );
  }

  static Map<String, dynamic> toJson(PaymentReceiptEntity entity) {
    return {
      'id': entity.id,
      'showroom_id': entity.showroomId,
      'customer_id': entity.customerId,
      'invoice_id': entity.invoiceId,
      'booking_id': entity.bookingId,
      'receipt_number': entity.receiptNumber,
      'receipt_date': entity.receiptDate.toIso8601String().substring(0, 10),
      'amount': entity.amount,
      'payment_mode': entity.paymentMode,
      'payment_reference': entity.paymentReference,
      'bank_name': entity.bankName,
      'collected_by': entity.collectedBy,
      'notes': entity.notes,
      'created_at': entity.createdAt.toIso8601String(),
    };
  }
}
