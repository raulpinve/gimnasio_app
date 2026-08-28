import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/workouts/domain/repos/workout_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/active_workout/active_workout_state.dart';

class ActiveWorkoutCubit extends Cubit<ActiveWorkoutState> {
  final WorkoutRepo workoutRepo;

  ActiveWorkoutCubit({
    required this.workoutRepo,
  }) : super(ActiveWorkoutInitial());

  Future<void> loadActiveWorkout({bool showLoading = true}) async {
    if (isClosed) return;

    if (showLoading) {
      emit(ActiveWorkoutLoading());
    }

    try {
      final workout = await workoutRepo.getActiveWorkout();

      if (isClosed) return;

      emit(ActiveWorkoutLoaded(workout));
    } catch (e) {
      if (isClosed) return;

      emit(ActiveWorkoutError(e.toString()));
    }
  }
}
