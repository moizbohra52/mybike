import '../../features/documents/data/models/dealership_document_model.dart';
import '../../features/documents/domain/entities/dealership_document_entity.dart';
import '../../features/documents/domain/entities/document_filter_criteria.dart';

/// Central Dealership Document Management (DMS) Service
class DocumentManagementService {
  static final DocumentManagementService instance = DocumentManagementService._internal();

  factory DocumentManagementService() => instance;

  DocumentManagementService._internal() {
    _initSeededDocuments();
  }

  final List<DealershipDocumentEntity> _documents = [];

  // ─────────────────────────────────────────────────────────
  // Query & Fetch
  // ─────────────────────────────────────────────────────────

  Future<List<DealershipDocumentEntity>> fetchDocuments(DocumentFilterCriteria criteria) async {
    List<DealershipDocumentEntity> results = List.from(_documents);

    if (criteria.showroomId != null) {
      results = results
          .where((d) => d.showroomId == null || d.showroomId == criteria.showroomId)
          .toList();
    }

    if (criteria.entityType != null && criteria.entityType != 'all') {
      results = results.where((d) => d.entityType == criteria.entityType).toList();
    }

    if (criteria.entityId != null && criteria.entityId!.isNotEmpty) {
      results = results.where((d) => d.entityId == criteria.entityId).toList();
    }

    if (criteria.documentCategory != null && criteria.documentCategory != 'all') {
      results = results.where((d) => d.documentCategory == criteria.documentCategory).toList();
    }

    if (criteria.verificationStatus != null && criteria.verificationStatus != 'all') {
      results = results.where((d) => d.verificationStatus == criteria.verificationStatus).toList();
    }

    if (criteria.searchQuery != null && criteria.searchQuery!.trim().isNotEmpty) {
      final query = criteria.searchQuery!.trim().toLowerCase();
      results = results.where((d) {
        return d.fileName.toLowerCase().contains(query) ||
            d.documentType.toLowerCase().contains(query) ||
            d.entityId.toLowerCase().contains(query) ||
            (d.documentNumber?.toLowerCase().contains(query) ?? false) ||
            (d.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort newest first
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  Future<DealershipDocumentEntity?> getDocumentById(String id) async {
    try {
      return _documents.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────
  // Upload & Registration
  // ─────────────────────────────────────────────────────────

  Future<DealershipDocumentEntity> uploadDocument({
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
    final newDoc = DealershipDocumentModel(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      showroomId: showroomId,
      entityType: entityType,
      entityId: entityId,
      documentCategory: documentCategory,
      documentType: documentType,
      documentNumber: documentNumber,
      fileName: fileName,
      filePath: filePath ?? 'documents/$documentCategory/$fileName',
      fileSize: fileSize,
      mimeType: mimeType,
      verificationStatus: 'pending',
      expiryDate: expiryDate,
      uploadedBy: uploadedBy,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _documents.insert(0, newDoc);
    return newDoc;
  }

  // ─────────────────────────────────────────────────────────
  // Verification Workflow
  // ─────────────────────────────────────────────────────────

  Future<DealershipDocumentEntity> verifyDocument(
    String documentId, {
    required String verifiedBy,
  }) async {
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index == -1) {
      throw Exception('Document not found with ID: $documentId');
    }

    final updated = _documents[index].copyWith(
      verificationStatus: 'verified',
      verifiedBy: verifiedBy,
      verifiedAt: DateTime.now(),
      rejectionReason: null,
      updatedAt: DateTime.now(),
    );

    _documents[index] = updated;
    return updated;
  }

  Future<DealershipDocumentEntity> rejectDocument(
    String documentId, {
    required String rejectedBy,
    required String reason,
  }) async {
    final index = _documents.indexWhere((d) => d.id == documentId);
    if (index == -1) {
      throw Exception('Document not found with ID: $documentId');
    }

    final updated = _documents[index].copyWith(
      verificationStatus: 'rejected',
      verifiedBy: rejectedBy,
      verifiedAt: DateTime.now(),
      rejectionReason: reason,
      updatedAt: DateTime.now(),
    );

    _documents[index] = updated;
    return updated;
  }

  Future<void> deleteDocument(String documentId) async {
    _documents.removeWhere((d) => d.id == documentId);
  }

  // ─────────────────────────────────────────────────────────
  // Counters & Metrics
  // ─────────────────────────────────────────────────────────

  Future<int> getPendingCount({String? showroomId}) async {
    return _documents.where((d) {
      final matchesShowroom = showroomId == null || d.showroomId == null || d.showroomId == showroomId;
      return matchesShowroom && d.isPending;
    }).length;
  }

  Future<Map<String, int>> getDocumentCounts({String? showroomId}) async {
    final scoped = showroomId == null
        ? _documents
        : _documents.where((d) => d.showroomId == null || d.showroomId == showroomId).toList();

    return {
      'total': scoped.length,
      'pending': scoped.where((d) => d.isPending).length,
      'verified': scoped.where((d) => d.isVerified).length,
      'rejected': scoped.where((d) => d.isRejected).length,
    };
  }

  // ─────────────────────────────────────────────────────────
  // Pre-Seeded Development Records
  // ─────────────────────────────────────────────────────────

  void _initSeededDocuments() {
    _documents.addAll([
      DealershipDocumentModel(
        id: 'doc-seed-01',
        entityType: 'customer',
        entityId: 'cust-01',
        documentCategory: 'kyc',
        documentType: 'Aadhaar Card',
        documentNumber: 'XXXX-XXXX-9842',
        fileName: 'aadhaar_moiz_bohra.pdf',
        filePath: 'documents/kyc/aadhaar_moiz_bohra.pdf',
        fileSize: 842150,
        mimeType: 'application/pdf',
        verificationStatus: 'verified',
        verifiedAt: DateTime.now().subtract(const Duration(days: 2)),
        notes: 'Customer primary identity verification verified with UIDAI mask.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DealershipDocumentModel(
        id: 'doc-seed-02',
        entityType: 'customer',
        entityId: 'cust-01',
        documentCategory: 'kyc',
        documentType: 'PAN Card',
        documentNumber: 'ABCDE1234F',
        fileName: 'pan_moiz_bohra.jpg',
        filePath: 'documents/kyc/pan_moiz_bohra.jpg',
        fileSize: 421000,
        mimeType: 'image/jpeg',
        verificationStatus: 'verified',
        verifiedAt: DateTime.now().subtract(const Duration(days: 2)),
        notes: 'PAN verified against NSDL records for GST invoicing.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DealershipDocumentModel(
        id: 'doc-seed-03',
        entityType: 'vehicle',
        entityId: 'MD2A12345E6789012',
        documentCategory: 'rto_registration',
        documentType: 'Form 20 (RTO Application)',
        documentNumber: 'MH-02-2026-F20-091',
        fileName: 'form20_speedster250.pdf',
        filePath: 'documents/rto/form20_speedster250.pdf',
        fileSize: 1245000,
        mimeType: 'application/pdf',
        verificationStatus: 'pending',
        notes: 'Application for Registration of a Motor Vehicle signed by customer.',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      DealershipDocumentModel(
        id: 'doc-seed-04',
        entityType: 'vehicle',
        entityId: 'MD2A12345E6789012',
        documentCategory: 'rto_registration',
        documentType: 'Form 21 (Sale Certificate)',
        documentNumber: 'MB-MUM-F21-0045',
        fileName: 'form21_sale_certificate.pdf',
        filePath: 'documents/rto/form21_sale_certificate.pdf',
        fileSize: 612000,
        mimeType: 'application/pdf',
        verificationStatus: 'verified',
        verifiedAt: DateTime.now().subtract(const Duration(days: 1)),
        notes: 'Sale Certificate issued under Rule 47 of Central Motor Vehicles Rules.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      DealershipDocumentModel(
        id: 'doc-seed-05',
        entityType: 'booking',
        entityId: 'BK-2026-0042',
        documentCategory: 'insurance',
        documentType: 'Comprehensive Insurance Policy (1+5 Yr)',
        documentNumber: 'POL-HDFC-9928172',
        fileName: 'hdfc_ergo_policy.pdf',
        filePath: 'documents/insurance/hdfc_ergo_policy.pdf',
        fileSize: 1520000,
        mimeType: 'application/pdf',
        verificationStatus: 'pending',
        expiryDate: DateTime(2031, 3, 14),
        notes: '5 Years Third Party + 1 Year Own Damage coverage.',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      DealershipDocumentModel(
        id: 'doc-seed-06',
        entityType: 'customer',
        entityId: 'cust-02',
        documentCategory: 'kyc',
        documentType: 'Driving License',
        documentNumber: 'MH02-20180048123',
        fileName: 'driving_license_rahul.jpg',
        filePath: 'documents/kyc/driving_license_rahul.jpg',
        fileSize: 512000,
        mimeType: 'image/jpeg',
        verificationStatus: 'rejected',
        verifiedAt: DateTime.now().subtract(const Duration(hours: 5)),
        rejectionReason: 'Photo is blurry and address is not clearly legible. Please upload high-resolution scan.',
        expiryDate: DateTime(2038, 8, 20),
        notes: 'Re-upload requested from customer.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      DealershipDocumentModel(
        id: 'doc-seed-07',
        entityType: 'vehicle',
        entityId: 'MD2A12345E6789012',
        documentCategory: 'warranty',
        documentType: 'OEM 5-Year Extended Warranty Certificate',
        documentNumber: 'WR-2026-TVS-091',
        fileName: 'warranty_certificate.pdf',
        filePath: 'documents/warranty/warranty_certificate.pdf',
        fileSize: 450000,
        mimeType: 'application/pdf',
        verificationStatus: 'verified',
        verifiedAt: DateTime.now().subtract(const Duration(days: 1)),
        expiryDate: DateTime(2031, 3, 20),
        notes: 'Authorized manufacturer warranty with 24/7 Roadside Assistance.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      DealershipDocumentModel(
        id: 'doc-seed-08',
        entityType: 'booking',
        entityId: 'BK-2026-0042',
        documentCategory: 'delivery',
        documentType: 'Customer Delivery Gate Pass',
        documentNumber: 'GP-DEL-2026-0042',
        fileName: 'delivery_gate_pass.pdf',
        filePath: 'documents/delivery/delivery_gate_pass.pdf',
        fileSize: 380000,
        mimeType: 'application/pdf',
        verificationStatus: 'pending',
        notes: 'Security check gate pass pending showroom manager signature.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ]);
  }
}
