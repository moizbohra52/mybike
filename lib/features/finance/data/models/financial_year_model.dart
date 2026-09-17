import '../../domain/entities/financial_year_entity.dart';

/// Financial Year Data Model with JSON serialization
class FinancialYearModel extends FinancialYearEntity {
  const FinancialYearModel({
    required super.id,
    required super.name,
    required super.startDate,
    required super.endDate,
    super.isCurrent = false,
    super.isLocked = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FinancialYearModel.fromJson(Map<String, dynamic> json) {
    return FinancialYearModel(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isCurrent: json['is_current'] as bool? ?? false,
      isLocked: json['is_locked'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
      'end_date': "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
      'is_current': isCurrent,
      'is_locked': isLocked,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
