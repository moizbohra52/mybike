import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/document_management_service.dart';
import '../../domain/entities/document_filter_criteria.dart';
import 'document_list_state.dart';

class DocumentListCubit extends Cubit<DocumentListState> {
  final DocumentManagementService _service;

  DocumentListCubit({DocumentManagementService? service})
      : _service = service ?? DocumentManagementService.instance,
        super(const DocumentListInitial());

  DocumentFilterCriteria _currentCriteria = const DocumentFilterCriteria();

  DocumentFilterCriteria get currentCriteria => _currentCriteria;

  Future<void> loadDocuments({DocumentFilterCriteria? criteria}) async {
    if (criteria != null) {
      _currentCriteria = criteria;
    }
    emit(const DocumentListLoading());
    try {
      final documents = await _service.fetchDocuments(_currentCriteria);
      final counts = await _service.getDocumentCounts(showroomId: _currentCriteria.showroomId);
      emit(DocumentListLoaded(
        documents: documents,
        criteria: _currentCriteria,
        counts: counts,
      ));
    } catch (e) {
      emit(DocumentListError('Failed to load documents: $e'));
    }
  }

  Future<void> updateFilter(DocumentFilterCriteria criteria) async {
    _currentCriteria = criteria;
    await loadDocuments(criteria: _currentCriteria);
  }

  Future<void> setCategory(String category) async {
    _currentCriteria = _currentCriteria.copyWith(
      documentCategory: category == 'all' ? null : category,
      clearCategory: category == 'all',
    );
    await loadDocuments(criteria: _currentCriteria);
  }

  Future<void> setStatus(String status) async {
    _currentCriteria = _currentCriteria.copyWith(
      verificationStatus: status == 'all' ? null : status,
      clearStatus: status == 'all',
    );
    await loadDocuments(criteria: _currentCriteria);
  }

  Future<void> setEntityType(String entityType) async {
    _currentCriteria = _currentCriteria.copyWith(
      entityType: entityType == 'all' ? null : entityType,
      clearEntityType: entityType == 'all',
    );
    await loadDocuments(criteria: _currentCriteria);
  }

  Future<void> setSearch(String query) async {
    _currentCriteria = _currentCriteria.copyWith(
      searchQuery: query.isEmpty ? null : query,
    );
    await loadDocuments(criteria: _currentCriteria);
  }

  Future<void> setShowroom(String? showroomId) async {
    _currentCriteria = _currentCriteria.copyWith(
      showroomId: showroomId,
    );
    await loadDocuments(criteria: _currentCriteria);
  }

  Future<void> verifyDocument(String documentId, {required String verifiedBy}) async {
    try {
      await _service.verifyDocument(documentId, verifiedBy: verifiedBy);
      final documents = await _service.fetchDocuments(_currentCriteria);
      final counts = await _service.getDocumentCounts(showroomId: _currentCriteria.showroomId);
      emit(DocumentListLoaded(
        documents: documents,
        criteria: _currentCriteria,
        counts: counts,
        successMessage: 'Document successfully verified!',
      ));
    } catch (e) {
      emit(DocumentListError('Failed to verify document: $e'));
    }
  }

  Future<void> rejectDocument(
    String documentId, {
    required String rejectedBy,
    required String reason,
  }) async {
    try {
      await _service.rejectDocument(documentId, rejectedBy: rejectedBy, reason: reason);
      final documents = await _service.fetchDocuments(_currentCriteria);
      final counts = await _service.getDocumentCounts(showroomId: _currentCriteria.showroomId);
      emit(DocumentListLoaded(
        documents: documents,
        criteria: _currentCriteria,
        counts: counts,
        successMessage: 'Document has been rejected.',
      ));
    } catch (e) {
      emit(DocumentListError('Failed to reject document: $e'));
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await _service.deleteDocument(documentId);
      final documents = await _service.fetchDocuments(_currentCriteria);
      final counts = await _service.getDocumentCounts(showroomId: _currentCriteria.showroomId);
      emit(DocumentListLoaded(
        documents: documents,
        criteria: _currentCriteria,
        counts: counts,
        successMessage: 'Document deleted successfully.',
      ));
    } catch (e) {
      emit(DocumentListError('Failed to delete document: $e'));
    }
  }

  void clearSuccessMessage() {
    if (state is DocumentListLoaded) {
      emit((state as DocumentListLoaded).copyWith(clearSuccessMessage: true));
    }
  }
}
