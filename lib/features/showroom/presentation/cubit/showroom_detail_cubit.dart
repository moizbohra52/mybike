import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/showroom_management_service.dart';
import '../../../../core/services/showroom_service.dart';
import 'showroom_detail_state.dart';

/// Cubit managing detailed showroom view, staff listing, document sequence updates, and branch context switching
class ShowroomDetailCubit extends Cubit<ShowroomDetailState> {
  final ShowroomManagementService _service;
  final ShowroomService _showroomContextService;

  ShowroomDetailCubit({
    ShowroomManagementService? service,
    ShowroomService? showroomContextService,
  })  : _service = service ?? ShowroomManagementService.instance,
        _showroomContextService = showroomContextService ?? ShowroomService.instance,
        super(const ShowroomDetailInitial());

  /// Load comprehensive showroom data: profile, staff mapped, and document sequences
  Future<void> loadShowroomDetail(String showroomId) async {
    emit(const ShowroomDetailLoading());
    try {
      final showroom = await _service.fetchShowroomById(showroomId);
      if (showroom == null) {
        emit(const ShowroomDetailError('Showroom not found'));
        return;
      }

      final staff = await _service.fetchShowroomStaff(showroomId);
      final sequences = await _service.fetchShowroomSequences(showroomId);

      emit(ShowroomDetailLoaded(
        showroom: showroom,
        staff: staff,
        sequences: sequences,
      ));
    } catch (e) {
      emit(ShowroomDetailError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Update an invoice sequence prefix, start number, or zero padding
  Future<void> updateSequence(
    String sequenceId, {
    String? prefix,
    int? nextNumber,
    int? paddingZeros,
  }) async {
    if (state is! ShowroomDetailLoaded) return;
    final current = state as ShowroomDetailLoaded;

    try {
      final updatedSeq = await _service.updateInvoiceSequence(
        sequenceId,
        prefix: prefix,
        nextNumber: nextNumber,
        paddingZeros: paddingZeros,
      );

      final updatedList = current.sequences.map((s) {
        return s.id == sequenceId ? updatedSeq : s;
      }).toList();

      emit(ShowroomDetailLoaded(
        showroom: current.showroom,
        staff: current.staff,
        sequences: updatedList,
      ));
    } catch (e) {
      emit(ShowroomDetailError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Switch the active dealership operating showroom context
  Future<void> switchOperatingShowroom(String showroomId) async {
    if (state is! ShowroomDetailLoaded) return;
    final current = state as ShowroomDetailLoaded;

    try {
      await _showroomContextService.switchShowroom(current.showroom);
    } catch (e) {
      emit(ShowroomDetailError('Failed to switch active showroom: $e'));
    }
  }
}
