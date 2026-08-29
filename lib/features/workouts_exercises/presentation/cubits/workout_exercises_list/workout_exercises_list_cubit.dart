import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/workouts_exercises/domain/repos/workout_exercise_repo.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercises_list/workout_exercises_list_state.dart';

class WorkoutExercisesListCubit extends Cubit<WorkoutExercisesListState> {
  final WorkoutExerciseRepo workoutExerciseRepo;

  WorkoutExercisesListCubit({
    required this.workoutExerciseRepo,
  }) : super(WorkoutExercisesListInitial());

  // ===========================
  // CARGAR WORKOUTS EXERCISES
  //===========================

  Future<void> loadWorkoutExercises(String workoutId) async {
    try {
      emit(WorkoutExercisesListLoading());

      final resultWorkoutExercises = await workoutExerciseRepo
          .getAllWorkoutExercise(
            workoutId,
          );
      if (isClosed) return;
      emit(
        WorkoutExercisesListLoaded(
          workoutExercises: resultWorkoutExercises,
          isDeleting: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        WorkoutExercisesListError(
          e.toString(),
        ),
      );
    }
  }

  Future<bool> deleteWorkoutExercise(String workoutExerciseId) async {
    if (isClosed) return false;

    if (state is! WorkoutExercisesListLoaded) {
      return false;
    }

    final currentState = state as WorkoutExercisesListLoaded;

    emit(
      currentState.copyWith(
        isDeleting: true,
        errorMessage: null,
      ),
    );

    try {
      await workoutExerciseRepo.deleteWorkoutExercise(
        workoutExerciseId,
      );

      if (isClosed) return false;

      final updatedWorkoutExercises = currentState.workoutExercises
          .where(
            (workout) => workout.workoutExerciseId != workoutExerciseId,
          )
          .toList();

      emit(
        currentState.copyWith(
          workoutExercises: updatedWorkoutExercises,
          isDeleting: false,
          errorMessage: null,
        ),
      );

      return true;
    } catch (e) {
      if (isClosed) return false;

      emit(
        currentState.copyWith(
          isDeleting: false,
          errorMessage: e.toString(),
        ),
      );

      return false;
    }
  }
}
