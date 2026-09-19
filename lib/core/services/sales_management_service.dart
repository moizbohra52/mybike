import 'package:flutter/foundation.dart';

import '../config/supabase_config.dart';
import 'supabase_service.dart';
import '../../features/sales/domain/entities/sales_invoice_entity.dart';
import '../../features/sales/domain/entities/invoice_item_entity.dart';
import '../../features/sales/domain/entities/payment_receipt_entity.dart';
import '../../features/sales/domain/entities/delivery_challan_entity.dart';
import '../../features/sales/domain/entities/gate_pass_entity.dart';
import '../../features/sales/data/models/sales_invoice_model.dart';
import 'inventory_management_service.dart';
import 'customer_management_service.dart';

/// Sales Management Service
///
/// Handles all dealership sales, GST tax invoicing, payment receipts,
/// delivery challans, and gate passes.
class SalesManagementService {
  SalesManagementService._();
  static final SalesManagementService instance = SalesManagementService._();

  bool get _isSupabaseLive =>
      SupabaseConfig.isConfigured && SupabaseService.client != null;

  // ═══════════════════════════════════════════════════════════════════
  // DEV MODE SEED DATA
  // ═══════════════════════════════════════════════════════════════════

  static final DateTime _now = DateTime.now();
  static final DateTime _twoDaysAgo = _now.subtract(const Duration(days: 2));
  static final DateTime _fiveDaysAgo = _now.subtract(const Duration(days: 5));

  static const String _mumbaiId = 'showroom-mumbai-main';
  static const String _puneId = 'showroom-pune-west';
  static const String _bangaloreId = 'showroom-bangalore-metro';

