import 'package:equatable/equatable.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/vehicle_catalog_item.dart';

enum VehicleCatalogStatus { initial, loading, success, failure }

class VehicleCatalogState extends Equatable {
  final VehicleCatalogStatus status;
  final List<VehicleCatalogItem> items;
  final List<BrandEntity> brands;
  final String? selectedBrandId;
  final String? selectedType; // null/'all', 'petrol', 'electric'
  final String searchQuery;
  final String? errorMessage;

  const VehicleCatalogState({
    this.status = VehicleCatalogStatus.initial,
    this.items = const [],
    this.brands = const [],
    this.selectedBrandId,
    this.selectedType,
    this.searchQuery = '',
    this.errorMessage,
  });

  int get totalModels => items.length;
  int get petrolCount => items.where((i) => i.model.isPetrol).length;
  int get electricCount => items.where((i) => i.model.isElectric).length;
  int get totalVariants => items.fold<int>(0, (sum, i) => sum + i.variantCount);

  VehicleCatalogState copyWith({
    VehicleCatalogStatus? status,
    List<VehicleCatalogItem>? items,
    List<BrandEntity>? brands,
    String? Function()? selectedBrandId,
    String? Function()? selectedType,
    String? searchQuery,
    String? Function()? errorMessage,
  }) {
    return VehicleCatalogState(
      status: status ?? this.status,
      items: items ?? this.items,
      brands: brands ?? this.brands,
      selectedBrandId: selectedBrandId != null ? selectedBrandId() : this.selectedBrandId,
      selectedType: selectedType != null ? selectedType() : this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        brands,
        selectedBrandId,
        selectedType,
        searchQuery,
        errorMessage,
      ];
}
