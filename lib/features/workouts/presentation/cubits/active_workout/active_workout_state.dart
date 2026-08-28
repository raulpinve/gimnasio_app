import 'package:gym_app/features/workouts/domain/entities/workout.dart';

abstract class ActiveWorkoutState {}

class ActiveWorkoutInitial extends ActiveWorkoutState {}

class ActiveWorkoutLoading extends ActiveWorkoutState {}

class ActiveWorkoutLoaded extends ActiveWorkoutState {
  final Workout? workout;

  ActiveWorkoutLoaded(this.workout);
}

class ActiveWorkoutError extends ActiveWorkoutState {
  final String message;

  ActiveWorkoutError(this.message);
}
