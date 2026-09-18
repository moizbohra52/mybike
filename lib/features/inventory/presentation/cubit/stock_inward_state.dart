import 'package:equatable/equatable.dart';
import '../../../../core/services/inventory_management_service.dart';
import '../../../../core/services/showroom_management_service.dart';
import '../../../vehicles/domain/entities/vehicle_catalog_item.dart';

enum StockInwardStatus { initial, loading, submitting, success, failure }

class StockInwardState extends Equatable {
  final StockInwardStatus status;
  final List<ShowroomWithStats> showrooms;
  final List<VehicleCatalogItem> catalog;
  final String? selectedShowroomId;
  final String? selectedModelId;
  final String? selectedVariantId;
  final String? selectedColorId;
  final List<InwardVehicleUnit> units;
  final String? remarks;
  final String? errorMessage;

  const StockInwardState({
    this.status = StockInwardStatus.initial,
    this.showrooms = const [],
    this.catalog = const [],
    this.selectedShowroomId,
    this.selectedModelId,
    this.selectedVariantId,
    this.selectedColorId,
    this.units = const [],
    this.remarks,
    this.errorMessage,
  });

  VehicleCatalogItem? get currentCatalogItem =>
      catalog.where((c) => c.model.id == selectedModelId).firstOrNull;

  bool get isElectric => currentCatalogItem?.model.isElectric ?? false;

  StockInwardState copyWith({
    StockInwardStatus? status,
    List<ShowroomWithStats>? showrooms,
    List<VehicleCatalogItem>? catalog,
    String? Function()? selectedShowroomId,
    String? Function()? selectedModelId,
    String? Function()? selectedVariantId,
    String? Function()? selectedColorId,
    List<InwardVehicleUnit>? units,
    String? remarks,
    String? Function()? errorMessage,
  }) {
    return StockInwardState(
      status: status ?? this.status,
      showrooms: showrooms ?? this.showrooms,
      catalog: catalog ?? this.catalog,
      selectedShowroomId: selectedShowroomId != null ? selectedShowroomId() : this.selectedShowroomId,
      selectedModelId: selectedModelId != null ? selectedModelId() : this.selectedModelId,
      selectedVariantId: selectedVariantId != null ? selectedVariantId() : this.selectedVariantId,
      selectedColorId: selectedColorId != null ? selectedColorId() : this.selectedColorId,
      units: units ?? this.units,
      remarks: remarks ?? this.remarks,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        showrooms,
        catalog,
        selectedShowroomId,
        selectedModelId,
        selectedVariantId,
        selectedColorId,
        units,
        remarks,
        errorMessage,
      ];
}
