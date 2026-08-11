import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/features/workouts/domain/repos/workout_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/create_workout/workout_create_state.dart';

class WorkoutCreateCubit extends Cubit<WorkoutCreateState> {
  final WorkoutRepo workoutRepo;

  WorkoutCreateCubit({
    required this.workoutRepo,
  }) : super(
         const WorkoutCreateState(),
       );

  // Agregar workout
  Future<void> createWorkout(
    Map<String, dynamic> workoutBody,
  ) async {
    try {
      if (isClosed) return;

      emit(
        state.copyWith(
          isCreating: true,
          errorMessage: null,
          fieldErrors: null,
        ),
      );

      final workout = await workoutRepo.createWorkout(
        workoutBody: workoutBody,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          isCreating: false,
          isCreated: true,
          workoutId: workout.id,
        ),
      );
    } on ApiError catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isCreating: false,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isCreating: false,
          errorMessage: 'Ocurrió un error inesperado.',
        ),
      );
    }
  }
}
