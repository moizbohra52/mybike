import '../../domain/entities/customer_entity.dart';

/// Customer Data Model — Supabase JSON ↔ Entity mapper
class CustomerModel {
  const CustomerModel._();

  static CustomerEntity fromJson(Map<String, dynamic> json) {
    return CustomerEntity(
      id: json['id'] as String,
      showroomId: json['showroom_id'] as String,
      customerNumber: json['customer_number'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      mobilePrimary: json['mobile_primary'] as String,
      mobileSecondary: json['mobile_secondary'] as String?,
      email: json['email'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      addressLine1: json['address_line_1'] as String?,
      addressLine2: json['address_line_2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pinCode: json['pin_code'] as String?,
      landmark: json['landmark'] as String?,
      kycStatus: json['kyc_status'] as String? ?? 'pending',
      kycVerifiedBy: json['kyc_verified_by'] as String?,
      kycVerifiedAt: json['kyc_verified_at'] != null
          ? DateTime.parse(json['kyc_verified_at'] as String)
          : null,
      customerType: json['customer_type'] as String? ?? 'individual',
      source: json['source'] as String?,
      preferredContactMethod: json['preferred_contact_method'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static Map<String, dynamic> toJson(CustomerEntity entity) {
    return {
      'id': entity.id,
      'showroom_id': entity.showroomId,
      'customer_number': entity.customerNumber,
      'first_name': entity.firstName,
      'last_name': entity.lastName,
      'mobile_primary': entity.mobilePrimary,
      'mobile_secondary': entity.mobileSecondary,
      'email': entity.email,
      'date_of_birth': entity.dateOfBirth?.toIso8601String().substring(0, 10),
      'gender': entity.gender,
      'address_line_1': entity.addressLine1,
      'address_line_2': entity.addressLine2,
      'city': entity.city,
      'state': entity.state,
      'pin_code': entity.pinCode,
      'landmark': entity.landmark,
      'kyc_status': entity.kycStatus,
      'kyc_verified_by': entity.kycVerifiedBy,
      'kyc_verified_at': entity.kycVerifiedAt?.toIso8601String(),
      'customer_type': entity.customerType,
      'source': entity.source,
      'preferred_contact_method': entity.preferredContactMethod,
      'is_active': entity.isActive,
      'notes': entity.notes,
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),
    };
  }

  /// Partial JSON for create/update (excludes auto-generated fields)
  static Map<String, dynamic> toInsertJson(CustomerEntity entity) {
    final json = toJson(entity);
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }
}
