import 'package:equatable/equatable.dart';
import '../../domain/entities/lead_entity.dart';

/// Lead Pipeline View State
class LeadPipelineState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<LeadEntity> leads;
  final List<LeadEntity> filteredLeads;
  // Filters
  final String? selectedShowroomId;
  final String? selectedStatus;
  final String? selectedPriority;
  final String searchQuery;
  // KPIs
  final int totalActiveLeads;
  final int hotLeads;
  final int warmLeads;
  final int coldLeads;
  final double conversionRate;
  final int avgDaysToClose;

  const LeadPipelineState({
    this.isLoading = false,
    this.error,
    this.leads = const [],
    this.filteredLeads = const [],
    this.selectedShowroomId,
    this.selectedStatus,
    this.selectedPriority,
    this.searchQuery = '',
    this.totalActiveLeads = 0,
    this.hotLeads = 0,
    this.warmLeads = 0,
    this.coldLeads = 0,
    this.conversionRate = 0.0,
    this.avgDaysToClose = 0,
  });

  LeadPipelineState copyWith({
    bool? isLoading,
    String? error,
    List<LeadEntity>? leads,
    List<LeadEntity>? filteredLeads,
    String? selectedShowroomId,
    String? selectedStatus,
    String? selectedPriority,
    String? searchQuery,
    int? totalActiveLeads,
    int? hotLeads,
    int? warmLeads,
    int? coldLeads,
    double? conversionRate,
    int? avgDaysToClose,
  }) {
    return LeadPipelineState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      leads: leads ?? this.leads,
      filteredLeads: filteredLeads ?? this.filteredLeads,
      selectedShowroomId: selectedShowroomId ?? this.selectedShowroomId,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      searchQuery: searchQuery ?? this.searchQuery,
      totalActiveLeads: totalActiveLeads ?? this.totalActiveLeads,
      hotLeads: hotLeads ?? this.hotLeads,
      warmLeads: warmLeads ?? this.warmLeads,
      coldLeads: coldLeads ?? this.coldLeads,
      conversionRate: conversionRate ?? this.conversionRate,
      avgDaysToClose: avgDaysToClose ?? this.avgDaysToClose,
    );
  }

  @override
  List<Object?> get props => [
        isLoading, error, leads, filteredLeads,
        selectedShowroomId, selectedStatus, selectedPriority, searchQuery,
        totalActiveLeads, hotLeads, warmLeads, coldLeads, conversionRate, avgDaysToClose,
      ];
}
