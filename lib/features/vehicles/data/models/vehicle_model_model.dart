import '../../domain/entities/vehicle_model_entity.dart';

/// Vehicle Model Data Model with JSON serialization for Supabase
class VehicleModelModel extends VehicleModelEntity {
  const VehicleModelModel({
    required super.id,
    required super.brandId,
    required super.name,
    required super.type,
    super.bodyType = 'commuter',
    super.description,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
  });

  factory VehicleModelModel.fromJson(Map<String, dynamic> json) {
    return VehicleModelModel(
      id: json['id'] as String,
      brandId: json['brand_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'petrol',
      bodyType: json['body_type'] as String? ?? 'commuter',
      description: json['description'] as String?,
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
      'brand_id': brandId,
      'name': name,
      'type': type,
      'body_type': bodyType,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory VehicleModelModel.fromEntity(VehicleModelEntity entity) {
    return VehicleModelModel(
      id: entity.id,
      brandId: entity.brandId,
      name: entity.name,
      type: entity.type,
      bodyType: entity.bodyType,
      description: entity.description,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
