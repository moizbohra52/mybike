import 'package:equatable/equatable.dart';
import '../../domain/entities/party_outstanding_entity.dart';

/// Outstanding State (Receivables / Payables Aging)
class OutstandingState extends Equatable {
  final bool isLoading;
  final String? error;

  final List<PartyOutstandingEntity> customerReceivables;
  final List<PartyOutstandingEntity> filteredReceivables;

  final List<PartyOutstandingEntity> supplierPayables;
  final List<PartyOutstandingEntity> filteredPayables;

  final String activeTab; // 'receivables' (Customers) or 'payables' (Suppliers/OEMs)
  final String searchQuery;
  final String? selectedShowroomId;

  // Aggregated KPIs
  final double totalReceivables;
  final double totalPayables;
  final double netBalance;
  final double totalOverdue;

  const OutstandingState({
    this.isLoading = false,
    this.error,
    this.customerReceivables = const [],
    this.filteredReceivables = const [],
    this.supplierPayables = const [],
    this.filteredPayables = const [],
    this.activeTab = 'receivables',
    this.searchQuery = '',
    this.selectedShowroomId,
    this.totalReceivables = 0.0,
    this.totalPayables = 0.0,
    this.netBalance = 0.0,
    this.totalOverdue = 0.0,
  });

  bool get isReceivablesTab => activeTab == 'receivables';

  OutstandingState copyWith({
    bool? isLoading,
    String? error,
    List<PartyOutstandingEntity>? customerReceivables,
    List<PartyOutstandingEntity>? filteredReceivables,
    List<PartyOutstandingEntity>? supplierPayables,
    List<PartyOutstandingEntity>? filteredPayables,
    String? activeTab,
    String? searchQuery,
    String? selectedShowroomId,
    double? totalReceivables,
    double? totalPayables,
    double? netBalance,
    double? totalOverdue,
  }) {
    return OutstandingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      customerReceivables: customerReceivables ?? this.customerReceivables,
      filteredReceivables: filteredReceivables ?? this.filteredReceivables,
      supplierPayables: supplierPayables ?? this.supplierPayables,
      filteredPayables: filteredPayables ?? this.filteredPayables,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedShowroomId: selectedShowroomId ?? this.selectedShowroomId,
      totalReceivables: totalReceivables ?? this.totalReceivables,
      totalPayables: totalPayables ?? this.totalPayables,
      netBalance: netBalance ?? this.netBalance,
      totalOverdue: totalOverdue ?? this.totalOverdue,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        customerReceivables,
        filteredReceivables,
        supplierPayables,
        filteredPayables,
        activeTab,
        searchQuery,
        selectedShowroomId,
        totalReceivables,
        totalPayables,
        netBalance,
        totalOverdue,
      ];
}
