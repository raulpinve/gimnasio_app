import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/features/routines_exercises/domain/repos/routine_exercise_repo.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_list/routine_exercises_list_state.dart';

class RoutineExercisesListCubit extends Cubit<RoutineExercisesListState> {
  final RoutineExerciseRepo routineExerciseRepo;

  RoutineExercisesListCubit({required this.routineExerciseRepo})
    : super(RoutineExercisesListInicial());

  // ============================================================
  // CARGAR ROUTINE EXERCISES
  // ============================================================
  Future<void> loadRoutineExercises(
    String routineId,
  ) async {
    try {
      emit(RoutineExercisesListLoading());

      final result = await routineExerciseRepo.getAllRoutinesExercises(
        routineId: routineId,
      );
      if (isClosed) return;

      emit(RoutineExercisesListLoaded(routineExercises: result));
    } on ApiError catch (e) {
      if (isClosed) return;

      emit(
        RoutineExercisesListError(
          e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        RoutineExercisesListError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> deleteRoutineExercise(
    String workoutRecordId,
  ) async {
    try {
      if (isClosed) return;

      final currentState = state;
      if (currentState is! RoutineExercisesListLoaded) return;

      emit(
        currentState.copyWith(
          isDeleting: true,
        ),
      );

      await routineExerciseRepo.deleteRoutineExercise(
        workoutRecordId,
      );

      if (isClosed) return;

      emit(
        currentState.copyWith(
          routineExercises: currentState.routineExercises
              .where(
                (record) => record.id != workoutRecordId,
              )
              .toList(),
          isDeleting: false,
        ),
      );
    } on ApiError catch (e) {
      if (isClosed) return;

      emit(
        RoutineExercisesListError(
          e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        RoutineExercisesListError(
          e.toString(),
        ),
      );
    }
  }
}
