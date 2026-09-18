import 'package:equatable/equatable.dart';

/// Stock Movement Lifecycle Event Domain Entity
class StockMovementEntity extends Equatable {
  final String id;
  final String vehicleId;
  final String movementType; // 'inward_grn', 'transfer_dispatch', 'transfer_receive', 'booking_allocation', 'booking_released', 'sale_delivery', 'pdi_status_update', 'bay_location_change', 'status_adjustment'
  final String? fromShowroomId;
  final String? toShowroomId;
  final String? performedBy;
  final String? remarks;
  final DateTime createdAt;

  const StockMovementEntity({
    required this.id,
    required this.vehicleId,
    required this.movementType,
    this.fromShowroomId,
    this.toShowroomId,
    this.performedBy,
    this.remarks,
    required this.createdAt,
  });

  String get displayTitle {
    switch (movementType) {
      case 'inward_grn':
        return 'Factory Inward (GRN)';
      case 'transfer_dispatch':
        return 'Dispatched for Inter-Showroom Transfer';
      case 'transfer_receive':
        return 'Received from Branch Transfer';
      case 'booking_allocation':
        return 'Allocated to Customer Booking';
      case 'booking_released':
        return 'Released back to Available Stock';
      case 'sale_delivery':
        return 'Invoiced & Delivered to Customer';
      case 'pdi_status_update':
        return 'Pre-Delivery Inspection (PDI) Updated';
      case 'bay_location_change':
        return 'Showroom Bay Relocated';
      default:
        return movementType;
    }
  }

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        movementType,
        fromShowroomId,
        toShowroomId,
        performedBy,
        remarks,
        createdAt,
      ];
}
