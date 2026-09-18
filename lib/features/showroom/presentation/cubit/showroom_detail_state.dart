import 'package:equatable/equatable.dart';
import '../../domain/entities/showroom_entity.dart';
import '../../domain/entities/invoice_sequence_entity.dart';
import '../../../../core/services/user_management_service.dart';

sealed class ShowroomDetailState extends Equatable {
  const ShowroomDetailState();

  @override
  List<Object?> get props => [];
}

class ShowroomDetailInitial extends ShowroomDetailState {
  const ShowroomDetailInitial();
}

class ShowroomDetailLoading extends ShowroomDetailState {
  const ShowroomDetailLoading();
}

class ShowroomDetailLoaded extends ShowroomDetailState {
  final ShowroomEntity showroom;
  final List<ManagedUser> staff;
  final List<InvoiceSequenceEntity> sequences;

  const ShowroomDetailLoaded({
    required this.showroom,
    this.staff = const [],
    this.sequences = const [],
  });

  @override
  List<Object?> get props => [showroom, staff, sequences];
}

class ShowroomDetailError extends ShowroomDetailState {
  final String message;

  const ShowroomDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
