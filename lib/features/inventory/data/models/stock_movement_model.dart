import '../../domain/entities/stock_movement_entity.dart';

/// Stock Movement Data Model with JSON serialization
class StockMovementModel extends StockMovementEntity {
  const StockMovementModel({
    required super.id,
    required super.vehicleId,
    required super.movementType,
    super.fromShowroomId,
    super.toShowroomId,
    super.performedBy,
    super.remarks,
    required super.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      movementType: json['movement_type'] as String,
      fromShowroomId: json['from_showroom_id'] as String?,
      toShowroomId: json['to_showroom_id'] as String?,
      performedBy: json['performed_by'] as String?,
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'movement_type': movementType,
      'from_showroom_id': fromShowroomId,
      'to_showroom_id': toShowroomId,
      'performed_by': performedBy,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory StockMovementModel.fromEntity(StockMovementEntity entity) {
    return StockMovementModel(
      id: entity.id,
      vehicleId: entity.vehicleId,
      movementType: entity.movementType,
      fromShowroomId: entity.fromShowroomId,
      toShowroomId: entity.toShowroomId,
      performedBy: entity.performedBy,
      remarks: entity.remarks,
      createdAt: entity.createdAt,
    );
  }
}
