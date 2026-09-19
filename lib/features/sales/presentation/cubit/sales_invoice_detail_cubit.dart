import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/sales_management_service.dart';
import 'sales_invoice_detail_state.dart';

/// Sales Invoice Detail Cubit
///
/// Loads the complete GST Tax Invoice dossier with receipts,
/// delivery challans, and gate passes.
class SalesInvoiceDetailCubit extends Cubit<SalesInvoiceDetailState> {
  final SalesManagementService _service;

  SalesInvoiceDetailCubit({SalesManagementService? service})
      : _service = service ?? SalesManagementService.instance,
        super(const SalesInvoiceDetailState());

  Future<void> loadInvoice(String invoiceId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final invoice = await _service.fetchInvoiceById(invoiceId);
      final receipts = await _service.fetchReceipts(invoiceId: invoiceId);
      final challans = await _service.fetchDeliveryChallans();
      final challan = challans.cast<dynamic>().firstWhere(
            (c) => c.invoiceId == invoiceId,
            orElse: () => null,
          );
      final gatePasses = await _service.fetchGatePasses();
      final gatePass = gatePasses.cast<dynamic>().firstWhere(
            (gp) => gp.invoiceId == invoiceId,
            orElse: () => null,
          );

      emit(state.copyWith(
        isLoading: false,
        invoice: invoice,
        receipts: receipts,
        challan: challan,
        gatePass: gatePass,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
