import '../../domain/entities/sales_invoice_entity.dart';

/// Sales Invoice Data Model (Supabase JSON ↔ Entity)
class SalesInvoiceModel {
  const SalesInvoiceModel._();

  static SalesInvoiceEntity fromJson(Map<String, dynamic> json) {
    return SalesInvoiceEntity(
      id: json['id'] as String,
      showroomId: json['showroom_id'] as String,
      customerId: json['customer_id'] as String,
      bookingId: json['booking_id'] as String?,
      vehicleInventoryId: json['vehicle_inventory_id'] as String?,
      invoiceNumber: json['invoice_number'] as String,
      invoiceDate: DateTime.parse(json['invoice_date'] as String),
      variantId: json['variant_id'] as String,
      colorId: json['color_id'] as String,
      vin: json['vin'] as String,
      engineNumber: json['engine_number'] as String?,
      motorNumber: json['motor_number'] as String?,
      batterySerialNumber: json['battery_serial_number'] as String?,
      keyNumber: json['key_number'] as String?,
      hsnCode: json['hsn_code'] as String? ?? '8711',
      gstRate: (json['gst_rate'] as num?)?.toDouble() ?? 28.0,
      isInterstate: json['is_interstate'] as bool? ?? false,
      exShowroomPrice: (json['ex_showroom_price'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      taxableAmount: (json['taxable_amount'] as num?)?.toDouble() ?? 0.0,
      cgstAmount: (json['cgst_amount'] as num?)?.toDouble() ?? 0.0,
      sgstAmount: (json['sgst_amount'] as num?)?.toDouble() ?? 0.0,
      igstAmount: (json['igst_amount'] as num?)?.toDouble() ?? 0.0,
      rtoCharges: (json['rto_charges'] as num?)?.toDouble() ?? 0.0,
      insuranceCharges: (json['insurance_charges'] as num?)?.toDouble() ?? 0.0,
      accessoriesTotal: (json['accessories_total'] as num?)?.toDouble() ?? 0.0,
      extendedWarrantyAmount: (json['extended_warranty_amount'] as num?)?.toDouble() ?? 0.0,
      fastagCharges: (json['fastag_charges'] as num?)?.toDouble() ?? 0.0,
      hypothecationCharges: (json['hypothecation_charges'] as num?)?.toDouble() ?? 0.0,
      tcsAmount: (json['tcs_amount'] as num?)?.toDouble() ?? 0.0,
      roundOff: (json['round_off'] as num?)?.toDouble() ?? 0.0,
      totalOnRoadPrice: (json['total_on_road_price'] as num?)?.toDouble() ?? 0.0,
      bookingAdvanceAdjusted: (json['booking_advance_adjusted'] as num?)?.toDouble() ?? 0.0,
      financeAmount: (json['finance_amount'] as num?)?.toDouble() ?? 0.0,
      financeBank: json['finance_bank'] as String?,
      exchangeAllowance: (json['exchange_allowance'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      balanceAmount: (json['balance_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      status: json['status'] as String? ?? 'draft',
      issuedBy: json['issued_by'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // Hydrated
      customerName: json['customer_name'] as String?,
      customerMobile: json['customer_mobile'] as String?,
      modelName: json['model_name'] as String?,
      variantName: json['variant_name'] as String?,
      colorName: json['color_name'] as String?,
      showroomName: json['showroom_name'] as String?,
    );
  }

  static Map<String, dynamic> toJson(SalesInvoiceEntity entity) {
    return {
      'id': entity.id,
      'showroom_id': entity.showroomId,
      'customer_id': entity.customerId,
      'booking_id': entity.bookingId,
      'vehicle_inventory_id': entity.vehicleInventoryId,
      'invoice_number': entity.invoiceNumber,
      'invoice_date': entity.invoiceDate.toIso8601String().substring(0, 10),
      'variant_id': entity.variantId,
      'color_id': entity.colorId,
      'vin': entity.vin,
      'engine_number': entity.engineNumber,
      'motor_number': entity.motorNumber,
      'battery_serial_number': entity.batterySerialNumber,
      'key_number': entity.keyNumber,
      'hsn_code': entity.hsnCode,
      'gst_rate': entity.gstRate,
      'is_interstate': entity.isInterstate,
      'ex_showroom_price': entity.exShowroomPrice,
      'discount_amount': entity.discountAmount,
      'taxable_amount': entity.taxableAmount,
      'cgst_amount': entity.cgstAmount,
      'sgst_amount': entity.sgstAmount,
      'igst_amount': entity.igstAmount,
      'rto_charges': entity.rtoCharges,
      'insurance_charges': entity.insuranceCharges,
      'accessories_total': entity.accessoriesTotal,
      'extended_warranty_amount': entity.extendedWarrantyAmount,
      'fastag_charges': entity.fastagCharges,
      'hypothecation_charges': entity.hypothecationCharges,
      'tcs_amount': entity.tcsAmount,
      'round_off': entity.roundOff,
      'total_on_road_price': entity.totalOnRoadPrice,
      'booking_advance_adjusted': entity.bookingAdvanceAdjusted,
      'finance_amount': entity.financeAmount,
      'finance_bank': entity.financeBank,
      'exchange_allowance': entity.exchangeAllowance,
      'amount_paid': entity.amountPaid,
      'balance_amount': entity.balanceAmount,
      'payment_status': entity.paymentStatus,
      'status': entity.status,
      'issued_by': entity.issuedBy,
      'notes': entity.notes,
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> toInsertJson(SalesInvoiceEntity entity) {
    final json = toJson(entity);
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }
}
