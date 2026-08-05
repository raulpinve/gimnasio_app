import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/workouts/domain/repos/workout_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_detail_state.dart';

class WorkoutDetailCubit extends Cubit<WorkoutDetailState> {
  final WorkoutRepo workoutRepo;

  WorkoutDetailCubit({required this.workoutRepo})
    : super(WorkoutDetailInitial());

  // Cargar workout
  Future<void> loadWorkoutById(String workoutId) async {
    try {
      emit(WorkoutDetailLoading());
      final response = await workoutRepo.getWorkout(workoutId);
      emit(WorkoutDetailLoaded(workout: response));
    } catch (e) {
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

      emit(WorkoutDetailDeleted());
    } catch (e) {
      emit(
        WorkoutDetailError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> finishWorkout(String workoutId) async {
    try {
      emit(WorkoutDetailLoading());

      await workoutRepo.finishWorkout(workoutId);

      await loadWorkoutById(workoutId);
    } catch (e) {
      emit(WorkoutDetailError(e.toString()));
    }
  }
}
