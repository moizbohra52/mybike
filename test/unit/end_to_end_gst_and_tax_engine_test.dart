import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/gst_management_service.dart';
import 'package:mybike/features/gst/domain/entities/gst_rate_entity.dart';

void main() {
  group('Phase 25 — Unit Tests: End-to-End GST Tax Engine & Compliance', () {
    late GstManagementService gstService;

    setUp(() {
      gstService = GstManagementService();
      gstService.resetDevData();
    });

    test('1. Intra-State Petrol Two-Wheeler Tax Calculation (HSN 8711 @ 28%)', () {
      final result = gstService.calculateTax(
        baseAmount: 100000.0,
        discountAmount: 5000.0,
        hsnSacCode: '8711',
        isInterstate: false,
      );

      // Taxable = 100,000 - 5,000 = 95,000
      expect(result.taxableAmount, equals(95000.0));
      expect(result.gstRate, equals(28.0));
      // CGST 14% = 13,300, SGST 14% = 13,300
      expect(result.cgstAmount, equals(13300.0));
      expect(result.sgstAmount, equals(13300.0));
      expect(result.igstAmount, equals(0.0));
      expect(result.totalGstAmount, equals(26600.0));
      expect(result.finalTotal, equals(121600.0));
    });

    test('2. Inter-State Petrol Two-Wheeler Tax Calculation (IGST 28%)', () {
      final result = gstService.calculateTax(
        baseAmount: 150000.0,
        discountAmount: 0.0,
        hsnSacCode: '8711',
        isInterstate: true,
      );

      expect(result.taxableAmount, equals(150000.0));
      expect(result.cgstAmount, equals(0.0));
      expect(result.sgstAmount, equals(0.0));
      expect(result.igstAmount, equals(42000.0));
      expect(result.totalGstAmount, equals(42000.0));
      expect(result.finalTotal, equals(192000.0));
    });

    test('3. Electric Vehicle Concessional Tax Calculation (HSN 8711-EV @ 5%)', () {
      final result = gstService.calculateTax(
        baseAmount: 120000.0,
        discountAmount: 0.0,
        hsnSacCode: '8711-EV',
        isInterstate: false,
      );

      // 5% total -> CGST 2.5% = 3,000, SGST 2.5% = 3,000
      expect(result.taxableAmount, equals(120000.0));
      expect(result.gstRate, equals(5.0));
      expect(result.cgstAmount, equals(3000.0));
      expect(result.sgstAmount, equals(3000.0));
      expect(result.totalGstAmount, equals(6000.0));
      expect(result.finalTotal, equals(126000.0));
    });

    test('4. Spare Parts & Workshop Service Labor (HSN 8714 & SAC 9987 @ 18%)', () {
      final partsResult = gstService.calculateTax(
        baseAmount: 4000.0,
        discountAmount: 200.0,
        hsnSacCode: '8714',
        isInterstate: false,
      );

      // Taxable = 3,800 @ 18% = 684 (CGST 342 + SGST 342)
      expect(partsResult.taxableAmount, equals(3800.0));
      expect(partsResult.gstRate, equals(18.0));
      expect(partsResult.cgstAmount, equals(342.0));
      expect(partsResult.sgstAmount, equals(342.0));
      expect(partsResult.finalTotal, equals(4484.0));

      final laborResult = gstService.calculateTax(
        baseAmount: 1500.0,
        discountAmount: 0.0,
        hsnSacCode: '9987',
        isInterstate: false,
      );

      // Taxable = 1,500 @ 18% = 270 (CGST 135 + SGST 135)
      expect(laborResult.taxableAmount, equals(1500.0));
      expect(laborResult.cgstAmount, equals(135.0));
      expect(laborResult.sgstAmount, equals(135.0));
      expect(laborResult.finalTotal, equals(1770.0));
    });

    test('5. High Value Sale with TCS (Tax Collected at Source @ 1%)', () {
      final result = gstService.calculateTax(
        baseAmount: 200000.0,
        discountAmount: 0.0,
        hsnSacCode: '8711',
        isInterstate: false,
        tcsRate: 1.0,
      );

      // Taxable = 200,000, GST 28% = 56,000. Invoice total pre-TCS = 256,000
      // TCS 1% on 256,000 = 2,560.
      expect(result.taxableAmount, equals(200000.0));
      expect(result.totalGstAmount, equals(56000.0));
      expect(result.tcsAmount, equals(2560.0));
      expect(result.finalTotal, equals(258560.0));
    });

    test('6. Configurable GST Rates CRUD Lifecycle', () async {
      final initialRates = await gstService.getTaxRates();
      expect(initialRates.isNotEmpty, isTrue);

      final newRate = GstRateEntity.standard(
        id: 'rate-custom-test',
        taxName: 'EV Battery Pack',
        hsnSacCode: '8507',
        totalGstRate: 18.0,
        cessRate: 0.0,
        category: 'battery',
        description: 'Lithium-ion replacement traction battery',
        effectiveFrom: DateTime.now(),
        isActive: true,
      );

      final savedRate = await gstService.saveTaxRate(newRate);
      expect(savedRate.id, equals('rate-custom-test'));

      final updatedRates = await gstService.getTaxRates();
      expect(updatedRates.any((r) => r.hsnSacCode == '8507'), isTrue);

      final calculated = gstService.calculateTax(
        baseAmount: 50000.0,
        hsnSacCode: '8507',
        customGstRate: 18.0,
      );
      expect(calculated.totalGstAmount, equals(9000.0));

      final deleteSuccess = await gstService.deleteTaxRate('rate-custom-test');
      expect(deleteSuccess, isTrue);
    });

    test('7. GSTR-1 Outward Return Aggregation Structure', () async {
      final report = await gstService.generateGstr1Report(
        filingPeriod: '2026-09',
      );

      expect(report.filingPeriod, equals('2026-09'));
      expect(report.totalTaxableValue >= 0, isTrue);
      expect(report.hsnSummary, isNotNull);
      expect(report.totalInvoiceValue >= 0, isTrue);
    });

    test('8. GSTR-3B Monthly Return Reconciliation', () async {
      final gstr3b = await gstService.generateGstr3bReport(
        filingPeriod: '2026-09',
      );

      expect(gstr3b.filingPeriod, equals('2026-09'));
      expect(gstr3b.outwardSupplies, isNotNull);
      expect(gstr3b.eligibleItc, isNotNull);
      expect(gstr3b.taxPayments, isNotNull);
      // Net tax payable = Outward liability - Eligible ITC
      final expectedNet = gstr3b.totalOutwardTax - gstr3b.totalEligibleItc;
      expect(gstr3b.netCashPayable, closeTo(expectedNet < 0 ? 0.0 : expectedNet, 0.01));
    });
  });
}