  static final List<SalesInvoiceEntity> _devInvoices = [
    // 1. Honda CB350 (Petrol - 28% GST) - Mumbai - Delivered
    SalesInvoiceEntity(
      id: 'inv-001',
      showroomId: _mumbaiId,
      customerId: 'cust-001',
      bookingId: 'booking-001',
      vehicleInventoryId: 'inv-cb350-001',
      invoiceNumber: 'IND-MUM-INV-00184',
      invoiceDate: _fiveDaysAgo,
      variantId: 'variant-cb350-dlx-pro',
      colorId: 'color-cb350-red',
      vin: 'ME4NC5800N8000101',
      engineNumber: 'NC58E-1002341',
      keyNumber: 'KEY-MUM-01',
      hsnCode: '8711',
      gstRate: 28.0,
      isInterstate: false,
      exShowroomPrice: 217800.0,
      discountAmount: 2000.0,
      taxableAmount: 168593.75,
      cgstAmount: 23603.13,
      sgstAmount: 23603.12,
      rtoCharges: 21500.0,
      insuranceCharges: 12400.0,
      accessoriesTotal: 4500.0,
      extendedWarrantyAmount: 2800.0,
      fastagCharges: 500.0,
      hypothecationCharges: 1500.0,
      roundOff: 0.0,
      totalOnRoadPrice: 258500.0,
      bookingAdvanceAdjusted: 5000.0,
      financeAmount: 180000.0,
      financeBank: 'HDFC Bank Auto Loan',
      exchangeAllowance: 25000.0,
      amountPaid: 258500.0,
      balanceAmount: 0.0,
      paymentStatus: 'paid',
      status: 'delivered',
      issuedBy: 'staff-rahul-001',
      createdAt: _fiveDaysAgo,
      updatedAt: _fiveDaysAgo,
      customerName: 'Rajesh Sharma',
      customerMobile: '9876543210',
      modelName: 'Honda CB350',
      variantName: 'DLX Pro',
      colorName: 'Precious Red Metallic',
      showroomName: 'Mumbai Flagship',
    ),
    // 2. Ather 450X (EV - 5% GST) - Pune - Delivered
    SalesInvoiceEntity(
      id: 'inv-002',
      showroomId: _puneId,
      customerId: 'cust-003',
      bookingId: 'booking-003',
      vehicleInventoryId: 'inv-ather-001',
      invoiceNumber: 'IND-PUN-INV-00042',
      invoiceDate: _twoDaysAgo,
      variantId: 'variant-ather-450x-pro',
      colorId: 'color-ather-white',
      vin: 'MALJA450XN0000103',
      motorNumber: 'ATH-MTR-64-001',
      batterySerialNumber: 'ATH-BAT-37-9001',
      keyNumber: 'KEY-PUN-03',
      hsnCode: '8711',
      gstRate: 5.0,
      isInterstate: false,
      exShowroomPrice: 154999.0,
      discountAmount: 0.0,
      taxableAmount: 147618.10,
      cgstAmount: 3690.45,
      sgstAmount: 3690.45,
      rtoCharges: 2500.0, // EV road tax exemption subsidy
      insuranceCharges: 8500.0,
      accessoriesTotal: 3200.0,
      extendedWarrantyAmount: 3999.0,
      fastagCharges: 0.0,
      hypothecationCharges: 0.0,
      roundOff: 0.0,
      totalOnRoadPrice: 173198.0,
      bookingAdvanceAdjusted: 5000.0,
      financeAmount: 0.0,
      exchangeAllowance: 0.0,
      amountPaid: 173198.0,
      balanceAmount: 0.0,
      paymentStatus: 'paid',
      status: 'delivered',
      issuedBy: 'staff-amit-003',
      createdAt: _twoDaysAgo,
      updatedAt: _twoDaysAgo,
      customerName: 'Amit Kulkarni',
      customerMobile: '9822012345',
      modelName: 'Ather 450X',
      variantName: '3.7 Pro',
      colorName: 'Space Grey',
      showroomName: 'Pune West Hub',
    ),
    // 3. TVS Apache RTR 310 - Mumbai - Issued (Pending Delivery)
    SalesInvoiceEntity(
      id: 'inv-003',
      showroomId: _mumbaiId,
      customerId: 'cust-002',
      bookingId: 'booking-002',
      invoiceNumber: 'IND-MUM-INV-00185',
      invoiceDate: _now,
      variantId: 'variant-apache-rtr-310-bto',
      colorId: 'color-cb350-red',
      vin: 'ME4NC5800N8000102',
      engineNumber: 'RTR310E-99881',
      keyNumber: 'KEY-MUM-02',
      hsnCode: '8711',
      gstRate: 28.0,
      isInterstate: false,
      exShowroomPrice: 272000.0,
      discountAmount: 5000.0,
      taxableAmount: 208593.75,
      cgstAmount: 29203.13,
      sgstAmount: 29203.12,
      rtoCharges: 26800.0,
      insuranceCharges: 14500.0,
      accessoriesTotal: 6500.0,
      extendedWarrantyAmount: 3500.0,
      fastagCharges: 500.0,
      hypothecationCharges: 1500.0,
      roundOff: 0.0,
      totalOnRoadPrice: 320300.0,
      bookingAdvanceAdjusted: 10000.0,
      financeAmount: 220000.0,
      financeBank: 'State Bank of India',
      exchangeAllowance: 0.0,
      amountPaid: 320300.0,
      balanceAmount: 0.0,
      paymentStatus: 'paid',
      status: 'issued',
      issuedBy: 'staff-rahul-001',
      createdAt: _now,
      updatedAt: _now,
      customerName: 'Priya Deshmukh',
      customerMobile: '9876543212',
      modelName: 'TVS Apache RTR 310',
      variantName: 'BTO Dynamic',
      colorName: 'Arsenal Black',
      showroomName: 'Mumbai Flagship',
    ),
    // 4. Ather Rizta Z - Bangalore - Draft
    SalesInvoiceEntity(
      id: 'inv-004',
      showroomId: _bangaloreId,
      customerId: 'cust-004',
      invoiceNumber: 'IND-BLR-INV-00012',
      invoiceDate: _now,
      variantId: 'variant-ather-rizta-z',
      colorId: 'color-rizta-blue',
      vin: 'MALJA450XN0000104',
      motorNumber: 'ATH-MTR-RZ-102',
      batterySerialNumber: 'ATH-BAT-RZ-881',
      keyNumber: 'KEY-BLR-04',
      hsnCode: '8711',
      gstRate: 5.0,
      isInterstate: false,
      exShowroomPrice: 144999.0,
      discountAmount: 0.0,
      taxableAmount: 138094.28,
      cgstAmount: 3452.36,
      sgstAmount: 3452.36,
      rtoCharges: 2500.0,
      insuranceCharges: 7900.0,
      accessoriesTotal: 2500.0,
      extendedWarrantyAmount: 3200.0,
      fastagCharges: 0.0,
      hypothecationCharges: 0.0,
      roundOff: 0.0,
      totalOnRoadPrice: 161099.0,
      bookingAdvanceAdjusted: 5000.0,
      financeAmount: 100000.0,
      financeBank: 'ICICI Bank',
      exchangeAllowance: 0.0,
      amountPaid: 5000.0,
      balanceAmount: 156099.0,
      paymentStatus: 'partial',
      status: 'draft',
      issuedBy: 'staff-priya-002',
      createdAt: _now,
      updatedAt: _now,
      customerName: 'Karthik Rajan',
      customerMobile: '9845012345',
      modelName: 'Ather Rizta',
      variantName: 'Rizta Z 3.7',
      colorName: 'Pangong Blue',
      showroomName: 'Bangalore Metro',
    ),
  ];

