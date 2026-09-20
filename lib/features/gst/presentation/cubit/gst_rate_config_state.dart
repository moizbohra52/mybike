import 'package:equatable/equatable.dart';
import '../../domain/entities/gst_rate_entity.dart';

enum GstRateConfigStatus { initial, loading, success, failure }

class GstRateConfigState extends Equatable {
  final GstRateConfigStatus status;
  final List<GstRateEntity> rates;
  final String? selectedCategory; // null for All
  final String searchQuery;
  final String? errorMessage;
  final String? actionSuccessMessage;

  const GstRateConfigState({
    this.status = GstRateConfigStatus.initial,
    this.rates = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.errorMessage,
    this.actionSuccessMessage,
  });

  List<GstRateEntity> get filteredRates {
    return rates.where((r) {
      final matchesCat = selectedCategory == null || r.category == selectedCategory;
      final q = searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          r.taxName.toLowerCase().contains(q) ||
          r.hsnSacCode.toLowerCase().contains(q) ||
          (r.description?.toLowerCase().contains(q) ?? false);
      return matchesCat && matchesSearch;
    }).toList();
  }

  GstRateConfigState copyWith({
    GstRateConfigStatus? status,
    List<GstRateEntity>? rates,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    String? errorMessage,
    String? actionSuccessMessage,
  }) {
    return GstRateConfigState(
      status: status ?? this.status,
      rates: rates ?? this.rates,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        rates,
        selectedCategory,
        searchQuery,
        errorMessage,
        actionSuccessMessage,
      ];
}
