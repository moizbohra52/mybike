import 'package:equatable/equatable.dart';
import '../../../../core/services/showroom_management_service.dart';

sealed class ShowroomListState extends Equatable {
  const ShowroomListState();

  @override
  List<Object?> get props => [];
}

class ShowroomListInitial extends ShowroomListState {
  const ShowroomListInitial();
}

class ShowroomListLoading extends ShowroomListState {
  const ShowroomListLoading();
}

class ShowroomListLoaded extends ShowroomListState {
  final List<ShowroomWithStats> showrooms;
  final String? searchQuery;
  final bool? activeFilter;
  final String? cityFilter;

  const ShowroomListLoaded({
    required this.showrooms,
    this.searchQuery,
    this.activeFilter,
    this.cityFilter,
  });

  int get totalCount => showrooms.length;
  int get activeCount => showrooms.where((s) => s.showroom.isActive).length;
  int get inactiveCount => totalCount - activeCount;

  int get totalStaffMapped => showrooms.fold<int>(0, (sum, s) => sum + s.staffCount);

  int get totalOperatingCities =>
      showrooms.map((s) => s.showroom.city.toLowerCase().trim()).toSet().length;

  ShowroomListLoaded copyWith({
    List<ShowroomWithStats>? showrooms,
    String? searchQuery,
    bool? activeFilter,
    String? cityFilter,
    bool clearSearch = false,
    bool clearActiveFilter = false,
    bool clearCityFilter = false,
  }) {
    return ShowroomListLoaded(
      showrooms: showrooms ?? this.showrooms,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      activeFilter: clearActiveFilter ? null : (activeFilter ?? this.activeFilter),
      cityFilter: clearCityFilter ? null : (cityFilter ?? this.cityFilter),
    );
  }

  @override
  List<Object?> get props => [showrooms, searchQuery, activeFilter, cityFilter];
}

class ShowroomListError extends ShowroomListState {
  final String message;

  const ShowroomListError(this.message);

  @override
  List<Object?> get props => [message];
}