  static final List<DeliveryChallanEntity> _devChallans = [
    DeliveryChallanEntity(
      id: 'dc-001',
      showroomId: _mumbaiId,
      invoiceId: 'inv-001',
      challanNumber: 'IND-MUM-DC-00041',
      challanDate: _fiveDaysAgo,
      allocatedVin: 'ME4NC5800N8000101',
      odometerReadingKm: 3.5,
      fuelLevel: '5 Litres',
      helmetProvided: true,
      toolkitProvided: true,
      firstAidKitProvided: true,
      ownerManualProvided: true,
      spareKeysCount: 2,
      pdiFormSigned: true,
      customerAcceptanceSigned: true,
      deliveredBy: 'staff-rahul-001',
      receivedByName: 'Rajesh Sharma',
      receivedByRelationship: 'self',
      createdAt: _fiveDaysAgo,
      invoiceNumber: 'IND-MUM-INV-00184',
      customerName: 'Rajesh Sharma',
      modelName: 'Honda CB350',
      variantName: 'DLX Pro',
      colorName: 'Precious Red Metallic',
    ),
    DeliveryChallanEntity(
      id: 'dc-002',
      showroomId: _puneId,
      invoiceId: 'inv-002',
      challanNumber: 'IND-PUN-DC-00019',
      challanDate: _twoDaysAgo,
      allocatedVin: 'MALJA450XN0000103',
      odometerReadingKm: 2.1,
      batterySocPercent: 98.0,
      helmetProvided: true,
      toolkitProvided: true,
      firstAidKitProvided: true,
      ownerManualProvided: true,
      spareKeysCount: 2,
      batteryChargerSerial: 'ATH-CHG-3300-881',
      pdiFormSigned: true,
      customerAcceptanceSigned: true,
      deliveredBy: 'staff-amit-003',
      receivedByName: 'Amit Kulkarni',
      receivedByRelationship: 'self',
      createdAt: _twoDaysAgo,
      invoiceNumber: 'IND-PUN-INV-00042',
      customerName: 'Amit Kulkarni',
      modelName: 'Ather 450X',
      variantName: '3.7 Pro',
      colorName: 'Space Grey',
    ),
  ];

