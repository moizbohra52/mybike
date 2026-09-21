import 'package:equatable/equatable.dart';

/// Document Filter Criteria Value Object
class DocumentFilterCriteria extends Equatable {
  final String? showroomId;
  final String? entityType; // 'all', 'customer', 'vehicle', 'booking', 'invoice', etc.
  final String? entityId;
  final String? documentCategory; // 'all', 'kyc', 'rto_registration', 'insurance', etc.
  final String? verificationStatus; // 'all', 'pending', 'verified', 'rejected', 'expired'
  final String? searchQuery;

  const DocumentFilterCriteria({
    this.showroomId,
    this.entityType = 'all',
    this.entityId,
    this.documentCategory = 'all',
    this.verificationStatus = 'all',
    this.searchQuery,
  });

  DocumentFilterCriteria copyWith({
    String? showroomId,
    String? entityType,
    String? entityId,
    String? documentCategory,
    String? verificationStatus,
    String? searchQuery,
    bool clearCategory = false,
    bool clearStatus = false,
    bool clearEntityType = false,
  }) {
    return DocumentFilterCriteria(
      showroomId: showroomId ?? this.showroomId,
      entityType: clearEntityType ? null : (entityType ?? this.entityType),
      entityId: entityId ?? this.entityId,
      documentCategory: clearCategory ? null : (documentCategory ?? this.documentCategory),
      verificationStatus: clearStatus ? null : (verificationStatus ?? this.verificationStatus),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        showroomId,
        entityType,
        entityId,
        documentCategory,
        verificationStatus,
        searchQuery,
      ];
}
