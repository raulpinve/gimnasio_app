import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/enums/workout_type.dart';
import 'package:gym_app/features/workouts/domain/repos/workout_exercise_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_record/workout_record_create_state.dart';

class WorkoutRecordCreateCubit extends Cubit<WorkoutRecordCreateState> {
  final WorkoutExerciseRepo workoutExerciseRepo;

  WorkoutRecordCreateCubit({
    required this.workoutExerciseRepo,
  }) : super(
         WorkoutRecordCreateState(),
       );

  // Agregar record
  Future<void> createRecordWorkout(
    WorkoutType workoutType,
    Map<String, dynamic> workoutRecordBody,
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

      final workoutExercise = await workoutExerciseRepo.createWorkoutRecord(
        workoutType,
        workoutRecordBody,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          isCreating: false,
          isCreated: true,
          workoutExerciseId: workoutExercise.id,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isCreating: false,
          errorMessage: 'Ocurrió un error inesperado',
        ),
      );
    }
  }
}
