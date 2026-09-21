import 'package:equatable/equatable.dart';
import '../../domain/entities/dealership_document_entity.dart';

abstract class DocumentUploadState extends Equatable {
  const DocumentUploadState();

  @override
  List<Object?> get props => [];
}

class DocumentUploadInitial extends DocumentUploadState {
  const DocumentUploadInitial();
}

class DocumentUploadSubmitting extends DocumentUploadState {
  const DocumentUploadSubmitting();
}

class DocumentUploadSuccess extends DocumentUploadState {
  final DealershipDocumentEntity document;

  const DocumentUploadSuccess(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentUploadFailure extends DocumentUploadState {
  final String error;

  const DocumentUploadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
