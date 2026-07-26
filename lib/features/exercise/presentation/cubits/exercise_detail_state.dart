import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise_progress.dart';

abstract class ExerciseDetailState {}

// Estado inicial
class ExerciseDetailInitial extends ExerciseDetailState {}

// Estado para cargar la información del ejercicio
class ExerciseDetailLoading extends ExerciseDetailState {}

// Ejercicio cargado
class ExerciseDetailLoaded extends ExerciseDetailState {
  final Exercise exercise;
  final List<ExerciseProgress> progress;
  final String unit;

  ExerciseDetailLoaded({
    required this.exercise,
    required this.progress,
    required this.unit,
  });
}

// Error
class ExerciseDetailError extends ExerciseDetailState {
  final String message;
  ExerciseDetailError(this.message);
}
