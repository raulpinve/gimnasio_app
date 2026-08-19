import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/routines/domain/repos/routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine/routine_detail_state.dart';

class RoutineDetailCubit extends Cubit<RoutineDetailState> {
  final RoutineRepo routineRepo;

  RoutineDetailCubit({
    required this.routineRepo,
  }) : super(RoutineDetailInitial()) {
    debugPrint('>>> CUBIT CONSTRUIDO: $hashCode');
  }

  Future<void> loadRoutineDetail(String routineId) async {
    debugPrint('>>> LOAD ROUTINE LLAMADO: $routineId');

    try {
      if (isClosed) {
        debugPrint('>>> CUBIT CERRADO');
        return;
      }

      emit(RoutineDetailLoading());

      debugPrint('>>> LOADING EMITIDO');

      final routine = await routineRepo.getRoutine(routineId);

      debugPrint('>>> GET ROUTINE TERMINÓ');

      if (isClosed) return;

      emit(RoutineDetailLoaded(routine: routine));

      debugPrint('>>> LOADED EMITIDO');
    } catch (e) {
      debugPrint('>>> ERROR: $e');

      if (isClosed) return;

      emit(RoutineDetailError(e.toString()));
    }
  }
}
