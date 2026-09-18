import 'package:equatable/equatable.dart';
import '../../../../core/services/showroom_management_service.dart';
import '../../domain/entities/stock_transfer_entity.dart';
import '../../domain/entities/vehicle_inventory_item.dart';

enum StockTransferStatus { initial, loading, success, failure }

class StockTransferState extends Equatable {
  final StockTransferStatus status;
  final List<StockTransferEntity> transfers;
  final List<ShowroomWithStats> showrooms;
  final List<VehicleInventoryItem> availableVehicles;
  final String? selectedSourceShowroomId;
  final String? selectedDestShowroomId;
  final List<String> selectedVehicleIds;
  final String? notes;
  final String? errorMessage;
  final bool isSubmitting;

  const StockTransferState({
    this.status = StockTransferStatus.initial,
    this.transfers = const [],
    this.showrooms = const [],
    this.availableVehicles = const [],
    this.selectedSourceShowroomId,
    this.selectedDestShowroomId,
    this.selectedVehicleIds = const [],
    this.notes,
    this.errorMessage,
    this.isSubmitting = false,
  });

  StockTransferState copyWith({
    StockTransferStatus? status,
    List<StockTransferEntity>? transfers,
    List<ShowroomWithStats>? showrooms,
    List<VehicleInventoryItem>? availableVehicles,
    String? Function()? selectedSourceShowroomId,
    String? Function()? selectedDestShowroomId,
    List<String>? selectedVehicleIds,
    String? notes,
    String? Function()? errorMessage,
    bool? isSubmitting,
  }) {
    return StockTransferState(
      status: status ?? this.status,
      transfers: transfers ?? this.transfers,
      showrooms: showrooms ?? this.showrooms,
      availableVehicles: availableVehicles ?? this.availableVehicles,
      selectedSourceShowroomId: selectedSourceShowroomId != null ? selectedSourceShowroomId() : this.selectedSourceShowroomId,
      selectedDestShowroomId: selectedDestShowroomId != null ? selectedDestShowroomId() : this.selectedDestShowroomId,
      selectedVehicleIds: selectedVehicleIds ?? this.selectedVehicleIds,
      notes: notes ?? this.notes,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        status,
        transfers,
        showrooms,
        availableVehicles,
        selectedSourceShowroomId,
        selectedDestShowroomId,
        selectedVehicleIds,
        notes,
        errorMessage,
        isSubmitting,
      ];
}
