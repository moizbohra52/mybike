import 'package:equatable/equatable.dart';
import '../../../../core/services/showroom_management_service.dart';
import '../../domain/entities/vehicle_inventory_item.dart';

enum InventoryListStatus { initial, loading, success, failure }

class InventoryListState extends Equatable {
  final InventoryListStatus status;
  final List<VehicleInventoryItem> items;
  final List<ShowroomWithStats> showrooms;
  final String? selectedShowroomId;
  final String? selectedStatus; // null/'all', 'in_stock', 'booked', 'sold', 'in_transit'
  final String? selectedPowertrain; // null/'all', 'petrol', 'electric'
  final String? selectedPdiStatus; // null/'all', 'pending', 'passed', 'failed'
  final String searchQuery;
  final String? errorMessage;

  const InventoryListState({
    this.status = InventoryListStatus.initial,
    this.items = const [],
    this.showrooms = const [],
    this.selectedShowroomId,
    this.selectedStatus,
    this.selectedPowertrain,
    this.selectedPdiStatus,
    this.searchQuery = '',
    this.errorMessage,
  });

  int get totalUnits => items.length;
  int get availableUnits => items.where((i) => i.vehicle.isAvailable).length;
  int get bookedUnits => items.where((i) => i.vehicle.isBooked).length;
  int get inTransitUnits => items.where((i) => i.vehicle.isInTransit).length;
  int get pdiPendingUnits => items.where((i) => i.vehicle.pdiStatus == 'pending').length;
  double get totalValuationInr =>
      items.fold<double>(0.0, (sum, i) => sum + i.vehicle.purchaseCost);

  InventoryListState copyWith({
    InventoryListStatus? status,
    List<VehicleInventoryItem>? items,
    List<ShowroomWithStats>? showrooms,
    String? Function()? selectedShowroomId,
    String? Function()? selectedStatus,
    String? Function()? selectedPowertrain,
    String? Function()? selectedPdiStatus,
    String? searchQuery,
    String? Function()? errorMessage,
  }) {
    return InventoryListState(
      status: status ?? this.status,
      items: items ?? this.items,
      showrooms: showrooms ?? this.showrooms,
      selectedShowroomId: selectedShowroomId != null ? selectedShowroomId() : this.selectedShowroomId,
      selectedStatus: selectedStatus != null ? selectedStatus() : this.selectedStatus,
      selectedPowertrain: selectedPowertrain != null ? selectedPowertrain() : this.selectedPowertrain,
      selectedPdiStatus: selectedPdiStatus != null ? selectedPdiStatus() : this.selectedPdiStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        showrooms,
        selectedShowroomId,
        selectedStatus,
        selectedPowertrain,
        selectedPdiStatus,
        searchQuery,
        errorMessage,
      ];
}
