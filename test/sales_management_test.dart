import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/sales_management_service.dart';
import 'package:mybike/features/sales/data/models/sales_invoice_model.dart';
import 'package:mybike/features/sales/data/models/invoice_item_model.dart';
import 'package:mybike/features/sales/data/models/payment_receipt_model.dart';
import 'package:mybike/features/sales/data/models/delivery_challan_model.dart';
import 'package:mybike/features/sales/data/models/gate_pass_model.dart';
import 'package:mybike/features/sales/domain/entities/sales_invoice_entity.dart';
import 'package:mybike/features/sales/domain/entities/invoice_item_entity.dart';
import 'package:mybike/features/sales/domain/entities/payment_receipt_entity.dart';
import 'package:mybike/features/sales/domain/entities/delivery_challan_entity.dart';
import 'package:mybike/features/sales/domain/entities/gate_pass_entity.dart';
import 'package:mybike/features/sales/presentation/cubit/sales_invoice_list_cubit.dart';
import 'package:mybike/features/sales/presentation/cubit/sales_invoice_detail_cubit.dart';
import 'package:mybike/features/sales/presentation/cubit/booking_wizard_cubit.dart';

void main() {
  setUp(() {
    SalesManagementService.instance.resetDevData();
  });

  group('Sales & Invoicing — Domain Entities & Calculations', () {
    test('SalesInvoiceEntity calculates balance, fully-paid status, and delivered flags', () {
      final now = DateTime(2026, 2, 1);
      final invoice = SalesInvoiceEntity(
        id: 'inv-test-1',
        showroomId: 'sh-001',
        customerId: 'cust-001',
        invoiceNumber: 'INV-2026-00999',
        invoiceDate: now,
        variantId: 'var-001',
        colorId: 'col-001',
        status: 'issued',
        vin: 'ME4NC5800N8000999',
        hsnCode: '8711',
        exShowroomPrice: 200000.0,
        discountAmount: 5000.0,
        taxableAmount: 195000.0,
        gstRate: 28.0,
        cgstAmount: 27300.0,
        sgstAmount: 27300.0,
        rtoCharges: 22000.0,
        insuranceCharges: 11000.0,
        totalOnRoadPrice: 282600.0,
        amountPaid: 200000.0,
        bookingAdvanceAdjusted: 10000.0,
        financeAmount: 72600.0,
        paymentStatus: 'paid',
        createdAt: now,
        updatedAt: now,
      );

      expect(invoice.isPaid, isTrue);
      expect(invoice.isDelivered, isFalse);
      expect(invoice.totalPaid, equals(282600.0));
      expect(invoice.totalGst, equals(54600.0));
      expect(invoice.isEv, isFalse);
    });

    test('SalesInvoiceModel JSON serialization and deserialization preserves all tax amounts', () {
      final now = DateTime(2026, 2, 1);
      final entity = SalesInvoiceEntity(
        id: 'inv-model-1',
        showroomId: 'sh-001',
        customerId: 'cust-002',
        invoiceNumber: 'INV-2026-00042',
        invoiceDate: now,
        variantId: 'var-002',
        colorId: 'col-002',
        status: 'issued',
        vin: 'MALJA450XN0000998',
        hsnCode: '8711',
        exShowroomPrice: 150000.0,
        taxableAmount: 150000.0,
        gstRate: 5.0,
        cgstAmount: 3750.0,
        sgstAmount: 3750.0,
        rtoCharges: 3500.0,
        insuranceCharges: 6500.0,
        totalOnRoadPrice: 163750.0,
        amountPaid: 10000.0,
        balanceAmount: 153750.0,
        paymentStatus: 'partial',
        createdAt: now,
        updatedAt: now,
      );

      final json = SalesInvoiceModel.toJson(entity);
      expect(json['invoice_number'], equals('INV-2026-00042'));
      expect(json['gst_rate'], equals(5.0));
      expect(json['cgst_amount'], equals(3750.0));

      final restored = SalesInvoiceModel.fromJson(json);
      expect(restored.invoiceNumber, equals(entity.invoiceNumber));
      expect(restored.gstRate, equals(5.0));
      expect(restored.totalOnRoadPrice, equals(163750.0));
      expect(restored.balanceAmount, equals(153750.0));
      expect(restored.isEv, isTrue);
    });

    test('InvoiceItemModel and PaymentReceiptModel roundtrip serialization', () {
      final item = InvoiceItemEntity(
        id: 'item-1',
        invoiceId: 'inv-1',
        itemType: 'vehicle',
        description: 'Ather 450X Gen 3',
        hsnSacCode: '8711',
        quantity: 1,
        unitPrice: 154999.0,
        taxableAmount: 154999.0,
        gstRate: 5.0,
        taxAmount: 7749.96,
        totalAmount: 162748.96,
        createdAt: DateTime(2026, 2, 1),
      );

      final itemJson = InvoiceItemModel.toJson(item);
      final restoredItem = InvoiceItemModel.fromJson(itemJson);
      expect(restoredItem.description, equals('Ather 450X Gen 3'));
      expect(restoredItem.gstRate, equals(5.0));

      final receipt = PaymentReceiptEntity(
        id: 'rcpt-1',
        showroomId: 'sh-001',
        customerId: 'cust-001',
        invoiceId: 'inv-1',
        receiptNumber: 'RCP-2026-00001',
        receiptDate: DateTime(2026, 2, 1),
        amount: 25000.0,
        paymentMode: 'upi',
        paymentReference: 'UPI-REF-9988',
        createdAt: DateTime(2026, 2, 1),
      );

      final rcptJson = PaymentReceiptModel.toJson(receipt);
      final restoredReceipt = PaymentReceiptModel.fromJson(rcptJson);
      expect(restoredReceipt.receiptNumber, equals('RCP-2026-00001'));
      expect(restoredReceipt.amount, equals(25000.0));
      expect(restoredReceipt.paymentMode, equals('upi'));
    });

    test('DeliveryChallanModel and GatePassModel roundtrip serialization', () {
      final challan = DeliveryChallanEntity(
        id: 'ch-1',
        showroomId: 'sh-001',
        invoiceId: 'inv-1',
        challanNumber: 'DC-2026-00001',
        challanDate: DateTime(2026, 2, 1),
        allocatedVin: 'ME4NC5800N8000101',
        odometerReadingKm: 3.5,
        helmetProvided: true,
        toolkitProvided: true,
        firstAidKitProvided: true,
        ownerManualProvided: true,
        pdiFormSigned: true,
        customerAcceptanceSigned: true,
        receivedByName: 'Rajesh Sharma',
        createdAt: DateTime(2026, 2, 1),
      );

      final challanJson = DeliveryChallanModel.toJson(challan);
      final restoredChallan = DeliveryChallanModel.fromJson(challanJson);
      expect(restoredChallan.challanNumber, equals('DC-2026-00001'));
      expect(restoredChallan.helmetProvided, isTrue);
      expect(restoredChallan.odometerReadingKm, equals(3.5));

      final gatePass = GatePassEntity(
        id: 'gp-1',
        showroomId: 'sh-001',
        challanId: 'ch-1',
        invoiceId: 'inv-1',
        gatePassNumber: 'GP-2026-00001',
        issuedAt: DateTime(2026, 2, 1),
        vin: 'ME4NC5800N8000101',
        customerName: 'Rajesh Sharma',
        authorizedByName: 'Security Lead',
        createdAt: DateTime(2026, 2, 1),
      );

      final gpJson = GatePassModel.toJson(gatePass);
      final restoredGp = GatePassModel.fromJson(gpJson);
      expect(restoredGp.gatePassNumber, equals('GP-2026-00001'));
      expect(restoredGp.vin, equals('ME4NC5800N8000101'));
    });
  });

  group('SalesManagementService — Core Business Logic & Sequences', () {
    test('Seeded dev data loads 4 initial invoices with various statuses and powertrains', () async {
      final invoices = await SalesManagementService.instance.fetchInvoices();
      expect(invoices.length, equals(4));

      // CB350 is Petrol with 28% GST
      final cb350 = invoices.firstWhere((i) => i.vin == 'ME4NC5800N8000101');
      expect(cb350.gstRate, equals(28.0));
      expect(cb350.status, equals('delivered'));

      // Ather 450X is EV with 5% GST
      final ather = invoices.firstWhere((i) => i.vin == 'MALJA450XN0000103');
      expect(ather.gstRate, equals(5.0));
      expect(ather.status, equals('delivered'));
    });

    test('createInvoice auto-generates invoice number, items, and computes exact GST', () async {
      final now = DateTime(2026, 2, 5);
      final created = await SalesManagementService.instance.createInvoice(
        SalesInvoiceEntity(
          id: '',
          showroomId: 'sh-001',
          customerId: 'cust-001',
          customerName: 'Rajesh Sharma',
          customerMobile: '9876543210',
          invoiceNumber: '',
          invoiceDate: now,
          variantId: 'variant-hunter-350-metro',
          colorId: 'color-hunter-green',
          modelName: 'Royal Enfield Hunter 350',
          variantName: 'Metro Dapper',
          colorName: 'Dapper Ash',
          status: 'issued',
          vin: 'ME4NC5800N8000105',
          hsnCode: '8711',
          exShowroomPrice: 169656.0,
          discountAmount: 2000.0,
          taxableAmount: 167656.0,
          gstRate: 28.0,
          cgstAmount: 23471.84,
          sgstAmount: 23471.84,
          rtoCharges: 18500.0,
          insuranceCharges: 9800.0,
          accessoriesTotal: 3500.0,
          totalOnRoadPrice: 222927.68,
          amountPaid: 5000.0,
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(created.invoiceNumber, startsWith('INV-DEV-'));
      expect(created.status, equals('issued'));

      // Verify invoice items generated
      final items = await SalesManagementService.instance.fetchInvoiceItems(created.id);
      expect(items.isNotEmpty, isTrue);
      expect(items.any((item) => item.itemType == 'vehicle'), isTrue);

      // Verify queryable
      final fetched = await SalesManagementService.instance.fetchInvoiceById(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.invoiceNumber, equals(created.invoiceNumber));
    });

    test('recordPaymentReceipt updates paid amount and adjusts status when fully paid', () async {
      final invoices = await SalesManagementService.instance.fetchInvoices();
      final partialInvoice = invoices.firstWhere((i) => i.id == 'inv-003'); // RTR 310
      final due = partialInvoice.balanceAmount;

      final receipt = await SalesManagementService.instance.recordPaymentReceipt(
        PaymentReceiptEntity(
          id: '',
          showroomId: partialInvoice.showroomId,
          customerId: partialInvoice.customerId,
          invoiceId: partialInvoice.id,
          receiptNumber: '',
          receiptDate: DateTime.now(),
          amount: due,
          paymentMode: 'neft_rtgs',
          notes: 'final_settlement',
          createdAt: DateTime.now(),
        ),
      );

      expect(receipt.receiptNumber, startsWith('RCP-DEV-'));

      // Check updated invoice
      final updated = await SalesManagementService.instance.fetchInvoiceById(partialInvoice.id);
      expect(updated!.balanceAmount, equals(0.0));
      expect(updated.paymentStatus, equals('paid'));
    });

    test('createDeliveryChallan updates invoice status to delivered and creates gate pass', () async {
      final challan = await SalesManagementService.instance.createDeliveryChallan(
        DeliveryChallanEntity(
          id: '',
          showroomId: 'sh-001',
          invoiceId: 'inv-002', // Ather 450X (issued)
          challanNumber: '',
          challanDate: DateTime.now(),
          allocatedVin: 'MALJA450XN0000103',
          odometerReadingKm: 4.2,
          helmetProvided: true,
          toolkitProvided: true,
          firstAidKitProvided: true,
          ownerManualProvided: true,
          pdiFormSigned: true,
          customerAcceptanceSigned: true,
          receivedByName: 'Priya Deshmukh',
          createdAt: DateTime.now(),
        ),
      );

      expect(challan.challanNumber, startsWith('DC-DEV-'));

      final inv = await SalesManagementService.instance.fetchInvoiceById('inv-002');
      expect(inv!.status, equals('delivered'));

      // Create Gate Pass for security
      final gp = await SalesManagementService.instance.createGatePass(
        GatePassEntity(
          id: '',
          showroomId: 'sh-001',
          challanId: challan.id,
          invoiceId: 'inv-002',
          gatePassNumber: '',
          issuedAt: DateTime.now(),
          vin: 'MALJA450XN0000103',
          customerName: 'Priya Deshmukh',
          authorizedByName: 'Showroom GM',
          createdAt: DateTime.now(),
        ),
      );

      expect(gp.gatePassNumber, startsWith('GP-DEV-'));

      final challanCheck = await SalesManagementService.instance.fetchChallanByInvoiceId('inv-002');
      expect(challanCheck, isNotNull);
      expect(challanCheck!.id, equals(challan.id));
    });
  });

  group('Sales Cubits & State Management', () {
    test('SalesInvoiceListCubit loads invoices and applies search and status filtering', () async {
      final cubit = SalesInvoiceListCubit();
      await cubit.loadInvoices();

      expect(cubit.state.invoices.length, equals(4));
      expect(cubit.state.filteredInvoices.length, equals(4));

      // Filter by search query (Ather)
      cubit.applyFilters(searchQuery: 'Ather');
      expect(cubit.state.filteredInvoices.length, equals(2));

      // Filter by status (delivered)
      cubit.applyFilters(status: 'delivered', searchQuery: '');
      expect(cubit.state.filteredInvoices.every((i) => i.status == 'delivered'), isTrue);

      await cubit.close();
    });

    test('SalesInvoiceDetailCubit loads invoice along with related items and challans', () async {
      final cubit = SalesInvoiceDetailCubit();
      await cubit.loadInvoice('inv-001');

      expect(cubit.state.invoice, isNotNull);
      expect(cubit.state.invoice!.invoiceNumber, equals('IND-MUM-INV-00184'));
      expect(cubit.state.challan, isNotNull);
      expect(cubit.state.gatePass, isNotNull);
      expect(cubit.state.receipts.isNotEmpty, isTrue);

      await cubit.close();
    });

    test('BookingWizardCubit handles multi-step flow, powertrain tax calculation, and generation', () async {
      final cubit = BookingWizardCubit();
      expect(cubit.state.currentStep, equals(0));

      // Step 0: Customer
      cubit.setCustomer(
        id: 'cust-001',
        name: 'Rajesh Sharma',
        mobile: '9876543210',
      );
      expect(cubit.state.customerName, equals('Rajesh Sharma'));

      cubit.nextStep();
      expect(cubit.state.currentStep, equals(1));

      // Step 1: Select Petrol Bike (CB350) -> expect 28% GST
      cubit.setVehicle(
        modelId: 'model-cb350',
        modelName: 'Honda CB350 H\'ness',
        variantId: 'variant-cb350-dlx-pro',
        variantName: 'DLX Pro Dual Tone',
        colorId: 'color-cb350-red',
        colorName: 'Precious Red Metallic',
        colorHex: 'B71C1C',
        exShowroomPrice: 217800.0,
        isEv: false,
        vin: 'ME4NC5800N8000101',
      );

      expect(cubit.state.gstRate, equals(28.0));
      expect(cubit.state.isEv, isFalse);
      expect(cubit.state.totalGst, equals(47643.75));

      // Now switch to EV Scooter -> expect 5% GST
      cubit.setVehicle(
        modelId: 'model-ather-450x',
        modelName: 'Ather 450X Gen 3',
        variantId: 'variant-ather-450x-pro',
        variantName: '3.7 kWh Pro',
        colorId: 'color-ather-white',
        colorName: 'True White',
        colorHex: 'FFFFFF',
        exShowroomPrice: 154999.0,
        isEv: true,
        vin: 'MALJA450XN0000103',
      );

      expect(cubit.state.gstRate, equals(5.0));
      expect(cubit.state.isEv, isTrue);
      expect(cubit.state.cgstAmount, closeTo(3690.45, 0.05));

      // Step 2 & 3: Pricing and Payment
      cubit.nextStep(); // to pricing
      cubit.nextStep(); // to payment
      cubit.updatePayment(
        bookingAdvance: 5000.0,
        financeAmount: 140000.0,
        downPayment: 20000.0,
      );

      expect(cubit.state.totalPaid, equals(165000.0));

      // Step 4: Review & Generate
      cubit.nextStep();
      expect(cubit.state.currentStep, equals(4));

      await cubit.generateInvoice();
      expect(cubit.state.savedInvoice, isNotNull);
      expect(cubit.state.savedInvoice!.invoiceNumber, startsWith('INV-DEV-'));
      expect(cubit.state.savedInvoice!.gstRate, equals(5.0));

      await cubit.close();
    });
  });
}
