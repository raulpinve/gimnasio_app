import 'package:gym_app/features/workouts/domain/entities/workout_exercise.dart';

abstract class WorkoutExerciseDetailState {}

// Estado inicial
class WorkoutExerciseDetailInitial extends WorkoutExerciseDetailState {}

// Estado para cargar el ejercicio en la rutina
class WorkoutExerciseDetailLoading extends WorkoutExerciseDetailState {}

// Estado con el ejercicio cargado
class WorkoutExerciseDetailLoaded extends WorkoutExerciseDetailState {
  final WorkoutExercise workoutExercise;
  final bool isDeleting;

  WorkoutExerciseDetailLoaded({
    required this.workoutExercise,
    this.isDeleting = false,
  });

  WorkoutExerciseDetailLoaded copyWith({
    WorkoutExercise? workoutExercise,
    bool? isDeleting,
  }) {
    return WorkoutExerciseDetailLoaded(
      workoutExercise: workoutExercise ?? this.workoutExercise,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

// Estado para indicar el estado de error
class WorkoutExerciseDetailError extends WorkoutExerciseDetailState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  WorkoutExerciseDetailError(
    this.message, {
    this.fieldErrors,
  });
}
