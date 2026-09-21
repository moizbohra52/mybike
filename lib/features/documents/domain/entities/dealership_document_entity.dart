import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Dealership Document Domain Entity
class DealershipDocumentEntity extends Equatable {
  final String id;
  final String? showroomId;
  final String entityType; // 'customer', 'vehicle', 'booking', 'invoice', 'purchase', 'showroom', 'general'
  final String entityId;
  final String documentCategory; // 'kyc', 'rto_registration', 'insurance', 'warranty', 'delivery', 'purchase_invoice', 'factory_gatepass', 'hypothecation', 'puc', 'other'
  final String documentType;
  final String? documentNumber;
  final String fileName;
  final String filePath;
  final int fileSize; // bytes
  final String mimeType;
  final String verificationStatus; // 'pending', 'verified', 'rejected', 'expired'
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final DateTime? expiryDate;
  final String? uploadedBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DealershipDocumentEntity({
    required this.id,
    this.showroomId,
    required this.entityType,
    required this.entityId,
    required this.documentCategory,
    required this.documentType,
    this.documentNumber,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.mimeType,
    this.verificationStatus = 'pending',
    this.verifiedBy,
    this.verifiedAt,
    this.rejectionReason,
    this.expiryDate,
    this.uploadedBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isVerified => verificationStatus == 'verified';
  bool get isPending => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';
  bool get isExpired => verificationStatus == 'expired';

  bool get isPdf => mimeType.contains('pdf') || fileName.toLowerCase().endsWith('.pdf');
  bool get isImage =>
      mimeType.contains('image') ||
      fileName.toLowerCase().endsWith('.jpg') ||
      fileName.toLowerCase().endsWith('.jpeg') ||
      fileName.toLowerCase().endsWith('.png');

  String get statusLabel {
    switch (verificationStatus) {
      case 'verified':
        return 'VERIFIED';
      case 'rejected':
        return 'REJECTED';
      case 'expired':
        return 'EXPIRED';
      case 'pending':
      default:
        return 'PENDING';
    }
  }

  Color get statusColor {
    switch (verificationStatus) {
      case 'verified':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'expired':
        return Colors.orangeAccent;
      case 'pending':
      default:
        return AppColors.primaryYellowDark;
    }
  }

  String get categoryLabel {
    switch (documentCategory) {
      case 'kyc':
        return 'Customer KYC';
      case 'rto_registration':
        return 'RTO Registration';
      case 'insurance':
        return 'Insurance Policy';
      case 'warranty':
        return 'Warranty & RSA';
      case 'delivery':
        return 'Delivery & Gate Pass';
      case 'purchase_invoice':
        return 'Purchase Invoice';
      case 'factory_gatepass':
        return 'OEM Gate Pass / LR';
      case 'hypothecation':
        return 'Hypothecation (HPA)';
      case 'puc':
        return 'PUC Certificate';
      case 'other':
      default:
        return 'General Document';
    }
  }

  IconData get categoryIcon {
    switch (documentCategory) {
      case 'kyc':
        return Icons.badge_outlined;
      case 'rto_registration':
        return Icons.description_outlined;
      case 'insurance':
        return Icons.shield_outlined;
      case 'warranty':
        return Icons.verified_user_outlined;
      case 'delivery':
        return Icons.local_shipping_outlined;
      case 'purchase_invoice':
        return Icons.receipt_long_outlined;
      case 'factory_gatepass':
        return Icons.departure_board_outlined;
      case 'hypothecation':
        return Icons.account_balance_outlined;
      case 'puc':
        return Icons.eco_outlined;
      case 'other':
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String get entityTypeLabel {
    switch (entityType) {
      case 'customer':
        return 'Customer';
      case 'vehicle':
        return 'Vehicle';
      case 'booking':
        return 'Booking';
      case 'invoice':
        return 'Sales Invoice';
      case 'purchase':
        return 'Purchase Order';
      case 'showroom':
        return 'Showroom Branch';
      case 'general':
      default:
        return 'General';
    }
  }

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  DealershipDocumentEntity copyWith({
    String? id,
    String? showroomId,
    String? entityType,
    String? entityId,
    String? documentCategory,
    String? documentType,
    String? documentNumber,
    String? fileName,
    String? filePath,
    int? fileSize,
    String? mimeType,
    String? verificationStatus,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? rejectionReason,
    DateTime? expiryDate,
    String? uploadedBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DealershipDocumentEntity(
      id: id ?? this.id,
      showroomId: showroomId ?? this.showroomId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      documentCategory: documentCategory ?? this.documentCategory,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      expiryDate: expiryDate ?? this.expiryDate,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        showroomId,
        entityType,
        entityId,
        documentCategory,
        documentType,
        documentNumber,
        fileName,
        filePath,
        fileSize,
        mimeType,
        verificationStatus,
        verifiedBy,
        verifiedAt,
        rejectionReason,
        expiryDate,
        uploadedBy,
        notes,
        createdAt,
        updatedAt,
      ];
}
