import 'package:equatable/equatable.dart';
import 'brand_entity.dart';
import 'vehicle_color_entity.dart';
import 'vehicle_model_entity.dart';
import 'vehicle_variant_entity.dart';

/// Aggregated Vehicle Catalog Item representing a complete model
/// with its brand, available variants, and color options.
class VehicleCatalogItem extends Equatable {
  final VehicleModelEntity model;
  final BrandEntity? brand;
  final List<VehicleVariantEntity> variants;
  final List<VehicleColorEntity> colors;

  const VehicleCatalogItem({
    required this.model,
    this.brand,
    this.variants = const [],
    this.colors = const [],
  });

  /// Lowest ex-showroom price across all variants
  double get minPrice {
    if (variants.isEmpty) return 0.0;
    return variants
        .map((v) => v.exShowroomPrice)
        .reduce((a, b) => a < b ? a : b);
  }

  /// Highest ex-showroom price across all variants
  double get maxPrice {
    if (variants.isEmpty) return 0.0;
    return variants
        .map((v) => v.exShowroomPrice)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Lowest estimated on-road price across all variants
  double get minOnRoadPrice {
    if (variants.isEmpty) return 0.0;
    return variants
        .map((v) => v.estimatedOnRoadPrice)
        .reduce((a, b) => a < b ? a : b);
  }

  /// Total count of variants
  int get variantCount => variants.length;

  /// Total count of colors
  int get colorCount => colors.length;

  VehicleCatalogItem copyWith({
    VehicleModelEntity? model,
    BrandEntity? brand,
    List<VehicleVariantEntity>? variants,
    List<VehicleColorEntity>? colors,
  }) {
    return VehicleCatalogItem(
      model: model ?? this.model,
      brand: brand ?? this.brand,
      variants: variants ?? this.variants,
      colors: colors ?? this.colors,
    );
  }

  @override
  List<Object?> get props => [model, brand, variants, colors];
}
