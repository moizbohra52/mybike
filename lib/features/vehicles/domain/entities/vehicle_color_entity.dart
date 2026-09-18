import 'package:equatable/equatable.dart';

/// Vehicle Color Domain Entity
class VehicleColorEntity extends Equatable {
  final String id;
  final String modelId;
  final String name;
  final String code;
  final String hexCode;
  final double additionalPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleColorEntity({
    required this.id,
    required this.modelId,
    required this.name,
    required this.code,
    required this.hexCode,
    this.additionalPrice = 0.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  VehicleColorEntity copyWith({
    String? id,
    String? modelId,
    String? name,
    String? code,
    String? hexCode,
    double? additionalPrice,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleColorEntity(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      name: name ?? this.name,
      code: code ?? this.code,
      hexCode: hexCode ?? this.hexCode,
      additionalPrice: additionalPrice ?? this.additionalPrice,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        modelId,
        name,
        code,
        hexCode,
        additionalPrice,
        isActive,
        createdAt,
        updatedAt,
      ];
}
