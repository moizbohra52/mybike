import 'package:equatable/equatable.dart';

/// Customer KYC Document Domain Entity
///
/// Represents an identity document attached to a customer for KYC verification.
/// Supports Indian regulatory documents: Aadhaar, PAN, Driving License, Voter ID, Passport.
class CustomerDocumentEntity extends Equatable {
  final String id;
  final String customerId;
  final String documentType; // 'aadhaar', 'pan', 'driving_license', etc.
  final String? documentNumber; // Masked reference
  final String fileName;
  final String? fileUrl;
  final int fileSizeBytes;
  final String mimeType;
  final String verificationStatus; // 'pending', 'verified', 'rejected'
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final DateTime? expiryDate;
  final DateTime createdAt;

  const CustomerDocumentEntity({
    required this.id,
    required this.customerId,
    required this.documentType,
    this.documentNumber,
    required this.fileName,
    this.fileUrl,
    this.fileSizeBytes = 0,
    this.mimeType = 'application/pdf',
    this.verificationStatus = 'pending',
    this.verifiedBy,
    this.verifiedAt,
    this.rejectionReason,
    this.expiryDate,
    required this.createdAt,
  });

  // ─── Computed Helpers ───

  bool get isVerified => verificationStatus == 'verified';
  bool get isPending => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';

  /// Check if document has expired (for DL, Passport)
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Human-readable document type label
  String get documentTypeLabel {
    switch (documentType) {
      case 'aadhaar':
        return 'Aadhaar Card';
      case 'pan':
        return 'PAN Card';
      case 'driving_license':
        return 'Driving License';
      case 'voter_id':
        return 'Voter ID';
      case 'passport':
        return 'Passport';
      case 'address_proof':
        return 'Address Proof';
      case 'photo':
        return 'Photograph';
      default:
        return 'Other Document';
    }
  }

  /// File size in human-readable format
  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) return '${fileSizeBytes}B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Verification status display label
  String get statusLabel {
    switch (verificationStatus) {
      case 'verified':
        return 'Verified';
      case 'rejected':
        return 'Rejected';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  /// Masked document number for display
  String get maskedNumber {
    if (documentNumber == null || documentNumber!.isEmpty) return '—';
    final num = documentNumber!;
    if (num.length <= 4) return num;
    final visible = num.substring(num.length - 4);
    final masked = 'X' * (num.length - 4);
    return '$masked$visible';
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        documentType,
        documentNumber,
        fileName,
        fileUrl,
        fileSizeBytes,
        mimeType,
        verificationStatus,
        verifiedBy,
        verifiedAt,
        rejectionReason,
        expiryDate,
        createdAt,
      ];
}
