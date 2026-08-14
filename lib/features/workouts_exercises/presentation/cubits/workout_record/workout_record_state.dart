import 'package:gym_app/features/workouts/domain/entities/workout_record.dart';

abstract class WorkoutRecordState {}

// Estado inicial
class WorkoutRecordInitial extends WorkoutRecordState {}

// Estado para cargar la lista inicialmente
class WorkoutRecordLoading extends WorkoutRecordState {}

// Estado para guardar los workoutRecords cargados
class WorkoutRecordsLoaded extends WorkoutRecordState {
  final List<WorkoutRecord> workoutRecords;
  final bool isSaving;
  final bool isDeleting;

  WorkoutRecordsLoaded({
    required this.workoutRecords,
    this.isSaving = false,
    this.isDeleting = false,
  });

  WorkoutRecordsLoaded copyWith({
    List<WorkoutRecord>? workoutRecords,
    bool? isSaving,
    bool? isDeleting,
  }) {
    return WorkoutRecordsLoaded(
      workoutRecords: workoutRecords ?? this.workoutRecords,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

// Estado para indicar el estado de error
class WorkoutRecordError extends WorkoutRecordState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  WorkoutRecordError(
    this.message, {
    this.fieldErrors,
  });
}
