import 'package:gym_app/features/workouts_exercises/domain/entities/workout_exercise.dart';

abstract class WorkoutExercisesListState {}

// Estado inicial
class WorkoutExercisesListInitial extends WorkoutExercisesListState {}

// Estado para cargar la lista inicialmente
class WorkoutExercisesListLoading extends WorkoutExercisesListState {}

class WorkoutExercisesListLoaded extends WorkoutExercisesListState {
  final List<WorkoutExercise> workoutExercises;
  final bool isDeleting;
  final String? errorMessage;

  WorkoutExercisesListLoaded({
    required this.workoutExercises,
    this.isDeleting = false,
    this.errorMessage,
  });

  WorkoutExercisesListLoaded copyWith({
    List<WorkoutExercise>? workoutExercises,
    int? totalPages,
    bool? isDeleting,
    String? errorMessage,
  }) {
    return WorkoutExercisesListLoaded(
      workoutExercises: workoutExercises ?? this.workoutExercises,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage,
    );
  }
}

class WorkoutExercisesListError extends WorkoutExercisesListState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  WorkoutExercisesListError(this.message, {this.fieldErrors});
}
