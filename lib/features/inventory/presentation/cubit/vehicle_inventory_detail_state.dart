import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_movement_entity.dart';
import '../../domain/entities/vehicle_inventory_item.dart';

enum VehicleInventoryDetailStatus { initial, loading, success, failure }

class VehicleInventoryDetailState extends Equatable {
  final VehicleInventoryDetailStatus status;
  final VehicleInventoryItem? item;
  final List<StockMovementEntity> movements;
  final String? errorMessage;
  final bool isUpdating;

  const VehicleInventoryDetailState({
    this.status = VehicleInventoryDetailStatus.initial,
    this.item,
    this.movements = const [],
    this.errorMessage,
    this.isUpdating = false,
  });

  VehicleInventoryDetailState copyWith({
    VehicleInventoryDetailStatus? status,
    VehicleInventoryItem? item,
    List<StockMovementEntity>? movements,
    String? Function()? errorMessage,
    bool? isUpdating,
  }) {
    return VehicleInventoryDetailState(
      status: status ?? this.status,
      item: item ?? this.item,
      movements: movements ?? this.movements,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [status, item, movements, errorMessage, isUpdating];
}
