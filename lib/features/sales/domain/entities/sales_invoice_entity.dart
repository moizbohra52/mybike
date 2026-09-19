import 'package:equatable/equatable.dart';

/// Sales Invoice Domain Entity (GST Tax Invoice)
///
/// Models a complete legal GST sales invoice for a two-wheeler vehicle sale
/// in the Indian automotive dealership domain.
class SalesInvoiceEntity extends Equatable {
  final String id;
  final String showroomId;
  final String customerId;
  final String? bookingId;
  final String? vehicleInventoryId;
  final String invoiceNumber; // e.g. "IND-MUM-INV-00185"
  final DateTime invoiceDate;

  // Vehicle Particulars
  final String variantId;
  final String colorId;
  final String vin;
  final String? engineNumber;
  final String? motorNumber;
  final String? batterySerialNumber;
  final String? keyNumber;

  // GST & Tax Particulars
  final String hsnCode; // '8711'
  final double gstRate; // 28.0 (Petrol) or 5.0 (EV)
  final bool isInterstate;

  // Pricing Breakdown (INR)
  final double exShowroomPrice;
  final double discountAmount;
  final double taxableAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double rtoCharges;
  final double insuranceCharges;
  final double accessoriesTotal;
  final double extendedWarrantyAmount;
  final double fastagCharges;
  final double hypothecationCharges;
  final double tcsAmount;
  final double roundOff;
  final double totalOnRoadPrice;

  // Settlement & Payment
  final double bookingAdvanceAdjusted;
  final double financeAmount;
  final String? financeBank;
  final double exchangeAllowance;
  final double amountPaid;
  final double balanceAmount;
  final String paymentStatus; // 'pending', 'partial', 'paid', 'refunded'

  // Document State
  final String status; // 'draft', 'issued', 'delivered', 'cancelled'
  final String? issuedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Hydrated Display Helpers
  final String? customerName;
  final String? customerMobile;
  final String? modelName;
  final String? variantName;
  final String? colorName;
  final String? showroomName;

  const SalesInvoiceEntity({
    required this.id,
    required this.showroomId,
    required this.customerId,
    this.bookingId,
    this.vehicleInventoryId,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.variantId,
    required this.colorId,
    required this.vin,
    this.engineNumber,
    this.motorNumber,
    this.batterySerialNumber,
    this.keyNumber,
    this.hsnCode = '8711',
    this.gstRate = 28.0,
    this.isInterstate = false,
    required this.exShowroomPrice,
    this.discountAmount = 0.0,
    required this.taxableAmount,
    this.cgstAmount = 0.0,
    this.sgstAmount = 0.0,
    this.igstAmount = 0.0,
    this.rtoCharges = 0.0,
    this.insuranceCharges = 0.0,
    this.accessoriesTotal = 0.0,
    this.extendedWarrantyAmount = 0.0,
    this.fastagCharges = 0.0,
    this.hypothecationCharges = 0.0,
    this.tcsAmount = 0.0,
    this.roundOff = 0.0,
    required this.totalOnRoadPrice,
    this.bookingAdvanceAdjusted = 0.0,
    this.financeAmount = 0.0,
    this.financeBank,
    this.exchangeAllowance = 0.0,
    this.amountPaid = 0.0,
    this.balanceAmount = 0.0,
    this.paymentStatus = 'pending',
    this.status = 'draft',
    this.issuedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.customerName,
    this.customerMobile,
    this.modelName,
    this.variantName,
    this.colorName,
    this.showroomName,
  });

  // ─── Helpers ───
  bool get isPaid => paymentStatus == 'paid';
  bool get isPartialPayment => paymentStatus == 'partial';
  bool get isDelivered => status == 'delivered';
  bool get isIssued => status == 'issued';
  bool get isDraft => status == 'draft';
  bool get isCancelled => status == 'cancelled';
  bool get isEv => gstRate == 5.0;

