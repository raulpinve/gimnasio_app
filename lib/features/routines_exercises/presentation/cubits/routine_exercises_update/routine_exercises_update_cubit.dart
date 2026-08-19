import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/features/exercise/domain/repos/exercise_repo.dart';
import 'package:gym_app/features/routines_exercises/domain/repos/routine_exercise_repo.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_update/routine_exercises_update_state.dart';

class RoutineExercisesUpdateCubit extends Cubit<RoutineExercisesUpdateState> {
  final String routineExerciseId;
  final RoutineExerciseRepo routineExerciseRepo;
  final ExerciseRepo exerciseRepo;

  RoutineExercisesUpdateCubit({
    required this.routineExerciseRepo,
    required this.exerciseRepo,
    required this.routineExerciseId,
  }) : super(RoutineExercisesUpdateState());

  // Obtener ejercicio de la rutina por ID
  Future<void> getRoutineExerciseById() async {
    try {
      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: true,
          errorMessage: null,
          fieldErrors: null,
        ),
      );

      // Obtener la relación ejercicio-rutina
      final routineExercise = await routineExerciseRepo.getRoutineExerciseById(
        routineExerciseId,
      );

      // Obtener el ejercicio completo
      final exercise = await exerciseRepo.getExercise(
        routineExercise.exerciseId!,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          routineExercise: routineExercise,
          selectedExercise: exercise,
          isLoading: false,
        ),
      );
    } on ApiError catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Ocurrió un error inesperado',
        ),
      );
    }
  }

  // Actualizar ejercicio en la rutina
  Future<void> updateRoutineExercise(
    Map<String, dynamic> routineExerciseBody,
  ) async {
    try {
      if (isClosed) return;

      emit(
        state.copyWith(
          isUpdating: true,
          errorMessage: null,
          fieldErrors: null,
        ),
      );

      await routineExerciseRepo.updateRoutineExercise(
        routineExerciseId,
        routineExerciseBody,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          isUpdating: false,
          isUpdated: true,
        ),
      );
    } on ApiError catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: 'Ocurrió un error inesperado',
        ),
      );
    }
  }
}