  static final List<GatePassEntity> _devGatePasses = [
    GatePassEntity(
      id: 'gp-001',
      showroomId: _mumbaiId,
      challanId: 'dc-001',
      invoiceId: 'inv-001',
      gatePassNumber: 'IND-MUM-GP-00041',
      issuedAt: _fiveDaysAgo,
      vin: 'ME4NC5800N8000101',
      customerName: 'Rajesh Sharma',
      authorizedBy: 'staff-rahul-001',
      authorizedByName: 'Rahul Sharma (Manager)',
      securityGuardName: 'Ramesh Gate 1',
      vehicleDepartedAt: _fiveDaysAgo.add(const Duration(minutes: 15)),
      status: 'departed',
      createdAt: _fiveDaysAgo,
    ),
    GatePassEntity(
      id: 'gp-002',
      showroomId: _puneId,
      challanId: 'dc-002',
      invoiceId: 'inv-002',
      gatePassNumber: 'IND-PUN-GP-00019',
      issuedAt: _twoDaysAgo,
      vin: 'MALJA450XN0000103',
      customerName: 'Amit Kulkarni',
      authorizedBy: 'staff-amit-003',
      authorizedByName: 'Amit Joshi (Manager)',
      securityGuardName: 'Ganesh West Gate',
      vehicleDepartedAt: _twoDaysAgo.add(const Duration(minutes: 20)),
      status: 'departed',
      createdAt: _twoDaysAgo,
    ),
  ];

  static final List<PaymentReceiptEntity> _devReceipts = [
    PaymentReceiptEntity(
      id: 'rcp-001',
      showroomId: _mumbaiId,
      customerId: 'cust-001',
      invoiceId: 'inv-001',
      receiptNumber: 'IND-MUM-RCP-00051',
      receiptDate: _fiveDaysAgo,
      amount: 48500.0,
      paymentMode: 'upi',
      paymentReference: 'UPI-HDFC-998822',
      bankName: 'HDFC Bank',
      collectedBy: 'staff-rahul-001',
      createdAt: _fiveDaysAgo,
      customerName: 'Rajesh Sharma',
    ),
    PaymentReceiptEntity(
      id: 'rcp-002',
      showroomId: _mumbaiId,
      customerId: 'cust-001',
      invoiceId: 'inv-001',
      receiptNumber: 'IND-MUM-RCP-00052',
      receiptDate: _fiveDaysAgo,
      amount: 180000.0,
      paymentMode: 'finance_disbursement',
      paymentReference: 'LOAN-HDFC-771120',
      bankName: 'HDFC Auto Finance',
      collectedBy: 'staff-rahul-001',
      createdAt: _fiveDaysAgo,
      customerName: 'Rajesh Sharma',
    ),
  ];

  // Mutable copies for dev mode operations
  late List<SalesInvoiceEntity> _invoices = List.from(_devInvoices);
  late List<DeliveryChallanEntity> _challans = List.from(_devChallans);
  late List<GatePassEntity> _gatePasses = List.from(_devGatePasses);
  late List<PaymentReceiptEntity> _receipts = List.from(_devReceipts);
  late List<InvoiceItemEntity> _invoiceItems = [];
  int _invoiceSeq = 186;
  int _challanSeq = 43;
  int _gatePassSeq = 43;
  int _receiptSeq = 53;

  /// Reset in-memory dev data (used for testing)
  void resetDevData() {
    _invoices = List.from(_devInvoices);
    _challans = List.from(_devChallans);
    _gatePasses = List.from(_devGatePasses);
    _receipts = List.from(_devReceipts);
    _invoiceItems = [];
    _invoiceSeq = 186;
    _challanSeq = 43;
    _gatePassSeq = 43;
    _receiptSeq = 53;
  }

  // ═══════════════════════════════════════════════════════════════════
  // INVOICE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════

  /// Fetch invoices with optional filters
  Future<List<SalesInvoiceEntity>> fetchInvoices({
    String? showroomId,
    String? status,
    String? search,
  }) async {
    if (!_isSupabaseLive) {
      return _fetchDevInvoices(showroomId: showroomId, status: status, search: search);
    }
    try {
      var query = SupabaseService.client!.from('sales_invoices').select();
      if (showroomId != null) query = query.eq('showroom_id', showroomId);
      if (status != null) query = query.eq('status', status);
      final response = await query.order('created_at', ascending: false);
      final results = (response as List).map((e) => SalesInvoiceModel.fromJson(e as Map<String, dynamic>)).toList();
      if (search != null && search.isNotEmpty) {
        final s = search.toLowerCase();
        return results.where((inv) =>
            inv.invoiceNumber.toLowerCase().contains(s) ||
            inv.vin.toLowerCase().contains(s) ||
            (inv.customerName?.toLowerCase().contains(s) ?? false)).toList();
      }
      return results;
    } catch (e) {
      debugPrint('SalesManagementService.fetchInvoices error: $e');
      return _fetchDevInvoices(showroomId: showroomId, status: status, search: search);
    }
  }