  double get totalGst => isInterstate ? igstAmount : (cgstAmount + sgstAmount);
  double get totalPaid => amountPaid + bookingAdvanceAdjusted + financeAmount;

  SalesInvoiceEntity copyWith({
    String? id,
    String? showroomId,
    String? customerId,
    String? bookingId,
    String? vehicleInventoryId,
    String? invoiceNumber,
    DateTime? invoiceDate,
    String? variantId,
    String? colorId,
    String? vin,
    String? engineNumber,
    String? motorNumber,
    String? batterySerialNumber,
    String? keyNumber,
    String? hsnCode,
    double? gstRate,
    bool? isInterstate,
    double? exShowroomPrice,
    double? discountAmount,
    double? taxableAmount,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? rtoCharges,
    double? insuranceCharges,
    double? accessoriesTotal,
    double? extendedWarrantyAmount,
    double? fastagCharges,
    double? hypothecationCharges,
    double? tcsAmount,
    double? roundOff,
    double? totalOnRoadPrice,
    double? bookingAdvanceAdjusted,
    double? financeAmount,
    String? financeBank,
    double? exchangeAllowance,
    double? amountPaid,
    double? balanceAmount,
    String? paymentStatus,
    String? status,
    String? issuedBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerName,
    String? customerMobile,
    String? modelName,
    String? variantName,
    String? colorName,
    String? showroomName,
  }) {
    return SalesInvoiceEntity(
      id: id ?? this.id,
      showroomId: showroomId ?? this.showroomId,
      customerId: customerId ?? this.customerId,
      bookingId: bookingId ?? this.bookingId,
      vehicleInventoryId: vehicleInventoryId ?? this.vehicleInventoryId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      variantId: variantId ?? this.variantId,
      colorId: colorId ?? this.colorId,
      vin: vin ?? this.vin,
      engineNumber: engineNumber ?? this.engineNumber,
      motorNumber: motorNumber ?? this.motorNumber,
      batterySerialNumber: batterySerialNumber ?? this.batterySerialNumber,
      keyNumber: keyNumber ?? this.keyNumber,
      hsnCode: hsnCode ?? this.hsnCode,
      gstRate: gstRate ?? this.gstRate,
      isInterstate: isInterstate ?? this.isInterstate,
      exShowroomPrice: exShowroomPrice ?? this.exShowroomPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      rtoCharges: rtoCharges ?? this.rtoCharges,
      insuranceCharges: insuranceCharges ?? this.insuranceCharges,
      accessoriesTotal: accessoriesTotal ?? this.accessoriesTotal,
      extendedWarrantyAmount: extendedWarrantyAmount ?? this.extendedWarrantyAmount,
      fastagCharges: fastagCharges ?? this.fastagCharges,
      hypothecationCharges: hypothecationCharges ?? this.hypothecationCharges,
      tcsAmount: tcsAmount ?? this.tcsAmount,
      roundOff: roundOff ?? this.roundOff,
      totalOnRoadPrice: totalOnRoadPrice ?? this.totalOnRoadPrice,
      bookingAdvanceAdjusted: bookingAdvanceAdjusted ?? this.bookingAdvanceAdjusted,
      financeAmount: financeAmount ?? this.financeAmount,
      financeBank: financeBank ?? this.financeBank,
      exchangeAllowance: exchangeAllowance ?? this.exchangeAllowance,
      amountPaid: amountPaid ?? this.amountPaid,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      issuedBy: issuedBy ?? this.issuedBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName ?? this.customerName,
      customerMobile: customerMobile ?? this.customerMobile,
      modelName: modelName ?? this.modelName,
      variantName: variantName ?? this.variantName,
      colorName: colorName ?? this.colorName,
      showroomName: showroomName ?? this.showroomName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        showroomId,
        customerId,
        vin,
        totalOnRoadPrice,
        paymentStatus,
        status,
      ];
}
