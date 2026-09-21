import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/document_management_service.dart';
import 'document_upload_state.dart';

class DocumentUploadCubit extends Cubit<DocumentUploadState> {
  final DocumentManagementService _service;

  DocumentUploadCubit({DocumentManagementService? service})
      : _service = service ?? DocumentManagementService.instance,
        super(const DocumentUploadInitial());

  Future<void> uploadDocument({
    String? showroomId,
    required String entityType,
    required String entityId,
    required String documentCategory,
    required String documentType,
    String? documentNumber,
    required String fileName,
    String? filePath,
    required int fileSize,
    required String mimeType,
    DateTime? expiryDate,
    String? uploadedBy,
    String? notes,
  }) async {
    emit(const DocumentUploadSubmitting());
    try {
      final doc = await _service.uploadDocument(
        showroomId: showroomId,
        entityType: entityType,
        entityId: entityId,
        documentCategory: documentCategory,
        documentType: documentType,
        documentNumber: documentNumber,
        fileName: fileName,
        filePath: filePath,
        fileSize: fileSize,
        mimeType: mimeType,
        expiryDate: expiryDate,
        uploadedBy: uploadedBy,
        notes: notes,
      );
      emit(DocumentUploadSuccess(doc));
    } catch (e) {
      emit(DocumentUploadFailure('Failed to upload document: $e'));
    }
  }

  void reset() {
    emit(const DocumentUploadInitial());
  }
}
