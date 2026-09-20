import 'package:equatable/equatable.dart';

/// Configurable GST Tax Rate Entity
///
/// Models an Indian GST tax slab applicable to vehicles, spare parts,
/// accessories, or workshop services under HSN / SAC statutory classifications.
class GstRateEntity extends Equatable {
  final String id;
  final String taxName;
  final String hsnSacCode;
  final double gstRate; // Total GST % (e.g. 28.0, 5.0, 18.0)
  final double cgstRate; // Central GST % (e.g. 14.0, 2.5, 9.0)
  final double sgstRate; // State GST % (e.g. 14.0, 2.5, 9.0)
  final double igstRate; // Integrated GST % (e.g. 28.0, 5.0, 18.0)
  final double cessRate; // Compensation Cess % (e.g. 0.0)
  final String category; // 'vehicle_ice', 'vehicle_ev', 'spare_parts', 'service_labor', 'accessories', 'documentation', 'other'
  final String? description;
  final bool isActive;
  final DateTime effectiveFrom;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GstRateEntity({
    required this.id,
    required this.taxName,
    required this.hsnSacCode,
    required this.gstRate,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    this.cessRate = 0.0,
    required this.category,
    this.description,
    this.isActive = true,
    required this.effectiveFrom,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory helper that automatically calculates CGST, SGST, and IGST rates
  /// evenly from a given total GST percentage.
  factory GstRateEntity.standard({
    required String id,
    required String taxName,
    required String hsnSacCode,
    required double totalGstRate,
    double cessRate = 0.0,
    required String category,
    String? description,
    bool isActive = true,
    required DateTime effectiveFrom,
  }) {
    final halfRate = totalGstRate / 2.0;
    return GstRateEntity(
      id: id,
      taxName: taxName,
      hsnSacCode: hsnSacCode,
      gstRate: totalGstRate,
      cgstRate: halfRate,
      sgstRate: halfRate,
      igstRate: totalGstRate,
      cessRate: cessRate,
      category: category,
      description: description,
      isActive: isActive,
      effectiveFrom: effectiveFrom,
    );
  }

  /// Display badge label for the category
  String get categoryLabel {
    switch (category) {
      case 'vehicle_ice':
        return 'Petrol Vehicle';
      case 'vehicle_ev':
        return 'Electric Vehicle (EV)';
      case 'spare_parts':
        return 'Spare Parts';
      case 'service_labor':
        return 'Workshop Labor';
      case 'accessories':
        return 'Accessories';
      case 'documentation':
        return 'Documentation';
      default:
        return 'General';
    }
  }

  /// CopyWith for immutability
  GstRateEntity copyWith({
    String? id,
    String? taxName,
    String? hsnSacCode,
    double? gstRate,
    double? cgstRate,
    double? sgstRate,
    double? igstRate,
    double? cessRate,
    String? category,
    String? description,
    bool? isActive,
    DateTime? effectiveFrom,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GstRateEntity(
      id: id ?? this.id,
      taxName: taxName ?? this.taxName,
      hsnSacCode: hsnSacCode ?? this.hsnSacCode,
      gstRate: gstRate ?? this.gstRate,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      igstRate: igstRate ?? this.igstRate,
      cessRate: cessRate ?? this.cessRate,
      category: category ?? this.category,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taxName,
        hsnSacCode,
        gstRate,
        cgstRate,
        sgstRate,
        igstRate,
        cessRate,
        category,
        description,
        isActive,
        effectiveFrom,
      ];
}
