import 'package:equatable/equatable.dart';
import '../../domain/entities/sales_invoice_entity.dart';
import '../../domain/entities/payment_receipt_entity.dart';
import '../../domain/entities/delivery_challan_entity.dart';
import '../../domain/entities/gate_pass_entity.dart';

class SalesInvoiceDetailState extends Equatable {
  final bool isLoading;
  final String? error;
  final SalesInvoiceEntity? invoice;
  final List<PaymentReceiptEntity> receipts;
  final DeliveryChallanEntity? challan;
  final GatePassEntity? gatePass;

  const SalesInvoiceDetailState({
    this.isLoading = false,
    this.error,
    this.invoice,
    this.receipts = const [],
    this.challan,
    this.gatePass,
  });

  SalesInvoiceDetailState copyWith({
    bool? isLoading,
    String? error,
    SalesInvoiceEntity? invoice,
    List<PaymentReceiptEntity>? receipts,
    DeliveryChallanEntity? challan,
    GatePassEntity? gatePass,
  }) {
    return SalesInvoiceDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      invoice: invoice ?? this.invoice,
      receipts: receipts ?? this.receipts,
      challan: challan ?? this.challan,
      gatePass: gatePass ?? this.gatePass,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        invoice,
        receipts,
        challan,
        gatePass,
      ];
}
