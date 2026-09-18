import 'package:equatable/equatable.dart';

/// Document types supported for automated sequential numbering
enum DealershipDocType {
  saleInvoice('sale_invoice', 'Sales Invoice', 'INV'),
  booking('booking', 'Booking Order', 'BKG'),
  paymentReceipt('payment_receipt', 'Payment Receipt', 'RCP'),
  gatePass('gate_pass', 'Vehicle Gate Pass', 'GP'),
  deliveryChallan('delivery_challan', 'Delivery Challan', 'DC');

  final String key;
  final String label;
  final String defaultPrefix;

  const DealershipDocType(this.key, this.label, this.defaultPrefix);

  static DealershipDocType fromKey(String key) {
    return DealershipDocType.values.firstWhere(
      (e) => e.key == key,
      orElse: () => DealershipDocType.saleInvoice,
    );
  }
}

/// Invoice and Document Sequence Domain Entity
class InvoiceSequenceEntity extends Equatable {
  final String id;
  final String showroomId;
  final String? financialYearId;
  final String docType;
  final String prefix;
  final int currentNumber;
  final int paddingZeros;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvoiceSequenceEntity({
    required this.id,
    required this.showroomId,
    this.financialYearId,
    required this.docType,
    required this.prefix,
    this.currentNumber = 0,
    this.paddingZeros = 5,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Readable document type label
  String get docTypeLabel => DealershipDocType.fromKey(docType).label;

  /// Next sequential number
  int get nextNumber => currentNumber + 1;

  /// Formatted preview of the next document number (e.g. "MB-MUM-INV-00001")
  String get previewNextNumber {
    final padded = nextNumber.toString().padLeft(paddingZeros, '0');
    return '$prefix$padded';
  }

  InvoiceSequenceEntity copyWith({
    String? id,
    String? showroomId,
    String? financialYearId,
    String? docType,
    String? prefix,
    int? currentNumber,
    int? paddingZeros,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceSequenceEntity(
      id: id ?? this.id,
      showroomId: showroomId ?? this.showroomId,
      financialYearId: financialYearId ?? this.financialYearId,
      docType: docType ?? this.docType,
      prefix: prefix ?? this.prefix,
      currentNumber: currentNumber ?? this.currentNumber,
      paddingZeros: paddingZeros ?? this.paddingZeros,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        showroomId,
        financialYearId,
        docType,
        prefix,
        currentNumber,
        paddingZeros,
        createdAt,
        updatedAt,
      ];
}
