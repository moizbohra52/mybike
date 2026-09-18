import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/showroom_management_service.dart';
import 'showroom_list_state.dart';

/// Cubit managing showroom directory, KPIs, search, and active/inactive filters
class ShowroomListCubit extends Cubit<ShowroomListState> {
  final ShowroomManagementService _service;

  ShowroomListCubit({ShowroomManagementService? service})
      : _service = service ?? ShowroomManagementService.instance,
        super(const ShowroomListInitial());

  /// Load all showrooms with initial or preserved filters
  Future<void> loadShowrooms({bool refresh = false}) async {
    String? currentSearch;
    bool? currentActive;
    String? currentCity;

    if (state is ShowroomListLoaded && !refresh) {
      final loaded = state as ShowroomListLoaded;
      currentSearch = loaded.searchQuery;
      currentActive = loaded.activeFilter;
      currentCity = loaded.cityFilter;
    }

    emit(const ShowroomListLoading());

    try {
      final showrooms = await _service.fetchShowrooms(
        search: currentSearch,
        isActive: currentActive,
        city: currentCity,
      );

      emit(ShowroomListLoaded(
        showrooms: showrooms,
        searchQuery: currentSearch,
        activeFilter: currentActive,
        cityFilter: currentCity,
      ));
    } catch (e) {
      emit(ShowroomListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Search showrooms by name, code, or city
  Future<void> searchShowrooms(String query) async {
    final trimmed = query.trim();
    final currentActive = state is ShowroomListLoaded ? (state as ShowroomListLoaded).activeFilter : null;
    final currentCity = state is ShowroomListLoaded ? (state as ShowroomListLoaded).cityFilter : null;

    try {
      final showrooms = await _service.fetchShowrooms(
        search: trimmed.isEmpty ? null : trimmed,
        isActive: currentActive,
        city: currentCity,
      );

      emit(ShowroomListLoaded(
        showrooms: showrooms,
        searchQuery: trimmed.isEmpty ? null : trimmed,
        activeFilter: currentActive,
        cityFilter: currentCity,
      ));
    } catch (e) {
      emit(ShowroomListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Filter showrooms by active / inactive status
  Future<void> filterByActive(bool? isActive) async {
    final currentSearch = state is ShowroomListLoaded ? (state as ShowroomListLoaded).searchQuery : null;
    final currentCity = state is ShowroomListLoaded ? (state as ShowroomListLoaded).cityFilter : null;

    try {
      final showrooms = await _service.fetchShowrooms(
        search: currentSearch,
        isActive: isActive,
        city: currentCity,
      );

      emit(ShowroomListLoaded(
        showrooms: showrooms,
        searchQuery: currentSearch,
        activeFilter: isActive,
        cityFilter: currentCity,
      ));
    } catch (e) {
      emit(ShowroomListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Clear all search and filter conditions
  Future<void> clearFilters() async {
    emit(const ShowroomListLoading());
    try {
      final showrooms = await _service.fetchShowrooms();
      emit(ShowroomListLoaded(showrooms: showrooms));
    } catch (e) {
      emit(ShowroomListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Toggle active / inactive status of a showroom
  Future<void> toggleShowroomStatus(String showroomId, bool newStatus) async {
    try {
      await _service.toggleShowroomStatus(showroomId, newStatus);
      await loadShowrooms();
    } catch (e) {
      emit(ShowroomListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
