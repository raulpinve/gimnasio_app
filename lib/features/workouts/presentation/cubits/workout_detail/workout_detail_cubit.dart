import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/workouts/domain/repos/workout_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_detail/workout_detail_state.dart';

class WorkoutDetailCubit extends Cubit<WorkoutDetailState> {
  final WorkoutRepo workoutRepo;

  WorkoutDetailCubit({required this.workoutRepo})
    : super(WorkoutDetailInitial());

  // Cargar workout
  Future<void> loadWorkoutById(String workoutId) async {
    try {
      emit(WorkoutDetailLoading());

      final response = await workoutRepo.getWorkout(workoutId);

      if (isClosed) return;

      emit(WorkoutDetailLoaded(workout: response));
    } catch (e) {
      if (isClosed) return;
      emit(
        WorkoutDetailError(
          e.toString(),
        ),
      );
    }
  }

  // Delete routine
  Future<void> deleteWorkout(String workoutId) async {
    try {
      emit(WorkoutDetailDeleting());

      await workoutRepo.deleteWorkout(workoutId);
      if (isClosed) return;

      emit(WorkoutDetailDeleted());
    } catch (e) {
      if (isClosed) return;

      emit(
        WorkoutDetailError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> finishWorkout(String workoutId) async {
    try {
      emit(WorkoutDetailFinishing());

      await workoutRepo.finishWorkout(workoutId);

      if (isClosed) return;

      emit(WorkoutDetailFinished());

      await loadWorkoutById(workoutId);
    } catch (e) {
      if (isClosed) return;

      emit(
        WorkoutDetailError(
          e.toString(),
        ),
      );
    }
  }
}
