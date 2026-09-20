import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/report_filter_criteria.dart';

enum ReportsHubStatus { initial, loading, success, failure }

/// Metadata describing an enterprise report
class ReportMetadata extends Equatable {
  final String id;
  final String title;
  final String category; // 'financial', 'books', 'registers', 'working_capital'
  final String description;
  final IconData icon;
  final Color iconColor;
  final String routeSlug;

  const ReportMetadata({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.routeSlug,
  });

  @override
  List<Object?> get props => [id, title, category, description, icon, iconColor, routeSlug];
}

/// State for the Reports Hub
class ReportsHubState extends Equatable {
  final ReportsHubStatus status;
  final ReportFilterCriteria criteria;
  final String selectedCategory; // 'all', 'financial', 'books', 'registers', 'working_capital'
  final String searchQuery;
  final List<ReportMetadata> reports;
  final String? errorMessage;

  const ReportsHubState({
    this.status = ReportsHubStatus.initial,
    required this.criteria,
    this.selectedCategory = 'all',
    this.searchQuery = '',
    this.reports = const [],
    this.errorMessage,
  });

  List<ReportMetadata> get filteredReports {
    return reports.where((r) {
      if (selectedCategory != 'all' && r.category != selectedCategory) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return r.title.toLowerCase().contains(q) ||
            r.description.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  ReportsHubState copyWith({
    ReportsHubStatus? status,
    ReportFilterCriteria? criteria,
    String? selectedCategory,
    String? searchQuery,
    List<ReportMetadata>? reports,
    String? errorMessage,
  }) {
    return ReportsHubState(
      status: status ?? this.status,
      criteria: criteria ?? this.criteria,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      reports: reports ?? this.reports,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        criteria,
        selectedCategory,
        searchQuery,
        reports,
        errorMessage,
      ];
}
