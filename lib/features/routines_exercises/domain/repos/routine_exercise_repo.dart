import 'package:gym_app/features/routines_exercises/domain/entities/routine_exercise.dart';

abstract class RoutineExerciseRepo {
  Future<List<RoutineExercise>> getAllRoutinesExercises({
    required String routineId,
  });

  Future<RoutineExercise> getRoutineExercise(String routineExerciseId);

  Future<RoutineExercise> createRoutineExercise(
    Map<String, dynamic> routineExerciseBody,
  );

  Future<RoutineExercise> getRoutineExerciseById(
    String routineExerciseId,
  );

  Future<void> updateRoutineExercise(
    String routineExerciseId,
    Map<String, dynamic> routineExerciseBody,
  );
  Future<void> deleteRoutineExercise(String routineId);
}
