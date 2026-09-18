import 'package:equatable/equatable.dart';
import '../../../showroom/domain/entities/showroom_entity.dart';
import '../../../vehicles/domain/entities/brand_entity.dart';
import '../../../vehicles/domain/entities/vehicle_color_entity.dart';
import '../../../vehicles/domain/entities/vehicle_model_entity.dart';
import '../../../vehicles/domain/entities/vehicle_variant_entity.dart';
import 'inventory_vehicle_entity.dart';

/// Aggregated Vehicle Inventory Item with full related entities
class VehicleInventoryItem extends Equatable {
  final InventoryVehicleEntity vehicle;
  final VehicleModelEntity? model;
  final VehicleVariantEntity? variant;
  final BrandEntity? brand;
  final VehicleColorEntity? color;
  final ShowroomEntity? showroom;

  const VehicleInventoryItem({
    required this.vehicle,
    this.model,
    this.variant,
    this.brand,
    this.color,
    this.showroom,
  });

  String get displayName {
    final b = brand?.name ?? '';
    final m = model?.name ?? 'Vehicle';
    final v = variant?.name ?? '';
    return '$b $m $v'.trim();
  }

  bool get isElectric => model?.isElectric ?? vehicle.isElectric;
  bool get isPetrol => model?.isPetrol ?? vehicle.isPetrol;

  @override
  List<Object?> get props => [vehicle, model, variant, brand, color, showroom];
}
