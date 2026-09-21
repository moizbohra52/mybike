import 'package:flutter_test/flutter_test.dart';
import 'package:mybike/core/services/document_management_service.dart';
import 'package:mybike/features/documents/data/models/dealership_document_model.dart';
import 'package:mybike/features/documents/domain/entities/dealership_document_entity.dart';
import 'package:mybike/features/documents/domain/entities/document_filter_criteria.dart';
import 'package:mybike/features/documents/presentation/cubit/document_list_cubit.dart';
import 'package:mybike/features/documents/presentation/cubit/document_list_state.dart';
import 'package:mybike/features/documents/presentation/cubit/document_upload_cubit.dart';
import 'package:mybike/features/documents/presentation/cubit/document_upload_state.dart';

void main() {
  group('Phase 19: Document Management (DMS) Tests', () {
    late DocumentManagementService service;

    setUp(() {
      service = DocumentManagementService.instance;
    });

    // ─────────────────────────────────────────────────────────
    // 1. Entity & Model Tests
    // ─────────────────────────────────────────────────────────
    group('DealershipDocumentEntity & Model', () {
      test('DealershipDocumentModel correctly serializes and deserializes JSON', () {
        final now = DateTime.now();
        final model = DealershipDocumentModel(
          id: 'test-doc-01',
          showroomId: 'sr-01',
          entityType: 'customer',
          entityId: 'cust-101',
          documentCategory: 'kyc',
          documentType: 'Aadhaar Card',
          documentNumber: '1234-5678-9012',
          fileName: 'aadhaar_card.pdf',
          filePath: 'documents/kyc/aadhaar_card.pdf',
          fileSize: 1024 * 500,
          mimeType: 'application/pdf',
          verificationStatus: 'pending',
          createdAt: now,
          updatedAt: now,
        );

        final json = model.toJson();
        expect(json['id'], 'test-doc-01');
        expect(json['entity_type'], 'customer');
        expect(json['document_category'], 'kyc');
        expect(json['file_name'], 'aadhaar_card.pdf');
        expect(json['verification_status'], 'pending');

        final reconstructed = DealershipDocumentModel.fromJson(json);
        expect(reconstructed.id, model.id);
        expect(reconstructed.entityType, model.entityType);
        expect(reconstructed.documentType, model.documentType);
        expect(reconstructed.fileSize, model.fileSize);
        expect(reconstructed.mimeType, model.mimeType);
      });

      test('Entity helper getters work accurately', () {
        final now = DateTime.now();
        final doc = DealershipDocumentEntity(
          id: 'test-doc-02',
          entityType: 'vehicle',
          entityId: 'veh-001',
          documentCategory: 'rto_registration',
          documentType: 'Form 20 Sales Certificate',
          fileName: 'form_20.pdf',
          filePath: 'documents/rto/form_20.pdf',
          fileSize: 2 * 1024 * 1024, // 2 MB
          mimeType: 'application/pdf',
          verificationStatus: 'verified',
          createdAt: now,
          updatedAt: now,
        );

        expect(doc.isVerified, isTrue);
        expect(doc.isPending, isFalse);
        expect(doc.isRejected, isFalse);
        expect(doc.isPdf, isTrue);
        expect(doc.isImage, isFalse);
        expect(doc.statusLabel, 'VERIFIED');
        expect(doc.categoryLabel, 'RTO Registration');
        expect(doc.formattedFileSize, '2.0 MB');
      });

      test('Entity copyWith updates fields correctly', () {
        final now = DateTime.now();
        final doc = DealershipDocumentEntity(
          id: 'test-doc-03',
          entityType: 'booking',
          entityId: 'bk-01',
          documentCategory: 'insurance',
          documentType: 'Policy Note',
          fileName: 'policy.jpg',
          filePath: 'documents/insurance/policy.jpg',
          fileSize: 512,
          mimeType: 'image/jpeg',
          verificationStatus: 'pending',
          createdAt: now,
          updatedAt: now,
        );

        expect(doc.isImage, isTrue);
        expect(doc.formattedFileSize, '512 B');

        final updated = doc.copyWith(
          verificationStatus: 'rejected',
          rejectionReason: 'Invalid policy date',
        );

        expect(updated.verificationStatus, 'rejected');
        expect(updated.rejectionReason, 'Invalid policy date');
        expect(updated.isRejected, isTrue);
        expect(updated.statusLabel, 'REJECTED');
      });
    });

    // ─────────────────────────────────────────────────────────
    // 2. Filter Criteria Tests
    // ─────────────────────────────────────────────────────────
    group('DocumentFilterCriteria', () {
      test('Filter criteria copyWith and clear flags behave as expected', () {
        const initial = DocumentFilterCriteria(
          documentCategory: 'kyc',
          verificationStatus: 'pending',
          entityType: 'customer',
        );

        final updated = initial.copyWith(
          clearCategory: true,
          verificationStatus: 'verified',
        );

        expect(updated.documentCategory, isNull);
        expect(updated.verificationStatus, 'verified');
        expect(updated.entityType, 'customer');
      });
    });

    // ─────────────────────────────────────────────────────────
    // 3. DocumentManagementService CRUD & Workflow
    // ─────────────────────────────────────────────────────────
    group('DocumentManagementService', () {
      test('Pre-seeded documents are loaded with diverse categories', () async {
        final docs = await service.fetchDocuments(const DocumentFilterCriteria());
        expect(docs.isNotEmpty, isTrue);

        final categories = docs.map((d) => d.documentCategory).toSet();
        expect(categories.contains('kyc'), isTrue);
        expect(categories.contains('rto_registration'), isTrue);
        expect(categories.contains('insurance'), isTrue);
        expect(categories.contains('warranty'), isTrue);
      });

      test('Service filters documents by category and status accurately', () async {
        final kycDocs = await service.fetchDocuments(
          const DocumentFilterCriteria(documentCategory: 'kyc'),
        );
        for (final doc in kycDocs) {
          expect(doc.documentCategory, 'kyc');
        }

        final verifiedDocs = await service.fetchDocuments(
          const DocumentFilterCriteria(verificationStatus: 'verified'),
        );
        for (final doc in verifiedDocs) {
          expect(doc.verificationStatus, 'verified');
        }
      });

      test('Service filters documents by search query', () async {
        final searchResults = await service.fetchDocuments(
          const DocumentFilterCriteria(searchQuery: 'aadhaar'),
        );
        expect(searchResults.isNotEmpty, isTrue);
        for (final doc in searchResults) {
          expect(
            doc.documentType.toLowerCase().contains('aadhaar') ||
                doc.fileName.toLowerCase().contains('aadhaar'),
            isTrue,
          );
        }
      });

      test('Upload, verify, and reject workflow executes properly', () async {
        // 1. Upload new document
        final uploaded = await service.uploadDocument(
          entityType: 'vehicle',
          entityId: 'veh-unit-test-99',
          documentCategory: 'rto_registration',
          documentType: 'Form 21 Sale Certificate',
          documentNumber: 'FORM21-TEST-99',
          fileName: 'form_21_test.pdf',
          fileSize: 1024 * 300,
          mimeType: 'application/pdf',
          uploadedBy: 'Tester',
        );

        expect(uploaded.verificationStatus, 'pending');
        expect(uploaded.entityId, 'veh-unit-test-99');

        // 2. Verify document
        final verified = await service.verifyDocument(
          uploaded.id,
          verifiedBy: 'Compliance Lead',
        );
        expect(verified.isVerified, isTrue);
        expect(verified.verifiedBy, 'Compliance Lead');
        expect(verified.verifiedAt, isNotNull);

        // 3. Reject document
        final rejected = await service.rejectDocument(
          uploaded.id,
          rejectedBy: 'Audit Officer',
          reason: 'Missing digital sign',
        );
        expect(rejected.isRejected, isTrue);
        expect(rejected.rejectionReason, 'Missing digital sign');

        // 4. Delete document
        await service.deleteDocument(uploaded.id);
        final found = await service.getDocumentById(uploaded.id);
        expect(found, isNull);
      });

      test('Metrics counter returns valid totals', () async {
        final counts = await service.getDocumentCounts();
        expect(counts.containsKey('total'), isTrue);
        expect(counts.containsKey('pending'), isTrue);
        expect(counts.containsKey('verified'), isTrue);
        expect(counts.containsKey('rejected'), isTrue);
        expect(counts['total']!, greaterThanOrEqualTo(0));
      });
    });

    // ─────────────────────────────────────────────────────────
    // 4. Cubits (State Management)
    // ─────────────────────────────────────────────────────────
    group('DocumentListCubit & DocumentUploadCubit', () {
      test('DocumentListCubit loads documents and handles filters', () async {
        final cubit = DocumentListCubit(service: service);
        expect(cubit.state, isA<DocumentListInitial>());

        await cubit.loadDocuments();
        expect(cubit.state, isA<DocumentListLoaded>());

        final loaded = cubit.state as DocumentListLoaded;
        expect(loaded.documents.isNotEmpty, isTrue);
        expect(loaded.counts['total']!, greaterThan(0));

        // Filter category
        await cubit.setCategory('insurance');
        final insuranceLoaded = cubit.state as DocumentListLoaded;
        for (final doc in insuranceLoaded.documents) {
          expect(doc.documentCategory, 'insurance');
        }

        // Filter status
        await cubit.setStatus('verified');
        final statusLoaded = cubit.state as DocumentListLoaded;
        for (final doc in statusLoaded.documents) {
          expect(doc.verificationStatus, 'verified');
        }

        // Search query
        await cubit.setSearch('test');
        expect(cubit.state, isA<DocumentListLoaded>());

        await cubit.close();
      });

      test('DocumentUploadCubit uploads document successfully', () async {
        final uploadCubit = DocumentUploadCubit(service: service);
        expect(uploadCubit.state, isA<DocumentUploadInitial>());

        await uploadCubit.uploadDocument(
          entityType: 'customer',
          entityId: 'cust-upload-test',
          documentCategory: 'kyc',
          documentType: 'PAN Card',
          fileName: 'pan_card.pdf',
          fileSize: 1024 * 120,
          mimeType: 'application/pdf',
        );

        expect(uploadCubit.state, isA<DocumentUploadSuccess>());
        final success = uploadCubit.state as DocumentUploadSuccess;
        expect(success.document.entityId, 'cust-upload-test');
        expect(success.document.documentType, 'PAN Card');

        // Cleanup
        await service.deleteDocument(success.document.id);
        await uploadCubit.close();
      });
    });
  });
}
