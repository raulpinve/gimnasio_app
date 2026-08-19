import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/routines/domain/repos/routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine/routine_detail_state.dart';

class RoutineDetailCubit extends Cubit<RoutineDetailState> {
  final RoutineRepo routineRepo;

  RoutineDetailCubit({
    required this.routineRepo,
  }) : super(RoutineDetailInitial());

  Future<void> loadRoutineDetail(String routineId) async {
    try {
      if (isClosed) {
        return;
      }
      emit(RoutineDetailLoading());

      final routine = await routineRepo.getRoutine(routineId);
      if (isClosed) return;

      emit(RoutineDetailLoaded(routine: routine));
    } catch (e) {
      if (isClosed) return;
      emit(RoutineDetailError(e.toString()));
    }
  }
}
