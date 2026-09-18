import '../../domain/entities/vehicle_color_entity.dart';

/// Vehicle Color Data Model with JSON serialization for Supabase
class VehicleColorModel extends VehicleColorEntity {
  const VehicleColorModel({
    required super.id,
    required super.modelId,
    required super.name,
    required super.code,
    required super.hexCode,
    super.additionalPrice = 0.0,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
  });

  factory VehicleColorModel.fromJson(Map<String, dynamic> json) {
    return VehicleColorModel(
      id: json['id'] as String,
      modelId: json['model_id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      hexCode: json['hex_code'] as String? ?? '#000000',
      additionalPrice: (json['additional_price'] as num?)?.toDouble() ?? 0.0,
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
      'model_id': modelId,
      'name': name,
      'code': code,
      'hex_code': hexCode,
      'additional_price': additionalPrice,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory VehicleColorModel.fromEntity(VehicleColorEntity entity) {
    return VehicleColorModel(
      id: entity.id,
      modelId: entity.modelId,
      name: entity.name,
      code: entity.code,
      hexCode: entity.hexCode,
      additionalPrice: entity.additionalPrice,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
