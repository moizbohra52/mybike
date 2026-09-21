import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/approval_workflow_service.dart';
import '../../domain/entities/approval_rule_entity.dart';
import 'approval_rules_state.dart';

class ApprovalRulesCubit extends Cubit<ApprovalRulesState> {
  final ApprovalWorkflowService _service;

  ApprovalRulesCubit({ApprovalWorkflowService? service})
      : _service = service ?? ApprovalWorkflowService.instance,
        super(const ApprovalRulesInitial());

  String? _currentShowroomId;

  Future<void> loadRules({String? showroomId}) async {
    _currentShowroomId = showroomId;
    emit(const ApprovalRulesLoading());
    try {
      final rules = await _service.getRules(showroomId: _currentShowroomId);
      emit(ApprovalRulesLoaded(rules: rules));
    } catch (e) {
      emit(ApprovalRulesError('Failed to load approval rules: $e'));
    }
  }

  Future<void> updateRule(ApprovalRuleEntity rule) async {
    try {
      await _service.updateRule(rule);
      final rules = await _service.getRules(showroomId: _currentShowroomId);
      emit(ApprovalRulesLoaded(
        rules: rules,
        successMessage: 'Policy "${rule.name}" updated successfully.',
      ));
    } catch (e) {
      emit(ApprovalRulesError('Failed to update rule: $e'));
    }
  }

  void clearSuccessMessage() {
    if (state is ApprovalRulesLoaded) {
      emit((state as ApprovalRulesLoaded).copyWith(clearSuccessMessage: true));
    }
  }
}
