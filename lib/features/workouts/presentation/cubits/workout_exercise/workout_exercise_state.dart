import 'package:gym_app/features/workouts_exercises/domain/entities/workout_exercise.dart';

abstract class WorkoutExerciseState {}

// Estado inicial
class WorkoutExerciseInitial extends WorkoutExerciseState {}

// Estado para cargar la lista inicialmente
class WorkoutExerciseLoading extends WorkoutExerciseState {}

// Ejercicios cargados
class WorkoutExercisesLoaded extends WorkoutExerciseState {
  final List<WorkoutExercise> workoutExercises;

  WorkoutExercisesLoaded(this.workoutExercises);
}

// Error al cargar los ejercicios
class WorkoutExerciseError extends WorkoutExerciseState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  WorkoutExerciseError(
    this.message, {
    this.fieldErrors,
  });
}

// -----------------------------
// Estados para registrar una serie
// -----------------------------

// Guardando una serie
class WorkoutExerciseSaving extends WorkoutExerciseState {}

// Serie registrada correctamente
class WorkoutExerciseSaveSuccess extends WorkoutExerciseState {
  final List<WorkoutExercise> workoutExercises;

  WorkoutExerciseSaveSuccess(this.workoutExercises);
}

// Error al registrar una serie
class WorkoutExerciseSaveError extends WorkoutExerciseState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  WorkoutExerciseSaveError(
    this.message, {
    this.fieldErrors,
  });
}
