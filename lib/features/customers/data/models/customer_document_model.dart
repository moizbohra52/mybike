import '../../domain/entities/customer_document_entity.dart';

/// Customer Document Data Model — Supabase JSON ↔ Entity mapper
class CustomerDocumentModel {
  const CustomerDocumentModel._();

  static CustomerDocumentEntity fromJson(Map<String, dynamic> json) {
    return CustomerDocumentEntity(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      documentType: json['document_type'] as String,
      documentNumber: json['document_number'] as String?,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String?,
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt() ?? 0,
      mimeType: json['mime_type'] as String? ?? 'application/pdf',
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      verifiedBy: json['verified_by'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> toJson(CustomerDocumentEntity entity) {
    return {
      'id': entity.id,
      'customer_id': entity.customerId,
      'document_type': entity.documentType,
      'document_number': entity.documentNumber,
      'file_name': entity.fileName,
      'file_url': entity.fileUrl,
      'file_size_bytes': entity.fileSizeBytes,
      'mime_type': entity.mimeType,
      'verification_status': entity.verificationStatus,
      'verified_by': entity.verifiedBy,
      'verified_at': entity.verifiedAt?.toIso8601String(),
      'rejection_reason': entity.rejectionReason,
      'expiry_date': entity.expiryDate?.toIso8601String().substring(0, 10),
      'created_at': entity.createdAt.toIso8601String(),
    };
  }
}
