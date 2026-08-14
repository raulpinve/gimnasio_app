import 'package:gym_app/features/workouts/domain/entities/workout_exercise.dart';

abstract class WorkoutExerciseRepo {
  Future<List<WorkoutExercise>> getAllWorkoutExercise(String workoutId);

  Future<WorkoutExercise> getWorkoutExerciseById(String workoutExerciseId);

  Future<WorkoutExercise> createWorkoutExercise(
    String workoutId,
    String exerciseId,
  );
}
