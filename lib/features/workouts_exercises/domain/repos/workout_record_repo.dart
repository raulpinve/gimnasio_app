import 'package:gym_app/core/enums/workout_type.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_record.dart';

abstract class WorkoutRecordRepo {
  Future<List<WorkoutRecord>> getAllWorkoutRecords(
    String wokoutExerciseId,
    ExerciseType exerciseType,
  );

  Future<WorkoutRecord> createWorkoutRecord(
    ExerciseType exerciseType,
    Map<String, dynamic> workoutRecordBody,
  );

  Future<WorkoutRecord> updateWorkoutRecord(
    String workoutRecordId,
    ExerciseType exerciseType,
    Map<String, dynamic> workoutRecordBody,
  );

  Future<void> deleteWorkoutRecord(
    String workoutRecordId,
    ExerciseType exerciseType,
  );
}
