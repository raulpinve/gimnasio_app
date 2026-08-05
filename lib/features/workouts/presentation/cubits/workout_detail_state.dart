import 'package:gym_app/features/workouts/domain/entities/workout.dart';

abstract class WorkoutDetailState {}

class WorkoutDetailInitial extends WorkoutDetailState {}

class WorkoutDetailLoading extends WorkoutDetailState {}

class WorkoutDetailLoaded extends WorkoutDetailState {
  final Workout workout;
  WorkoutDetailLoaded({
    required this.workout,
  });
}

class WorkoutDetailDeleting extends WorkoutDetailState {}

class WorkoutDetailDeleted extends WorkoutDetailState {}

class WorkoutDetailError extends WorkoutDetailState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  WorkoutDetailError(
    this.message, {
    this.fieldErrors,
  });
}
