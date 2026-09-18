import '../../domain/entities/brand_entity.dart';

/// Brand Model with JSON serialization for Supabase
class BrandModel extends BrandEntity {
  const BrandModel({
    required super.id,
    required super.name,
    required super.code,
    super.countryOfOrigin = 'India',
    super.logoUrl,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      countryOfOrigin: json['country_of_origin'] as String? ?? 'India',
      logoUrl: json['logo_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
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
      'name': name,
      'code': code,
      'country_of_origin': countryOfOrigin,
      'logo_url': logoUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BrandModel.fromEntity(BrandEntity entity) {
    return BrandModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      countryOfOrigin: entity.countryOfOrigin,
      logoUrl: entity.logoUrl,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
