import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_record.dart';
import 'package:gym_app/features/workouts/domain/repos/workout_exercise_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_exercise/workout_exercise_state.dart';

class WorkoutExerciseCubit extends Cubit<WorkoutExerciseState> {
  final WorkoutExerciseRepo workoutExerciseRepo;

  WorkoutExerciseCubit({required this.workoutExerciseRepo})
    : super(WorkoutExerciseInitial());

  // Cargar workout exercises
  Future<void> loadWorkoutExercises(String workoutId) async {
    try {
      emit(WorkoutExerciseLoading());

      final exercises = await workoutExerciseRepo.getAllWorkoutExercise(
        workoutId,
      );

      if (isClosed) return;

      emit(WorkoutExercisesLoaded(exercises));
    } catch (e) {
      if (isClosed) return;
      emit(
        WorkoutExerciseError(e.toString()),
      );
    }
  }

  void addRecord(WorkoutRecord record) {
    final current = state;

    if (current is! WorkoutExercisesLoaded) return;

    final updatedExercises = current.workoutExercises.map((exercise) {
      if (exercise.exerciseId == record.id) {
        return exercise.copyWith(
          records: [
            ...exercise.records,
            record,
          ],
        );
      }
      return exercise;
    }).toList();

    emit(WorkoutExercisesLoaded(updatedExercises));
  }
}
