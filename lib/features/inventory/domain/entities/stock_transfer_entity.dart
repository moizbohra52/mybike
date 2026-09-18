import 'package:equatable/equatable.dart';

/// Stock Transfer Item mapping a vehicle to an inter-showroom transfer
class StockTransferItemEntity extends Equatable {
  final String id;
  final String transferId;
  final String vehicleId;
  final String status; // 'pending', 'in_transit', 'received', 'rejected'
  final String? notes;

  const StockTransferItemEntity({
    required this.id,
    required this.transferId,
    required this.vehicleId,
    this.status = 'pending',
    this.notes,
  });

  @override
  List<Object?> get props => [id, transferId, vehicleId, status, notes];
}

/// Stock Transfer Document Domain Entity
class StockTransferEntity extends Equatable {
  final String id;
  final String transferNumber;
  final String sourceShowroomId;
  final String destinationShowroomId;
  final String status; // 'requested', 'in_transit', 'received', 'rejected', 'cancelled'
  final String? requestedBy;
  final String? dispatchedBy;
  final String? receivedBy;
  final DateTime? dispatchedAt;
  final DateTime? receivedAt;
  final String? notes;
  final List<StockTransferItemEntity> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockTransferEntity({
    required this.id,
    required this.transferNumber,
    required this.sourceShowroomId,
    required this.destinationShowroomId,
    this.status = 'requested',
    this.requestedBy,
    this.dispatchedBy,
    this.receivedBy,
    this.dispatchedAt,
    this.receivedAt,
    this.notes,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isRequested => status == 'requested';
  bool get isInTransit => status == 'in_transit';
  bool get isReceived => status == 'received';

  StockTransferEntity copyWith({
    String? id,
    String? transferNumber,
    String? sourceShowroomId,
    String? destinationShowroomId,
    String? status,
    String? requestedBy,
    String? dispatchedBy,
    String? receivedBy,
    DateTime? dispatchedAt,
    DateTime? receivedAt,
    String? notes,
    List<StockTransferItemEntity>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockTransferEntity(
      id: id ?? this.id,
      transferNumber: transferNumber ?? this.transferNumber,
      sourceShowroomId: sourceShowroomId ?? this.sourceShowroomId,
      destinationShowroomId: destinationShowroomId ?? this.destinationShowroomId,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      dispatchedBy: dispatchedBy ?? this.dispatchedBy,
      receivedBy: receivedBy ?? this.receivedBy,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      receivedAt: receivedAt ?? this.receivedAt,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        transferNumber,
        sourceShowroomId,
        destinationShowroomId,
        status,
        requestedBy,
        dispatchedBy,
        receivedBy,
        dispatchedAt,
        receivedAt,
        notes,
        items,
        createdAt,
        updatedAt,
      ];
}
