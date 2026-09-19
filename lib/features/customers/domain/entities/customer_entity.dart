import 'package:equatable/equatable.dart';

/// Customer Master Domain Entity
///
/// Represents a customer record in the Indian two-wheeler dealership context.
/// Tracks personal identity, contact details, address (Indian format),
/// KYC verification status, and customer classification.
class CustomerEntity extends Equatable {
  final String id;
  final String showroomId;
  final String customerNumber; // e.g. "CUST-IND-MAIN-0001"
  final String firstName;
  final String lastName;
  final String mobilePrimary; // 10-digit Indian mobile
  final String? mobileSecondary;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender; // 'male', 'female', 'other', 'prefer_not_to_say'
  // Indian Address
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? pinCode;
  final String? landmark;
  // KYC Workflow
  final String kycStatus; // 'pending', 'partial', 'verified', 'rejected'
  final String? kycVerifiedBy;
  final DateTime? kycVerifiedAt;
  // Classification
  final String customerType; // 'individual', 'corporate', 'fleet'
  final String? source;
  final String? preferredContactMethod;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerEntity({
    required this.id,
    required this.showroomId,
    required this.customerNumber,
    required this.firstName,
    required this.lastName,
    required this.mobilePrimary,
    this.mobileSecondary,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.pinCode,
    this.landmark,
    this.kycStatus = 'pending',
    this.kycVerifiedBy,
    this.kycVerifiedAt,
    this.customerType = 'individual',
    this.source,
    this.preferredContactMethod = 'phone',
    this.isActive = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // ─── Computed Helpers ───

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  bool get isKycVerified => kycStatus == 'verified';
  bool get isKycPending => kycStatus == 'pending';
  bool get isKycPartial => kycStatus == 'partial';
  bool get isKycRejected => kycStatus == 'rejected';

  bool get isIndividual => customerType == 'individual';
  bool get isCorporate => customerType == 'corporate';
  bool get isFleet => customerType == 'fleet';

  /// Mask mobile number: "98XXXX5678" → "98****5678"
  String get maskedMobile {
    if (mobilePrimary.length < 10) return mobilePrimary;
    return '${mobilePrimary.substring(0, 2)}****${mobilePrimary.substring(mobilePrimary.length - 4)}';
  }

  /// Formatted full address
  String get fullAddress {
    final parts = <String>[
      if (addressLine1 != null && addressLine1!.isNotEmpty) addressLine1!,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      if (landmark != null && landmark!.isNotEmpty) 'Near $landmark',
      if (city != null && city!.isNotEmpty) city!,
      if (state != null && state!.isNotEmpty) state!,
      if (pinCode != null && pinCode!.isNotEmpty) '- $pinCode',
    ];
    return parts.join(', ');
  }

  /// KYC status display label
  String get kycStatusLabel {
    switch (kycStatus) {
      case 'verified':
        return 'KYC Verified';
      case 'partial':
        return 'KYC Partial';
      case 'rejected':
        return 'KYC Rejected';
      case 'pending':
      default:
        return 'KYC Pending';
    }
  }

  /// Customer type display label
  String get customerTypeLabel {
    switch (customerType) {
      case 'corporate':
        return 'Corporate';
      case 'fleet':
        return 'Fleet';
      case 'individual':
      default:
        return 'Individual';
    }
  }

  /// Source display label
  String get sourceLabel {
    switch (source) {
      case 'walk_in':
        return 'Walk-in';
      case 'phone_call':
        return 'Phone Call';
      case 'website':
        return 'Website';
      case 'social_media':
        return 'Social Media';
      case 'oem_referral':
        return 'OEM Referral';
      case 'exchange_inquiry':
        return 'Exchange Inquiry';
      case 'corporate_tieup':
        return 'Corporate Tie-up';
      case 'auto_expo':
        return 'Auto Expo';
      case 'existing_customer':
        return 'Existing Customer';
      default:
        return source ?? 'Unknown';
    }
  }

  /// Days since customer was created
  int get daysSinceCreation => DateTime.now().difference(createdAt).inDays;

  CustomerEntity copyWith({
    String? id,
    String? showroomId,
    String? customerNumber,
    String? firstName,
    String? lastName,
    String? mobilePrimary,
    String? mobileSecondary,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pinCode,
    String? landmark,
    String? kycStatus,
    String? kycVerifiedBy,
    DateTime? kycVerifiedAt,
    String? customerType,
    String? source,
    String? preferredContactMethod,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      showroomId: showroomId ?? this.showroomId,
      customerNumber: customerNumber ?? this.customerNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobilePrimary: mobilePrimary ?? this.mobilePrimary,
      mobileSecondary: mobileSecondary ?? this.mobileSecondary,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      landmark: landmark ?? this.landmark,
      kycStatus: kycStatus ?? this.kycStatus,
      kycVerifiedBy: kycVerifiedBy ?? this.kycVerifiedBy,
      kycVerifiedAt: kycVerifiedAt ?? this.kycVerifiedAt,
      customerType: customerType ?? this.customerType,
      source: source ?? this.source,
      preferredContactMethod: preferredContactMethod ?? this.preferredContactMethod,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        showroomId,
        customerNumber,
        firstName,
        lastName,
        mobilePrimary,
        mobileSecondary,
        email,
        dateOfBirth,
        gender,
        addressLine1,
        addressLine2,
        city,
        state,
        pinCode,
        landmark,
        kycStatus,
        kycVerifiedBy,
        kycVerifiedAt,
        customerType,
        source,
        preferredContactMethod,
        isActive,
        notes,
        createdAt,
        updatedAt,
      ];
}
