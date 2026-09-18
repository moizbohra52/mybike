import 'package:equatable/equatable.dart';

/// Vehicle Model Domain Entity
class VehicleModelEntity extends Equatable {
  final String id;
  final String brandId;
  final String name;
  final String type; // 'petrol' | 'electric'
  final String bodyType; // 'commuter' | 'cruiser' | 'sports' | 'scooter' | 'adventure' | 'moped'
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleModelEntity({
    required this.id,
    required this.brandId,
    required this.name,
    required this.type,
    this.bodyType = 'commuter',
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isElectric => type.toLowerCase() == 'electric';
  bool get isPetrol => type.toLowerCase() == 'petrol';

  VehicleModelEntity copyWith({
    String? id,
    String? brandId,
    String? name,
    String? type,
    String? bodyType,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModelEntity(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      name: name ?? this.name,
      type: type ?? this.type,
      bodyType: bodyType ?? this.bodyType,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        brandId,
        name,
        type,
        bodyType,
        description,
        isActive,
        createdAt,
        updatedAt,
      ];
}
