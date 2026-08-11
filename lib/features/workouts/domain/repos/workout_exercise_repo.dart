import 'package:gym_app/core/enums/workout_type.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_exercise.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_record.dart';

abstract class WorkoutExerciseRepo {
  Future<List<WorkoutExercise>> getAllWorkoutExercise(String workoutId);

  Future<WorkoutRecord> createWorkoutRecord(
    WorkoutType workoutType,
    Map<String, dynamic> workoutRecordBody,
  );
}
