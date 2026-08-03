import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:gym_app/features/routines_exercises/domain/entities/routine_exercise.dart';

class RoutineExercisesUpdateState {
  final RoutineExercise? routineExercise;
  final Exercise? selectedExercise;
  final bool isLoading;
  final bool isUpdating;
  final bool isUpdated;
  final String? errorMessage;
  final Map<String, dynamic>? fieldErrors;

  const RoutineExercisesUpdateState({
    this.routineExercise,
    this.selectedExercise,
    this.isLoading = false,
    this.isUpdating = false,
    this.isUpdated = false,
    this.errorMessage,
    this.fieldErrors,
  });

  RoutineExercisesUpdateState copyWith({
    RoutineExercise? routineExercise,
    Exercise? selectedExercise,
    bool? isLoading,
    bool? isUpdating,
    bool? isUpdated,
    String? errorMessage,
    Map<String, dynamic>? fieldErrors,
  }) {
    return RoutineExercisesUpdateState(
      routineExercise: routineExercise ?? this.routineExercise,
      selectedExercise: selectedExercise ?? this.selectedExercise,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      isUpdated: isUpdated ?? this.isUpdated,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}
