import '../../domain/entities/gst_rate_entity.dart';

/// GST Rate Model for Supabase & local cache serialization
class GstRateModel extends GstRateEntity {
  const GstRateModel({
    required super.id,
    required super.taxName,
    required super.hsnSacCode,
    required super.gstRate,
    required super.cgstRate,
    required super.sgstRate,
    required super.igstRate,
    super.cessRate = 0.0,
    required super.category,
    super.description,
    super.isActive = true,
    required super.effectiveFrom,
    super.createdAt,
    super.updatedAt,
  });

  factory GstRateModel.fromJson(Map<String, dynamic> json) {
    return GstRateModel(
      id: json['id'] as String,
      taxName: json['tax_name'] as String,
      hsnSacCode: json['hsn_sac_code'] as String,
      gstRate: (json['gst_rate'] as num).toDouble(),
      cgstRate: (json['cgst_rate'] as num).toDouble(),
      sgstRate: (json['sgst_rate'] as num).toDouble(),
      igstRate: (json['igst_rate'] as num).toDouble(),
      cessRate: (json['cess_rate'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'other',
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      effectiveFrom: json['effective_from'] != null
          ? DateTime.parse(json['effective_from'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tax_name': taxName,
      'hsn_sac_code': hsnSacCode,
      'gst_rate': gstRate,
      'cgst_rate': cgstRate,
      'sgst_rate': sgstRate,
      'igst_rate': igstRate,
      'cess_rate': cessRate,
      'category': category,
      'description': description,
      'is_active': isActive,
      'effective_from': effectiveFrom.toIso8601String().split('T').first,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  factory GstRateModel.fromEntity(GstRateEntity entity) {
    return GstRateModel(
      id: entity.id,
      taxName: entity.taxName,
      hsnSacCode: entity.hsnSacCode,
      gstRate: entity.gstRate,
      cgstRate: entity.cgstRate,
      sgstRate: entity.sgstRate,
      igstRate: entity.igstRate,
      cessRate: entity.cessRate,
      category: entity.category,
      description: entity.description,
      isActive: entity.isActive,
      effectiveFrom: entity.effectiveFrom,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
