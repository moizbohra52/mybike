import 'package:equatable/equatable.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/vehicle_model_entity.dart';

enum VehicleFormStatus { initial, loading, submitting, success, failure }

class VehicleFormState extends Equatable {
  final VehicleFormStatus status;
  final VehicleModelEntity? initialModel;
  final List<BrandEntity> brands;
  final String? brandId;
  final String name;
  final String type; // 'petrol' | 'electric'
  final String bodyType; // 'commuter' | 'cruiser' | 'sports' | 'scooter' | 'adventure' | 'moped'
  final String description;
  final bool isActive;
  final String? errorMessage;
  final VehicleModelEntity? savedModel;

  const VehicleFormState({
    this.status = VehicleFormStatus.initial,
    this.initialModel,
    this.brands = const [],
    this.brandId,
    this.name = '',
    this.type = 'petrol',
    this.bodyType = 'commuter',
    this.description = '',
    this.isActive = true,
    this.errorMessage,
    this.savedModel,
  });

  bool get isEditing => initialModel != null;
  bool get isElectric => type == 'electric';

  VehicleFormState copyWith({
    VehicleFormStatus? status,
    VehicleModelEntity? initialModel,
    List<BrandEntity>? brands,
    String? Function()? brandId,
    String? name,
    String? type,
    String? bodyType,
    String? description,
    bool? isActive,
    String? Function()? errorMessage,
    VehicleModelEntity? savedModel,
  }) {
    return VehicleFormState(
      status: status ?? this.status,
      initialModel: initialModel ?? this.initialModel,
      brands: brands ?? this.brands,
      brandId: brandId != null ? brandId() : this.brandId,
      name: name ?? this.name,
      type: type ?? this.type,
      bodyType: bodyType ?? this.bodyType,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      savedModel: savedModel ?? this.savedModel,
    );
  }

  @override
  List<Object?> get props => [
        status,
        initialModel,
        brands,
        brandId,
        name,
        type,
        bodyType,
        description,
        isActive,
        errorMessage,
        savedModel,
      ];
}
