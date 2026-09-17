import 'package:equatable/equatable.dart';

/// Financial Year Domain Entity (Indian FY: April 1 - March 31)
class FinancialYearEntity extends Equatable {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FinancialYearEntity({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isCurrent = false,
    this.isLocked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if a transaction date falls into this financial year
  bool containsDate(DateTime date) {
    return (date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) &&
        (date.isBefore(endDate) || date.isAtSameMomentAs(endDate));
  }

  @override
  List<Object?> get props => [
        id,
        name,
        startDate,
        endDate,
        isCurrent,
        isLocked,
        createdAt,
        updatedAt,
      ];
}
