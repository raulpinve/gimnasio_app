import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/workouts_exercises/domain/repos/workout_exercise_repo.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercise_detail/workout_exercise_detail_state.dart';

class WorkoutExerciseDetailCubit extends Cubit<WorkoutExerciseDetailState> {
  final WorkoutExerciseRepo workoutExerciseRepo;

  WorkoutExerciseDetailCubit({required this.workoutExerciseRepo})
    : super(WorkoutExerciseDetailInitial());

  // Obtener el workoutExercise
  Future<void> loadWorkoutExerciseById(
    String workoutExerciseId,
  ) async {
    try {
      emit(WorkoutExerciseDetailLoading());

      final response = await workoutExerciseRepo.getWorkoutExerciseById(
        workoutExerciseId,
      );
      if (isClosed) return;

      emit(WorkoutExerciseDetailLoaded(workoutExercise: response));
    } catch (e) {
      if (isClosed) return;
      emit(WorkoutExerciseDetailError(e.toString()));
    }
  }

  // Create workoutExercise
  Future<void> createWorkoutExercise(
    String workoutId,
    String exerciseId,
  ) async {
    try {
      debugPrint(
        'CREANDO WorkoutExercise: workout=$workoutId exercise=$exerciseId',
      );

      emit(WorkoutExerciseDetailLoading());

      final result = await workoutExerciseRepo.createWorkoutExercise(
        workoutId,
        exerciseId,
      );

      debugPrint('WorkoutExercise creado: $result');

      if (isClosed) return;

      emit(WorkoutExerciseDetailCreated());
    } catch (e, stackTrace) {
      debugPrint('ERROR creando WorkoutExercise: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (isClosed) return;

      emit(
        WorkoutExerciseDetailError(
          e.toString(),
        ),
      );
    }
  }
}
