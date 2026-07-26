import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise_progress.dart';
import '../entities/exercise_pagination.dart';

abstract class ExerciseRepo {
  Future<ExercisePagination> getAllExercises({
    int page = 1,
    String name = "",
    String muscleGroup = "",
  });

  Future<Exercise> createExercise({
    required String name,
    required List<String> muscleGroups,
    String? equipment,
    required String type,
  });

  //  Agrega este método para soportar la nueva pantalla de detalle
  Future<Exercise> getExercise(String id);

  Future<(List<ExerciseProgress> progressList, String unit)>
  getExerciseProgress(String id);
}
