import 'package:equatable/equatable.dart';
import '../../domain/entities/approval_rule_entity.dart';

abstract class ApprovalRulesState extends Equatable {
  const ApprovalRulesState();

  @override
  List<Object?> get props => [];
}

class ApprovalRulesInitial extends ApprovalRulesState {
  const ApprovalRulesInitial();
}

class ApprovalRulesLoading extends ApprovalRulesState {
  const ApprovalRulesLoading();
}

class ApprovalRulesLoaded extends ApprovalRulesState {
  final List<ApprovalRuleEntity> rules;
  final String? successMessage;

  const ApprovalRulesLoaded({
    required this.rules,
    this.successMessage,
  });

  ApprovalRulesLoaded copyWith({
    List<ApprovalRuleEntity>? rules,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return ApprovalRulesLoaded(
      rules: rules ?? this.rules,
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [rules, successMessage];
}

class ApprovalRulesError extends ApprovalRulesState {
  final String message;

  const ApprovalRulesError(this.message);

  @override
  List<Object?> get props => [message];
}
