import 'package:equatable/equatable.dart';
import '../../domain/entities/showroom_entity.dart';

sealed class ShowroomFormState extends Equatable {
  const ShowroomFormState();

  @override
  List<Object?> get props => [];
}

class ShowroomFormInitial extends ShowroomFormState {
  const ShowroomFormInitial();
}

class ShowroomFormLoading extends ShowroomFormState {
  const ShowroomFormLoading();
}

class ShowroomFormReady extends ShowroomFormState {
  final ShowroomEntity? existingShowroom;
  final List<String> availableStates;

  const ShowroomFormReady({
    this.existingShowroom,
    this.availableStates = const [],
  });

  bool get isEditMode => existingShowroom != null;

  @override
  List<Object?> get props => [existingShowroom, availableStates];
}

class ShowroomFormSaving extends ShowroomFormState {
  const ShowroomFormSaving();
}

class ShowroomFormSuccess extends ShowroomFormState {
  final String message;
  final ShowroomEntity showroom;

  const ShowroomFormSuccess(this.message, this.showroom);

  @override
  List<Object?> get props => [message, showroom];
}

class ShowroomFormError extends ShowroomFormState {
  final String message;

  const ShowroomFormError(this.message);

  @override
  List<Object?> get props => [message];
}
