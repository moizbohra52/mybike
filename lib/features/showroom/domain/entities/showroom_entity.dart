import 'package:equatable/equatable.dart';

/// Showroom / Dealership Branch Domain Entity
class ShowroomEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String phone;
  final String? email;
  final String? gstin;
  final String? pan;
  final String? logoUrl;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankIfsc;
  final String? bankBranch;
  final String invoicePrefix;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShowroomEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
    this.email,
    this.gstin,
    this.pan,
    this.logoUrl,
    this.bankName,
    this.bankAccountNumber,
    this.bankIfsc,
    this.bankBranch,
    this.invoicePrefix = 'MB',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullAddress => '$address, $city, $state - $pincode';

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        address,
        city,
        state,
        pincode,
        phone,
        email,
        gstin,
        pan,
        logoUrl,
        bankName,
        bankAccountNumber,
        bankIfsc,
        bankBranch,
        invoicePrefix,
        isActive,
        createdAt,
        updatedAt,
      ];
}
