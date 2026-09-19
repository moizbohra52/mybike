import 'package:equatable/equatable.dart';

/// Invoice Line Item Entity (Accessories, Services, Packages)
class InvoiceItemEntity extends Equatable {
  final String id;
  final String invoiceId;
  final String itemType; // 'vehicle', 'accessory', 'insurance', 'rto', 'warranty', 'fastag', 'service'
  final String? itemCode;
  final String description;
  final String? hsnSacCode;
  final int quantity;
  final double unitPrice;
  final double discountAmount;
  final double gstRate;
  final double taxableAmount;
  final double taxAmount;
  final double totalAmount;
  final DateTime createdAt;

  const InvoiceItemEntity({
    required this.id,
    required this.invoiceId,
    required this.itemType,
    this.itemCode,
    required this.description,
    this.hsnSacCode,
    this.quantity = 1,
    required this.unitPrice,
    this.discountAmount = 0.0,
    this.gstRate = 18.0,
    required this.taxableAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        invoiceId,
        itemType,
        description,
        totalAmount,
      ];
}
