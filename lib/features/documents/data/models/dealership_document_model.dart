import '../../domain/entities/dealership_document_entity.dart';

/// Dealership Document Data Model with Supabase JSON serialization
class DealershipDocumentModel extends DealershipDocumentEntity {
  const DealershipDocumentModel({
    required super.id,
    super.showroomId,
    required super.entityType,
    required super.entityId,
    required super.documentCategory,
    required super.documentType,
    super.documentNumber,
    required super.fileName,
    required super.filePath,
    required super.fileSize,
    required super.mimeType,
    super.verificationStatus = 'pending',
    super.verifiedBy,
    super.verifiedAt,
    super.rejectionReason,
    super.expiryDate,
    super.uploadedBy,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DealershipDocumentModel.fromJson(Map<String, dynamic> json) {
    return DealershipDocumentModel(
      id: json['id'] as String,
      showroomId: json['showroom_id'] as String?,
      entityType: json['entity_type'] as String? ?? 'general',
      entityId: json['entity_id'] as String? ?? '',
      documentCategory: json['document_category'] as String? ?? 'other',
      documentType: json['document_type'] as String? ?? '',
      documentNumber: json['document_number'] as String?,
      fileName: json['file_name'] as String? ?? '',
      filePath: json['file_path'] as String? ?? '',
      fileSize: (json['file_size'] as num?)?.toInt() ?? 0,
      mimeType: json['mime_type'] as String? ?? 'application/octet-stream',
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      verifiedBy: json['verified_by'] as String?,
      verifiedAt: json['verified_at'] != null ? DateTime.parse(json['verified_at'] as String) : null,
      rejectionReason: json['rejection_reason'] as String?,
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date'] as String) : null,
      uploadedBy: json['uploaded_by'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'showroom_id': showroomId,
      'entity_type': entityType,
      'entity_id': entityId,
      'document_category': documentCategory,
      'document_type': documentType,
      'document_number': documentNumber,
      'file_name': fileName,
      'file_path': filePath,
      'file_size': fileSize,
      'mime_type': mimeType,
      'verification_status': verificationStatus,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'expiry_date': expiryDate != null
          ? '${expiryDate!.year.toString().padLeft(4, '0')}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}'
          : null,
      'uploaded_by': uploadedBy,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DealershipDocumentModel.fromEntity(DealershipDocumentEntity entity) {
    return DealershipDocumentModel(
      id: entity.id,
      showroomId: entity.showroomId,
      entityType: entity.entityType,
      entityId: entity.entityId,
      documentCategory: entity.documentCategory,
      documentType: entity.documentType,
      documentNumber: entity.documentNumber,
      fileName: entity.fileName,
      filePath: entity.filePath,
      fileSize: entity.fileSize,
      mimeType: entity.mimeType,
      verificationStatus: entity.verificationStatus,
      verifiedBy: entity.verifiedBy,
      verifiedAt: entity.verifiedAt,
      rejectionReason: entity.rejectionReason,
      expiryDate: entity.expiryDate,
      uploadedBy: entity.uploadedBy,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
