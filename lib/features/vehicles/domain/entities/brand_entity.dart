import 'package:equatable/equatable.dart';

/// Vehicle Manufacturer / Brand Domain Entity
class BrandEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String countryOfOrigin;
  final String? logoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BrandEntity({
    required this.id,
    required this.name,
    required this.code,
    this.countryOfOrigin = 'India',
    this.logoUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  BrandEntity copyWith({
    String? id,
    String? name,
    String? code,
    String? countryOfOrigin,
    String? logoUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BrandEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        countryOfOrigin,
        logoUrl,
        isActive,
        createdAt,
        updatedAt,
      ];
}
