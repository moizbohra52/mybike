import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/accounting_management_service.dart';
import 'package:mybike/core/services/finance_management_service.dart';
import 'package:mybike/core/services/gst_management_service.dart';
import 'package:mybike/core/services/sales_management_service.dart';
import 'package:mybike/features/gst/data/models/gst_rate_model.dart';
import 'package:mybike/features/gst/domain/entities/gst_rate_entity.dart';
import 'package:mybike/features/gst/domain/entities/tax_calculation_result.dart';
import 'package:mybike/features/gst/presentation/cubit/gst_dashboard_cubit.dart';
import 'package:mybike/features/gst/presentation/cubit/gst_dashboard_state.dart';
import 'package:mybike/features/gst/presentation/cubit/gst_rate_config_cubit.dart';
import 'package:mybike/features/gst/presentation/cubit/gst_rate_config_state.dart';
import 'package:mybike/features/gst/presentation/cubit/gstr1_report_cubit.dart';
import 'package:mybike/features/gst/presentation/cubit/gstr1_report_state.dart';
import 'package:mybike/features/gst/presentation/cubit/gstr3b_report_cubit.dart';
import 'package:mybike/features/gst/presentation/cubit/gstr3b_report_state.dart';

void main() {
  late GstManagementService gstService;
  late AccountingManagementService accountingService;
  late SalesManagementService salesService;
  late FinanceManagementService financeService;

  setUp(() {
    accountingService = AccountingManagementService.instance;
    accountingService.resetDevData();

    salesService = SalesManagementService.instance;
    salesService.resetDevData();

    financeService = FinanceManagementService.instance;
    financeService.resetDevData();

    gstService = GstManagementService();
    gstService.resetDevData();
  });

  group('GST Domain & Entity Tests', () {
    test('GstRateEntity.standard splits CGST and SGST 50:50', () {
      final rate = GstRateEntity.standard(
        id: 'test-rate-1',
        taxName: 'Test Vehicle Tax',
        hsnSacCode: '8711',
        totalGstRate: 28.0,
        category: 'vehicle_ice',
        effectiveFrom: DateTime(2026, 1, 1),
      );

      expect(rate.gstRate, 28.0);
      expect(rate.cgstRate, 14.0);
      expect(rate.sgstRate, 14.0);
      expect(rate.igstRate, 28.0);
      expect(rate.categoryLabel, 'Petrol Vehicle');
    });

    test('GstRateModel serializes and deserializes JSON correctly', () {
      final rate = GstRateEntity.standard(
        id: 'test-rate-model',
        taxName: 'EV Green Tax',
        hsnSacCode: '8711-EV',
        totalGstRate: 5.0,
        category: 'vehicle_ev',
        effectiveFrom: DateTime(2026, 1, 1),
      );

      final model = GstRateModel.fromEntity(rate);
      final json = model.toJson();

      expect(json['hsn_sac_code'], '8711-EV');
      expect(json['gst_rate'], 5.0);
      expect(json['cgst_rate'], 2.5);
      expect(json['sgst_rate'], 2.5);

      final restored = GstRateModel.fromJson(json);
      expect(restored.id, rate.id);
      expect(restored.taxName, rate.taxName);
      expect(restored.gstRate, 5.0);
    });
  });

  group('High-Precision Tax Calculation Engine Tests', () {
    test('Intra-state Petrol Vehicle (28% GST) computes 14% CGST and 14% SGST', () {
      final result = TaxCalculationResult.compute(
        baseAmount: 100000.0,
        discountAmount: 0.0,
        hsnSacCode: '8711',
        gstRate: 28.0,
        isInterstate: false,
      );

      expect(result.taxableAmount, 100000.0);
      expect(result.cgstAmount, 14000.0);
      expect(result.sgstAmount, 14000.0);
      expect(result.igstAmount, 0.0);
      expect(result.totalGstAmount, 28000.0);
      expect(result.finalTotal, 128000.0);
      expect(result.roundOff, 0.0);
    });

    test('Inter-state Petrol Vehicle computes 28% IGST with zero CGST/SGST', () {
      final result = TaxCalculationResult.compute(
        baseAmount: 100000.0,
        discountAmount: 0.0,
        hsnSacCode: '8711',
        gstRate: 28.0,
        isInterstate: true,
      );

      expect(result.taxableAmount, 100000.0);
      expect(result.cgstAmount, 0.0);
      expect(result.sgstAmount, 0.0);
      expect(result.igstAmount, 28000.0);
      expect(result.totalGstAmount, 28000.0);
      expect(result.finalTotal, 128000.0);
    });

    test('Electric Vehicle (EV) computes concessional 5% GST (2.5% CGST + 2.5% SGST)', () {
      final result = TaxCalculationResult.compute(
        baseAmount: 150000.0,
        discountAmount: 5000.0,
        hsnSacCode: '8711-EV',
        gstRate: 5.0,
        isInterstate: false,
      );

      expect(result.taxableAmount, 145000.0);
      expect(result.cgstAmount, 3625.0); // 145,000 * 2.5%
      expect(result.sgstAmount, 3625.0); // 145,000 * 2.5%
      expect(result.totalGstAmount, 7250.0);
      expect(result.finalTotal, 152250.0);
    });

    test('Spare parts & accessories (18% GST) computes 9% CGST + 9% SGST', () {
      final result = TaxCalculationResult.compute(
        baseAmount: 10000.0,
        hsnSacCode: '8714',
        gstRate: 18.0,
        isInterstate: false,
      );

      expect(result.taxableAmount, 10000.0);
      expect(result.cgstAmount, 900.0);
      expect(result.sgstAmount, 900.0);
      expect(result.totalGstAmount, 1800.0);
      expect(result.finalTotal, 11800.0);
    });

    test('Section 206C TCS and Mathematical Round-off function properly', () {
      // Base amount that produces fractional paise
      final result = TaxCalculationResult.compute(
        baseAmount: 85243.65,
        discountAmount: 1200.0,
        hsnSacCode: '8711',
        gstRate: 28.0,
        isInterstate: false,
        tcsRate: 0.1, // 0.1% TCS
      );

      // Verify subtotal + roundOff == finalTotal
      expect(
        (result.subtotalBeforeRoundOff + result.roundOff).toStringAsFixed(2),
        result.finalTotal.toStringAsFixed(2),
      );
      // Verify finalTotal is rounded to nearest integer
      expect(result.finalTotal % 1.0, 0.0);
      expect(result.tcsAmount, greaterThan(0.0));
    });
  });

  group('GstManagementService Core Operations', () {
    test('getTaxRates returns standard statutory dealership slabs', () async {
      final rates = await gstService.getTaxRates();
      expect(rates.length, greaterThanOrEqualTo(5));

      final petrol = rates.firstWhere((r) => r.hsnSacCode == '8711');
      expect(petrol.gstRate, 28.0);

      final ev = rates.firstWhere((r) => r.hsnSacCode == '8711-EV');
      expect(ev.gstRate, 5.0);

      final spares = rates.firstWhere((r) => r.hsnSacCode == '8714');
      expect(spares.gstRate, 18.0);
    });

    test('saveTaxRate adds and updates tax slabs', () async {
      final newSlab = GstRateEntity.standard(
        id: 'slab-test-helmets',
        taxName: 'ISI Certified Helmets',
        hsnSacCode: '6506',
        totalGstRate: 18.0,
        category: 'accessories',
        effectiveFrom: DateTime(2026, 1, 1),
      );

      await gstService.saveTaxRate(newSlab);
      final fetched = await gstService.getRateForHsn('6506');
      expect(fetched, isNotNull);
      expect(fetched!.taxName, 'ISI Certified Helmets');
      expect(fetched.gstRate, 18.0);

      // Update slab rate
      final updated = fetched.copyWith(gstRate: 12.0, cgstRate: 6.0, sgstRate: 6.0);
      await gstService.saveTaxRate(updated);

      final reFetched = await gstService.getRateForHsn('6506');
      expect(reFetched!.gstRate, 12.0);

      // Delete
      await gstService.deleteTaxRate('slab-test-helmets');
      final deleted = await gstService.getRateForHsn('6506');
      expect(deleted, isNull);
    });

    test('generateGstr1Report compiles outward supplies into statutory tables', () async {
      final report = await gstService.generateGstr1Report(filingPeriod: '2026-09');

      expect(report.gstin, '27AABCU9603R1ZM');
      expect(report.filingPeriod, '2026-09');
      expect(report.totalTaxableValue, greaterThan(0.0));
      expect(report.totalCgstAmount, greaterThan(0.0));
      expect(report.totalSgstAmount, greaterThan(0.0));
      expect(report.hsnSummary, isNotEmpty);
      expect(report.docSummary, isNotEmpty);

      // Check HSN summary contains vehicle code 8711
      final hsn8711 = report.hsnSummary.where((h) => h.hsnSacCode == '8711');
      expect(hsn8711, isNotEmpty);
      expect(hsn8711.first.taxableValue, greaterThan(0.0));
    });

    test('generateGstr3bReport compiles Table 3.1, Table 4 ITC, and Table 6.1 Tax Payment', () async {
      final return3b = await gstService.generateGstr3bReport(filingPeriod: '2026-09');

      expect(return3b.filingPeriod, '2026-09');
      expect(return3b.outwardSupplies, isNotEmpty);
      expect(return3b.eligibleItc, isNotEmpty);
      expect(return3b.taxPayments, isNotEmpty);

      // Verify Table 3.1(a) has taxable value and tax
      final row31a = return3b.outwardSupplies.first;
      expect(row31a.totalTaxableValue, greaterThan(0.0));
      expect(row31a.centralTax, greaterThan(0.0));
      expect(row31a.stateTax, greaterThan(0.0));

      // Verify Eligible ITC is positive
      expect(return3b.totalEligibleItc, greaterThan(0.0));

      // Verify tax payments table
      expect(return3b.taxPayments.length, 3); // IGST, CGST, SGST
    });

    test('getGstSummary aggregates period KPIs and validates General Ledger reconciliation', () async {
      final summary = await gstService.getGstSummary(filingPeriod: '2026-09');

      expect(summary.totalOutwardTaxable, greaterThan(0.0));
      expect(summary.totalOutputTax, greaterThan(0.0));
      expect(summary.totalEligibleItc, greaterThan(0.0));
      expect(summary.glOutputTaxBalance, greaterThan(0.0));
      expect(summary.glInputTaxBalance, greaterThan(0.0));
      expect(summary.isGlReconciled, isTrue);
    });
  });

  group('GST Presentation Cubits Tests', () {
    test('GstDashboardCubit loads dashboard summary and changes filing period', () async {
      final cubit = GstDashboardCubit(service: gstService);

      expect(cubit.state.status, GstDashboardStatus.initial);

      await cubit.loadDashboard(period: '2026-09');

      expect(cubit.state.status, GstDashboardStatus.success);
      expect(cubit.state.summary, isNotNull);
      expect(cubit.state.selectedPeriod, '2026-09');
      expect(cubit.state.summary!.totalOutwardTaxable, greaterThan(0.0));

      // Change period
      await cubit.loadDashboard(period: '2026-08');
      expect(cubit.state.selectedPeriod, '2026-08');

      cubit.close();
    });

    test('GstRateConfigCubit filters by category, searches, and saves slab', () async {
      final cubit = GstRateConfigCubit(service: gstService);

      await cubit.loadRates();
      expect(cubit.state.status, GstRateConfigStatus.success);
      expect(cubit.state.rates.length, greaterThanOrEqualTo(5));

      // Filter by category
      cubit.filterByCategory('vehicle_ev');
      expect(cubit.state.filteredRates.every((r) => r.category == 'vehicle_ev'), isTrue);

      // Clear filter
      cubit.filterByCategory(null);
      expect(cubit.state.filteredRates.length, cubit.state.rates.length);

      // Search
      cubit.setSearchQuery('labor');
      expect(cubit.state.filteredRates.length, 1);
      expect(cubit.state.filteredRates.first.hsnSacCode, '9987');

      cubit.close();
    });

    test('Gstr1ReportCubit generates report, filters tabs, and changes period', () async {
      final cubit = Gstr1ReportCubit(service: gstService);

      await cubit.loadReport(period: '2026-09');
      expect(cubit.state.status, Gstr1ReportStatus.success);
      expect(cubit.state.report, isNotNull);
      expect(cubit.state.report!.b2cSmallInvoices, isNotEmpty);

      // Set active tab
      cubit.setTab(4); // Table 12 HSN Summary
      expect(cubit.state.activeTab, 4);

      await cubit.changePeriod('2026-08');
      expect(cubit.state.selectedPeriod, '2026-08');

      cubit.close();
    });

    test('Gstr3bReportCubit generates return and sets active section', () async {
      final cubit = Gstr3bReportCubit(service: gstService);

      await cubit.loadReport(period: '2026-09');
      expect(cubit.state.status, Gstr3bReportStatus.success);
      expect(cubit.state.report, isNotNull);
      expect(cubit.state.report!.outwardSupplies, isNotEmpty);

      cubit.setSection(1); // Table 4 Eligible ITC
      expect(cubit.state.activeSection, 1);

      cubit.close();
    });
  });
}
