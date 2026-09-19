import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/customer_management_service.dart';
import '../../domain/entities/lead_entity.dart';
import 'lead_pipeline_state.dart';

/// Lead Pipeline Cubit
///
/// Manages the sales lead pipeline with KPI computation,
/// priority filtering, and conversion tracking.
class LeadPipelineCubit extends Cubit<LeadPipelineState> {
  final CustomerManagementService _service;

  LeadPipelineCubit({CustomerManagementService? service})
      : _service = service ?? CustomerManagementService.instance,
        super(const LeadPipelineState());

  /// Load all leads
  Future<void> loadLeads() async {
    emit(state.copyWith(isLoading: true));
    try {
      final leads = await _service.fetchLeads();
      final kpis = _computeKpis(leads);
      emit(state.copyWith(
        isLoading: false,
        leads: leads,
        filteredLeads: leads,
        totalActiveLeads: kpis['totalActive'] as int,
        hotLeads: kpis['hot'] as int,
        warmLeads: kpis['warm'] as int,
        coldLeads: kpis['cold'] as int,
        conversionRate: kpis['conversionRate'] as double,
        avgDaysToClose: kpis['avgDays'] as int,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Apply filters
  void applyFilters({
    String? showroomId,
    String? status,
    String? priority,
    String? searchQuery,
  }) {
    final newShowroom = showroomId ?? state.selectedShowroomId;
    final newStatus = status ?? state.selectedStatus;
    final newPriority = priority ?? state.selectedPriority;
    final newSearch = searchQuery ?? state.searchQuery;

    var filtered = List<LeadEntity>.from(state.leads);

    if (newShowroom != null && newShowroom.isNotEmpty) {
      filtered = filtered.where((l) => l.showroomId == newShowroom).toList();
    }
    if (newStatus != null && newStatus.isNotEmpty) {
      filtered = filtered.where((l) => l.status == newStatus).toList();
    }
    if (newPriority != null && newPriority.isNotEmpty) {
      filtered = filtered.where((l) => l.priority == newPriority).toList();
    }
    if (newSearch.isNotEmpty) {
      final s = newSearch.toLowerCase();
      filtered = filtered.where((l) =>
          l.displayName.toLowerCase().contains(s) ||
          l.leadNumber.toLowerCase().contains(s)).toList();
    }

    emit(state.copyWith(
      filteredLeads: filtered,
      selectedShowroomId: showroomId,
      selectedStatus: status,
      selectedPriority: priority,
      searchQuery: searchQuery,
    ));
  }

  /// Clear all filters
  void clearFilters() {
    emit(state.copyWith(
      filteredLeads: state.leads,
      selectedShowroomId: '',
      selectedStatus: '',
      selectedPriority: '',
      searchQuery: '',
    ));
  }

  /// Search leads
  void search(String query) {
    applyFilters(searchQuery: query);
  }

  Map<String, dynamic> _computeKpis(List<LeadEntity> leads) {
    final active = leads.where((l) => l.isActive).toList();
    final converted = leads.where((l) => l.isConverted).toList();

    // Conversion rate
    final convRate = leads.isNotEmpty
        ? (converted.length / leads.length) * 100
        : 0.0;

    // Average days to close (from converted leads)
    final avgDays = converted.isNotEmpty
        ? (converted.map((l) => l.daysOpen).reduce((a, b) => a + b) / converted.length).round()
        : 0;

    return {
      'totalActive': active.length,
      'hot': leads.where((l) => l.isHot && l.isActive).length,
      'warm': leads.where((l) => l.isWarm && l.isActive).length,
      'cold': leads.where((l) => l.isCold && l.isActive).length,
      'conversionRate': convRate,
      'avgDays': avgDays,
    };
  }
}
