import 'package:equatable/equatable.dart';
import '../../domain/entities/vehicle_catalog_item.dart';

enum VehicleDetailStatus { initial, loading, success, failure }

class VehicleDetailState extends Equatable {
  final VehicleDetailStatus status;
  final VehicleCatalogItem? item;
  final String? errorMessage;
  final bool isActionInProgress;

  const VehicleDetailState({
    this.status = VehicleDetailStatus.initial,
    this.item,
    this.errorMessage,
    this.isActionInProgress = false,
  });

  VehicleDetailState copyWith({
    VehicleDetailStatus? status,
    VehicleCatalogItem? item,
    String? Function()? errorMessage,
    bool? isActionInProgress,
  }) {
    return VehicleDetailState(
      status: status ?? this.status,
      item: item ?? this.item,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
    );
  }

  @override
  List<Object?> get props => [status, item, errorMessage, isActionInProgress];
}
