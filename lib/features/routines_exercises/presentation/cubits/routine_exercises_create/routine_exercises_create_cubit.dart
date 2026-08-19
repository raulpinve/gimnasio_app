import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:gym_app/features/routines_exercises/domain/repos/routine_exercise_repo.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_create/routine_exercises_create_state.dart';

class RoutineExercisesCreateCubit extends Cubit<RoutineExercisesCreateState> {
  final RoutineExerciseRepo routineExerciseRepo;

  RoutineExercisesCreateCubit({
    required this.routineExerciseRepo,
  }) : super(
         const RoutineExercisesCreateState(),
       );

  // Seleccionar ejercicio
  void selectExercise(Exercise exercise) {
    emit(
      state.copyWith(
        selectedExercise: exercise,
      ),
    );
  }

  // Agregar ejercicio a la rutina
  Future<void> createRoutineExercise(
    Map<String, dynamic> routineExerciseBody,
  ) async {
    try {
      if (isClosed) return;

      emit(
        state.copyWith(
          isCreating: true,
          errorMessage: null,
          fieldErrors: null,
        ),
      );

      await routineExerciseRepo.createRoutineExercise(
        routineExerciseBody,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          isCreating: false,
          isCreated: true,
        ),
      );
    } on ApiError catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isCreating: false,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isCreating: false,
          errorMessage: 'Ocurrió un error inesperado.',
        ),
      );
    }
  }
}
