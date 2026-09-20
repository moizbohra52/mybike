import 'package:equatable/equatable.dart';
import '../../domain/entities/trial_balance_item_entity.dart';

/// Trial Balance State
class TrialBalanceState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<TrialBalanceItemEntity> items;
  final double totalDebit;
  final double totalCredit;
  final double difference;
  final bool isBalanced;
  final DateTime asOfDate;
  final String? selectedShowroomId;

  const TrialBalanceState({
    this.isLoading = false,
    this.error,
    this.items = const [],
    this.totalDebit = 0.0,
    this.totalCredit = 0.0,
    this.difference = 0.0,
    this.isBalanced = true,
    required this.asOfDate,
    this.selectedShowroomId,
  });

  TrialBalanceState copyWith({
    bool? isLoading,
    String? error,
    List<TrialBalanceItemEntity>? items,
    double? totalDebit,
    double? totalCredit,
    double? difference,
    bool? isBalanced,
    DateTime? asOfDate,
    String? selectedShowroomId,
  }) {
    return TrialBalanceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
      totalDebit: totalDebit ?? this.totalDebit,
      totalCredit: totalCredit ?? this.totalCredit,
      difference: difference ?? this.difference,
      isBalanced: isBalanced ?? this.isBalanced,
      asOfDate: asOfDate ?? this.asOfDate,
      selectedShowroomId: selectedShowroomId ?? this.selectedShowroomId,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        items,
        totalDebit,
        totalCredit,
        difference,
        isBalanced,
        asOfDate,
        selectedShowroomId,
      ];
}
