import 'package:gym_app/features/routines_exercises/domain/entities/routine_exercise.dart';
import 'package:gym_app/features/routines_exercises/domain/entities/routine_exercise_pagination.dart';

abstract class RoutineExerciseRepo {
  Future<List<RoutineExercise>> getAllRoutinesExercises({
    required String routineId,
  });

  Future<RoutineExercise> getRoutineExercise(String routineExerciseId);

  Future<RoutineExercise> createRoutineExercise({
    required String name,
  });

  Future<RoutineExercise> updateRoutineExercise({
    required String name,
    required String routineExerciseId,
  });

  Future<void> deleteRoutineExercise(String routineId);
}
