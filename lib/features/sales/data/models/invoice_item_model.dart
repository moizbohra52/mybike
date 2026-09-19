import '../../domain/entities/invoice_item_entity.dart';

/// Invoice Line Item Data Model
class InvoiceItemModel {
  const InvoiceItemModel._();

  static InvoiceItemEntity fromJson(Map<String, dynamic> json) {
    return InvoiceItemEntity(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      itemType: json['item_type'] as String,
      itemCode: json['item_code'] as String?,
      description: json['description'] as String,
      hsnSacCode: json['hsn_sac_code'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      gstRate: (json['gst_rate'] as num?)?.toDouble() ?? 18.0,
      taxableAmount: (json['taxable_amount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> toJson(InvoiceItemEntity entity) {
    return {
      'id': entity.id,
      'invoice_id': entity.invoiceId,
      'item_type': entity.itemType,
      'item_code': entity.itemCode,
      'description': entity.description,
      'hsn_sac_code': entity.hsnSacCode,
      'quantity': entity.quantity,
      'unit_price': entity.unitPrice,
      'discount_amount': entity.discountAmount,
      'gst_rate': entity.gstRate,
      'taxable_amount': entity.taxableAmount,
      'tax_amount': entity.taxAmount,
      'total_amount': entity.totalAmount,
      'created_at': entity.createdAt.toIso8601String(),
    };
  }
}