  List<SalesInvoiceEntity> _fetchDevInvoices({
    String? showroomId,
    String? status,
    String? search,
  }) {
    var result = List<SalesInvoiceEntity>.from(_invoices);
    if (showroomId != null) result = result.where((i) => i.showroomId == showroomId).toList();
    if (status != null) result = result.where((i) => i.status == status).toList();
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      result = result.where((i) =>
          i.invoiceNumber.toLowerCase().contains(s) ||
          i.vin.toLowerCase().contains(s) ||
          (i.customerName?.toLowerCase().contains(s) ?? false) ||
          (i.customerMobile?.contains(s) ?? false)).toList();
    }
    return result;
  }

  /// Fetch a single invoice by ID
  Future<SalesInvoiceEntity?> fetchInvoiceById(String id) async {
    if (!_isSupabaseLive) {
      return _invoices.cast<SalesInvoiceEntity?>().firstWhere((i) => i!.id == id, orElse: () => null);
    }
    try {
      final response = await SupabaseService.client!.from('sales_invoices').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return SalesInvoiceModel.fromJson(response);
    } catch (e) {
      debugPrint('SalesManagementService.fetchInvoiceById error: $e');
      return _invoices.cast<SalesInvoiceEntity?>().firstWhere((i) => i!.id == id, orElse: () => null);
    }
  }

  /// Create a new Sales Invoice (GST Tax Invoice)
  Future<SalesInvoiceEntity> createInvoice(
    SalesInvoiceEntity invoice, {
    List<InvoiceItemEntity>? items,
  }) async {
    final invoiceNumber = invoice.invoiceNumber.isNotEmpty
        ? invoice.invoiceNumber
        : 'INV-DEV-${_invoiceSeq.toString().padLeft(5, '0')}';
    _invoiceSeq++;

    final newInvoice = invoice.copyWith(
      id: 'inv-${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: invoiceNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _invoices.insert(0, newInvoice);

    // Track vehicle line item
    final vehicleItem = InvoiceItemEntity(
      id: 'item-${DateTime.now().millisecondsSinceEpoch}',
      invoiceId: newInvoice.id,
      itemType: 'vehicle',
      description: '${newInvoice.modelName ?? "Vehicle"} ${newInvoice.variantName ?? ""}'.trim(),
      hsnSacCode: newInvoice.hsnCode,
      quantity: 1,
      unitPrice: newInvoice.taxableAmount,
      taxableAmount: newInvoice.taxableAmount,
      gstRate: newInvoice.gstRate,
      taxAmount: newInvoice.totalGst,
      totalAmount: newInvoice.taxableAmount + newInvoice.totalGst,
      createdAt: DateTime.now(),
    );
    _invoiceItems.add(vehicleItem);
    if (items != null) {
      _invoiceItems.addAll(items);
    }

    // If linked to a booking, mark the booking as confirmed / invoiced
    if (newInvoice.bookingId != null) {
      try {
        await CustomerManagementService.instance.updateBookingStatus(
          newInvoice.bookingId!,
          'confirmed',
        );
      } catch (e) {
        debugPrint('Note: Booking not updated: $e');
      }
    }

    if (_isSupabaseLive) {
      try {
        await SupabaseService.client!
            .from('sales_invoices')
            .insert(SalesInvoiceModel.toInsertJson(newInvoice));
      } catch (e) {
        debugPrint('Supabase createInvoice error: $e');
      }
    }

    return newInvoice;
  }

  // ═══════════════════════════════════════════════════════════════════
  // PAYMENT RECEIPTS
  // ═══════════════════════════════════════════════════════════════════

  /// Fetch payment receipts
  Future<List<PaymentReceiptEntity>> fetchReceipts({String? invoiceId, String? showroomId}) async {
    var result = List<PaymentReceiptEntity>.from(_receipts);
    if (invoiceId != null) result = result.where((r) => r.invoiceId == invoiceId).toList();
    if (showroomId != null) result = result.where((r) => r.showroomId == showroomId).toList();
    return result;
  }

  /// Record payment receipt and adjust balance on invoice
  Future<PaymentReceiptEntity> recordPaymentReceipt(PaymentReceiptEntity receipt) async {
    final receiptNumber = 'RCP-DEV-${_receiptSeq.toString().padLeft(5, '0')}';
    _receiptSeq++;

    final newReceipt = PaymentReceiptEntity(
      id: 'rcp-${DateTime.now().millisecondsSinceEpoch}',
      showroomId: receipt.showroomId,
      customerId: receipt.customerId,
      invoiceId: receipt.invoiceId,
      bookingId: receipt.bookingId,
      receiptNumber: receiptNumber,
      receiptDate: DateTime.now(),
      amount: receipt.amount,
      paymentMode: receipt.paymentMode,
      paymentReference: receipt.paymentReference,
      bankName: receipt.bankName,
      collectedBy: receipt.collectedBy,
      notes: receipt.notes,
      createdAt: DateTime.now(),
      customerName: receipt.customerName,
    );

    _receipts.insert(0, newReceipt);

    // Update invoice paid and balance amounts
    if (receipt.invoiceId != null) {
      final idx = _invoices.indexWhere((i) => i.id == receipt.invoiceId);
      if (idx >= 0) {
        final inv = _invoices[idx];
        final newPaid = inv.amountPaid + receipt.amount;
        final newBalance = (inv.totalOnRoadPrice - newPaid).clamp(0.0, double.infinity);
        final newStatus = newBalance <= 0.0 ? 'paid' : 'partial';
        _invoices[idx] = inv.copyWith(
          amountPaid: newPaid,
          balanceAmount: newBalance,
          paymentStatus: newStatus,
          updatedAt: DateTime.now(),
        );
      }
    }

    return newReceipt;
  }

  // ═══════════════════════════════════════════════════════════════════
  // DELIVERY CHALLAN & GATE PASS
  // ═══════════════════════════════════════════════════════════════════

  /// Fetch delivery challans
  Future<List<DeliveryChallanEntity>> fetchDeliveryChallans({String? showroomId}) async {
    var result = List<DeliveryChallanEntity>.from(_challans);
    if (showroomId != null) result = result.where((dc) => dc.showroomId == showroomId).toList();
    return result;
  }

  /// Fetch delivery challan by ID
  Future<DeliveryChallanEntity?> fetchDeliveryChallanById(String id) async {
    return _challans.cast<DeliveryChallanEntity?>().firstWhere((dc) => dc!.id == id, orElse: () => null);
  }

  /// Fetch delivery challan by invoice ID
  Future<DeliveryChallanEntity?> fetchChallanByInvoiceId(String invoiceId) async {
    return _challans.cast<DeliveryChallanEntity?>().firstWhere((dc) => dc!.invoiceId == invoiceId, orElse: () => null);
  }

  /// Fetch invoice line items
  Future<List<InvoiceItemEntity>> fetchInvoiceItems(String invoiceId) async {
    return _invoiceItems.where((item) => item.invoiceId == invoiceId).toList();
  }

  /// Create a Delivery Challan, updates Invoice to 'delivered' and vehicle to 'delivered'
  Future<DeliveryChallanEntity> createDeliveryChallan(DeliveryChallanEntity challan) async {
    final challanNumber = 'DC-DEV-${_challanSeq.toString().padLeft(5, '0')}';
    _challanSeq++;

    final newChallan = DeliveryChallanEntity(
      id: 'dc-${DateTime.now().millisecondsSinceEpoch}',
      showroomId: challan.showroomId,
      invoiceId: challan.invoiceId,
      challanNumber: challanNumber,
      challanDate: DateTime.now(),
      allocatedVin: challan.allocatedVin,
      odometerReadingKm: challan.odometerReadingKm,
      batterySocPercent: challan.batterySocPercent,
      fuelLevel: challan.fuelLevel,
      helmetProvided: challan.helmetProvided,
      toolkitProvided: challan.toolkitProvided,
      firstAidKitProvided: challan.firstAidKitProvided,
      ownerManualProvided: challan.ownerManualProvided,
      spareKeysCount: challan.spareKeysCount,
      batteryChargerSerial: challan.batteryChargerSerial,
      pdiFormSigned: challan.pdiFormSigned,
      customerAcceptanceSigned: challan.customerAcceptanceSigned,
      deliveredBy: challan.deliveredBy,
      receivedByName: challan.receivedByName,
      receivedByRelationship: challan.receivedByRelationship,
      notes: challan.notes,
      createdAt: DateTime.now(),
      invoiceNumber: challan.invoiceNumber,
      customerName: challan.customerName,
      modelName: challan.modelName,
      variantName: challan.variantName,
      colorName: challan.colorName,
    );

    _challans.insert(0, newChallan);

    // Update invoice status to 'delivered'
    final invIdx = _invoices.indexWhere((i) => i.id == challan.invoiceId);
    if (invIdx >= 0) {
      _invoices[invIdx] = _invoices[invIdx].copyWith(
        status: 'delivered',
        updatedAt: DateTime.now(),
      );
    }

    // Update vehicle inventory status if vehicle ID or VIN is known
    try {
      final v = await InventoryManagementService.instance.fetchVehicleByVin(challan.allocatedVin);
      if (v != null) {
        await InventoryManagementService.instance.updateVehicleStatus(v.vehicle.id, 'delivered');
        await InventoryManagementService.instance.logStockMovement(
          vehicleId: v.vehicle.id,
          movementType: 'delivered',
          remarks: 'Vehicle handed over to customer under challan $challanNumber',
        );
      }
    } catch (e) {
      debugPrint('Note: Inventory update on delivery: $e');
    }

    return newChallan;
  }

  /// Fetch gate passes
  Future<List<GatePassEntity>> fetchGatePasses({String? showroomId}) async {
    var result = List<GatePassEntity>.from(_gatePasses);
    if (showroomId != null) result = result.where((gp) => gp.showroomId == showroomId).toList();
    return result;
  }

  /// Create a Gate Pass
  Future<GatePassEntity> createGatePass(GatePassEntity pass) async {
    final gpNumber = 'GP-DEV-${_gatePassSeq.toString().padLeft(5, '0')}';
    _gatePassSeq++;

    final newPass = GatePassEntity(
      id: 'gp-${DateTime.now().millisecondsSinceEpoch}',
      showroomId: pass.showroomId,
      challanId: pass.challanId,
      invoiceId: pass.invoiceId,
      gatePassNumber: gpNumber,
      issuedAt: DateTime.now(),
      vin: pass.vin,
      customerName: pass.customerName,
      authorizedBy: pass.authorizedBy,
      authorizedByName: pass.authorizedByName ?? 'Showroom Manager',
      securityGuardName: pass.securityGuardName,
      status: 'issued',
      createdAt: DateTime.now(),
    );

    _gatePasses.insert(0, newPass);
    return newPass;
  }

  /// Mark gate pass departed (Security guard action)
  Future<GatePassEntity> markGatePassDeparted(String gatePassId, String guardName) async {
    final idx = _gatePasses.indexWhere((gp) => gp.id == gatePassId);
    if (idx >= 0) {
      _gatePasses[idx] = GatePassEntity(
        id: _gatePasses[idx].id,
        showroomId: _gatePasses[idx].showroomId,
        challanId: _gatePasses[idx].challanId,
        invoiceId: _gatePasses[idx].invoiceId,
        gatePassNumber: _gatePasses[idx].gatePassNumber,
        issuedAt: _gatePasses[idx].issuedAt,
        vin: _gatePasses[idx].vin,
        customerName: _gatePasses[idx].customerName,
        authorizedBy: _gatePasses[idx].authorizedBy,
        authorizedByName: _gatePasses[idx].authorizedByName,
        securityGuardName: guardName,
        vehicleDepartedAt: DateTime.now(),
        status: 'departed',
        createdAt: _gatePasses[idx].createdAt,
      );
      return _gatePasses[idx];
    }
    throw Exception('Gate pass not found: $gatePassId');
  }
}
