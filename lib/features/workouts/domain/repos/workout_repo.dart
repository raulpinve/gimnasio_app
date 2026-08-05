import 'package:gym_app/features/workouts/domain/entities/workout.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_pagination.dart';

abstract class WorkoutRepo {
  Future<WorkoutPagination> getAllWorkouts({
    int page = 1,
  });

  Future<Workout> getWorkout(String id);

  Future<Workout> createWorkout({
    required Map<String, dynamic> workoutBody,
  });

  Future<void> updateWorkout(
    String workoutId,
    Map<String, dynamic> workoutBody,
  );

  Future<void> deleteWorkout(String workoutId);
  Future<void> finishWorkout(String workoutId);
}
