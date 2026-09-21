import 'package:equatable/equatable.dart';
import '../../domain/entities/dealership_document_entity.dart';
import '../../domain/entities/document_filter_criteria.dart';

abstract class DocumentListState extends Equatable {
  const DocumentListState();

  @override
  List<Object?> get props => [];
}

class DocumentListInitial extends DocumentListState {
  const DocumentListInitial();
}

class DocumentListLoading extends DocumentListState {
  const DocumentListLoading();
}

class DocumentListLoaded extends DocumentListState {
  final List<DealershipDocumentEntity> documents;
  final DocumentFilterCriteria criteria;
  final Map<String, int> counts;
  final String? successMessage;

  const DocumentListLoaded({
    required this.documents,
    required this.criteria,
    this.counts = const {'total': 0, 'pending': 0, 'verified': 0, 'rejected': 0},
    this.successMessage,
  });

  DocumentListLoaded copyWith({
    List<DealershipDocumentEntity>? documents,
    DocumentFilterCriteria? criteria,
    Map<String, int>? counts,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return DocumentListLoaded(
      documents: documents ?? this.documents,
      criteria: criteria ?? this.criteria,
      counts: counts ?? this.counts,
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [documents, criteria, counts, successMessage];
}

class DocumentListError extends DocumentListState {
  final String message;

  const DocumentListError(this.message);

  @override
  List<Object?> get props => [message];
}
