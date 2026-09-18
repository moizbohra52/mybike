import '../../domain/entities/stock_transfer_entity.dart';

/// Stock Transfer Item Data Model
class StockTransferItemModel extends StockTransferItemEntity {
  const StockTransferItemModel({
    required super.id,
    required super.transferId,
    required super.vehicleId,
    super.status = 'pending',
    super.notes,
  });

  factory StockTransferItemModel.fromJson(Map<String, dynamic> json) {
    return StockTransferItemModel(
      id: json['id'] as String,
      transferId: json['transfer_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transfer_id': transferId,
      'vehicle_id': vehicleId,
      'status': status,
      'notes': notes,
    };
  }

  factory StockTransferItemModel.fromEntity(StockTransferItemEntity entity) {
    return StockTransferItemModel(
      id: entity.id,
      transferId: entity.transferId,
      vehicleId: entity.vehicleId,
      status: entity.status,
      notes: entity.notes,
    );
  }
}

/// Stock Transfer Data Model with JSON serialization
class StockTransferModel extends StockTransferEntity {
  const StockTransferModel({
    required super.id,
    required super.transferNumber,
    required super.sourceShowroomId,
    required super.destinationShowroomId,
    super.status = 'requested',
    super.requestedBy,
    super.dispatchedBy,
    super.receivedBy,
    super.dispatchedAt,
    super.receivedAt,
    super.notes,
    super.items = const [],
    required super.createdAt,
    required super.updatedAt,
  });

  factory StockTransferModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['stock_transfer_items'] as List?;
    final parsedItems = rawItems != null
        ? rawItems.map((i) => StockTransferItemModel.fromJson(i as Map<String, dynamic>)).toList()
        : <StockTransferItemModel>[];

    return StockTransferModel(
      id: json['id'] as String,
      transferNumber: json['transfer_number'] as String,
      sourceShowroomId: json['source_showroom_id'] as String,
      destinationShowroomId: json['destination_showroom_id'] as String,
      status: json['status'] as String? ?? 'requested',
      requestedBy: json['requested_by'] as String?,
      dispatchedBy: json['dispatched_by'] as String?,
      receivedBy: json['received_by'] as String?,
      dispatchedAt: json['dispatched_at'] != null
          ? DateTime.parse(json['dispatched_at'] as String)
          : null,
      receivedAt: json['received_at'] != null
          ? DateTime.parse(json['received_at'] as String)
          : null,
      notes: json['notes'] as String?,
      items: parsedItems,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transfer_number': transferNumber,
      'source_showroom_id': sourceShowroomId,
      'destination_showroom_id': destinationShowroomId,
      'status': status,
      'requested_by': requestedBy,
      'dispatched_by': dispatchedBy,
      'received_by': receivedBy,
      'dispatched_at': dispatchedAt?.toIso8601String(),
      'received_at': receivedAt?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StockTransferModel.fromEntity(StockTransferEntity entity) {
    return StockTransferModel(
      id: entity.id,
      transferNumber: entity.transferNumber,
      sourceShowroomId: entity.sourceShowroomId,
      destinationShowroomId: entity.destinationShowroomId,
      status: entity.status,
      requestedBy: entity.requestedBy,
      dispatchedBy: entity.dispatchedBy,
      receivedBy: entity.receivedBy,
      dispatchedAt: entity.dispatchedAt,
      receivedAt: entity.receivedAt,
      notes: entity.notes,
      items: entity.items
          .map((i) => StockTransferItemModel.fromEntity(i))
          .toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
