import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/customer_management_service.dart';
import 'package:mybike/core/services/sales_management_service.dart';
import 'package:mybike/features/customers/domain/entities/customer_entity.dart';
import 'package:mybike/features/customers/domain/entities/booking_entity.dart';
import 'package:mybike/features/sales/domain/entities/sales_invoice_entity.dart';
import 'package:mybike/features/sales/domain/entities/payment_receipt_entity.dart';
import 'package:mybike/features/sales/domain/entities/delivery_challan_entity.dart';

void main() {
  group('Phase 25 — Integration Test: Full End-to-End Sales Lifecycle', () {
    late CustomerManagementService customerService;
    late SalesManagementService salesService;

    setUp(() {
      customerService = CustomerManagementService.instance;
      salesService = SalesManagementService.instance;
    });

    test('1. Customer Registration, KYC Verification and Lead Creation', () async {
      final newCustomer = CustomerEntity(
        id: 'cust-test-${DateTime.now().millisecondsSinceEpoch}',
        showroomId: 'showroom-mumbai-main',
        customerNumber: 'CUST-2026-9001',
        firstName: 'Vikramaditya',
        lastName: 'Rao',
        mobilePrimary: '9820098200',
        email: 'vikram.rao@enterprise.in',
        addressLine1: '402 Skyline Towers, Worli',
        city: 'Mumbai',
        state: 'Maharashtra',
        pinCode: '400018',
        kycStatus: 'verified',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdCustomer = await customerService.createCustomer(newCustomer);
      expect(createdCustomer.id.isNotEmpty, isTrue);
      expect(createdCustomer.firstName, equals('Vikramaditya'));
      expect(createdCustomer.kycStatus, equals('verified'));
    });

    test('2. Vehicle Booking with Advance Token Payment Receipt', () async {
      final newBooking = BookingEntity(
        id: 'bk-test-${DateTime.now().millisecondsSinceEpoch}',
        showroomId: 'showroom-mumbai-main',
        customerId: 'cust-001',
        bookingNumber: 'BK-MUM-2026-901',
        variantId: 'variant-cb350-dlx-pro',
        colorId: 'color-cb350-red',
        expectedDeliveryDate: DateTime.now().add(const Duration(days: 7)),
        bookingAmount: 10000.0,
        paymentMode: 'upi',
        paymentReference: 'UPI/HDFC/9988112233',
        status: 'confirmed',
        bookedBy: 'staff-rahul-001',
        customerName: 'Rajesh Sharma',
        variantName: 'DLX Pro',
        colorName: 'Precious Red Metallic',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdBooking = await customerService.createBooking(newBooking);
      expect(createdBooking.id.isNotEmpty, isTrue);
      expect(createdBooking.status, equals('confirmed'));
      expect(createdBooking.bookingAmount, equals(10000.0));
    });

    test('3. Stock Allocation and Tax Invoice Generation with GST Ledger Split', () async {
      final invoice = SalesInvoiceEntity(
        id: 'inv-test-${DateTime.now().millisecondsSinceEpoch}',
        showroomId: 'showroom-mumbai-main',
        customerId: 'cust-001',
        bookingId: 'booking-001',
        vehicleInventoryId: 'inv-cb350-001',
        invoiceNumber: 'IND-MUM-INV-99001',
        invoiceDate: DateTime.now(),
        variantId: 'variant-cb350-dlx-pro',
        colorId: 'color-cb350-red',
        vin: 'ME4NC5800N8000999',
        engineNumber: 'NC58E-1009999',
        keyNumber: 'KEY-MUM-99',
        hsnCode: '8711',
        gstRate: 28.0,
        isInterstate: false,
        exShowroomPrice: 200000.0,
        discountAmount: 5000.0,
        taxableAmount: 152343.75,
        cgstAmount: 21328.12,
        sgstAmount: 21328.13,
        rtoCharges: 20000.0,
        insuranceCharges: 12000.0,
        accessoriesTotal: 5000.0,
        extendedWarrantyAmount: 3000.0,
        fastagCharges: 500.0,
        hypothecationCharges: 0.0,
        roundOff: 0.0,
        totalOnRoadPrice: 235500.0,
        bookingAdvanceAdjusted: 10000.0,
        financeAmount: 150000.0,
        financeBank: 'ICICI Bank Auto Loan',
        exchangeAllowance: 0.0,
        amountPaid: 235500.0,
        balanceAmount: 0.0,
        paymentStatus: 'paid',
        status: 'invoiced',
        issuedBy: 'staff-rahul-001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        customerName: 'Rajesh Sharma',
        customerMobile: '9876543210',
        modelName: 'Honda CB350',
        variantName: 'DLX Pro',
        colorName: 'Precious Red Metallic',
        showroomName: 'Mumbai Flagship',
      );

      final createdInvoice = await salesService.createInvoice(invoice);
      expect(createdInvoice.id.isNotEmpty, isTrue);
      expect(createdInvoice.invoiceNumber, equals('IND-MUM-INV-99001'));
      expect(createdInvoice.totalOnRoadPrice, equals(235500.0));
      expect(createdInvoice.paymentStatus, equals('paid'));
    });

    test('4. Payment Receipt Recording and Balance Reconciliation', () async {
      final receipt = PaymentReceiptEntity(
        id: 'rec-test-${DateTime.now().millisecondsSinceEpoch}',
        showroomId: 'showroom-mumbai-main',
        customerId: 'cust-001',
        invoiceId: 'inv-001',
        receiptNumber: 'RCP-MUM-2026-9901',
        receiptDate: DateTime.now(),
        amount: 50000.0,
        paymentMode: 'neft_rtgs',
        paymentReference: 'NEFT/HDFC/1122334455',
        bankName: 'HDFC Bank',
        collectedBy: 'staff-rahul-001',
        notes: 'Balance down payment received',
        createdAt: DateTime.now(),
      );

      final savedReceipt = await salesService.recordPaymentReceipt(receipt);
      expect(savedReceipt.id.isNotEmpty, isTrue);
      expect(savedReceipt.amount, equals(50000.0));
      expect(savedReceipt.paymentMode, equals('neft_rtgs'));
    });

    test('5. Delivery Challan, Gate Pass issuance and Delivery Completion', () async {
      final challan = DeliveryChallanEntity(
        id: 'dc-test-${DateTime.now().millisecondsSinceEpoch}',
        showroomId: 'showroom-mumbai-main',
        invoiceId: 'inv-001',
        challanNumber: 'DC-MUM-2026-9901',
        challanDate: DateTime.now(),
        allocatedVin: 'ME4NC5800N8000101',
        odometerReadingKm: 5,
        fuelLevel: '5 Litres',
        helmetProvided: true,
        toolkitProvided: true,
        firstAidKitProvided: true,
        ownerManualProvided: true,
        spareKeysCount: 2,
        deliveredBy: 'staff-rahul-001',
        receivedByName: 'Rajesh Sharma',
        receivedByRelationship: 'self',
        notes: 'Pre-delivery inspection completed.',
        createdAt: DateTime.now(),
      );

      final savedChallan = await salesService.createDeliveryChallan(challan);
      expect(savedChallan.id.isNotEmpty, isTrue);
      expect(savedChallan.challanNumber.isNotEmpty, isTrue);

      // Check gate passes
      final gatePasses = await salesService.fetchGatePasses();
      expect(gatePasses.any((g) => g.invoiceId == 'inv-001'), isTrue);
    });
  });
}
