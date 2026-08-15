import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/enums/workout_type.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/features/workouts_record/presentation/cubits/workout_record_state.dart';
import 'package:gym_app/features/workouts_record/domain/repos/workout_record_repo.dart';

class WorkoutRecordCubit extends Cubit<WorkoutRecordState> {
  final WorkoutRecordRepo workoutRecordRepo;
  WorkoutRecordCubit({required this.workoutRecordRepo})
    : super(WorkoutRecordInitial());

  // ============================================================
  // CARGAR WORKOUT RECORDS
  // ============================================================
  Future<void> loadWorkoutRecords(
    String wokoutExerciseId,
    ExerciseType exerciseType,
  ) async {
    try {
      emit(WorkoutRecordLoading());

      final result = await workoutRecordRepo.getAllWorkoutRecords(
        wokoutExerciseId,
        exerciseType,
      );
      if (isClosed) return;

      emit(WorkoutRecordsLoaded(workoutRecords: result));
    } catch (e) {
      if (isClosed) return;

      emit(
        WorkoutRecordError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> createWorkoutRecord(
    ExerciseType exerciseType,
    Map<String, dynamic> workoutRecordBody,
  ) async {
    try {
      if (isClosed) return;
      final currentState = state;

      if (currentState is! WorkoutRecordsLoaded) return;

      emit(
        currentState.copyWith(
          isSaving: true,
        ),
      );

      final newWorkoutRecord = await workoutRecordRepo.createWorkoutRecord(
        exerciseType,
        workoutRecordBody,
      );

      if (isClosed) return;

      emit(
        currentState.copyWith(
          workoutRecords: [
            ...currentState.workoutRecords,
            newWorkoutRecord,
          ],
          isSaving: false,
        ),
      );
    } on ApiError catch (e) {
      if (isClosed) return;

      emit(
        WorkoutRecordError(
          e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        WorkoutRecordError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> updateWorkoutRecord(
    String workoutRecordId,
    ExerciseType exerciseType,
    Map<String, dynamic> workoutRecordBody,
  ) async {
    try {
      if (isClosed) return;

      final currentState = state;

      if (currentState is! WorkoutRecordsLoaded) return;

      emit(
        currentState.copyWith(
          isSaving: true,
        ),
      );

      final updatedWorkoutRecord = await workoutRecordRepo.updateWorkoutRecord(
        workoutRecordId,
        exerciseType,
        workoutRecordBody,
      );

      if (isClosed) return;

      final updatedRecords = currentState.workoutRecords.map((record) {
        if (record.id == workoutRecordId) {
          return updatedWorkoutRecord;
        }

        return record;
      }).toList();

      emit(
        currentState.copyWith(
          workoutRecords: updatedRecords,
          isSaving: false,
        ),
      );
    } on ApiError catch (e) {
      if (isClosed) return;

      emit(
        WorkoutRecordError(
          e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        WorkoutRecordError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> deleteWorkoutRecord(
    String workoutRecordId,
    ExerciseType exerciseType,
  ) async {
    try {
      if (isClosed) return;

      final currentState = state;
      if (currentState is! WorkoutRecordsLoaded) return;

      emit(
        currentState.copyWith(
          isDeleting: true,
        ),
      );

      await workoutRecordRepo.deleteWorkoutRecord(
        workoutRecordId,
        exerciseType,
      );

      if (isClosed) return;

      emit(
        currentState.copyWith(
          workoutRecords: currentState.workoutRecords
              .where(
                (record) => record.id != workoutRecordId,
              )
              .toList(),
          isDeleting: false,
        ),
      );
    } on ApiError catch (e) {
      if (isClosed) return;

      emit(
        WorkoutRecordError(
          e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        WorkoutRecordError(
          e.toString(),
        ),
      );
    }
  }
}
