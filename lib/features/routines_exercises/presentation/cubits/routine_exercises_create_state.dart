import 'package:gym_app/features/exercise/domain/entities/exercise.dart';

class RoutineExercisesCreateState {
  final Exercise? selectedExercise;
  final bool isCreating;
  final bool isCreated;
  final String? errorMessage;
  final Map<String, dynamic>? fieldErrors;

  const RoutineExercisesCreateState({
    this.selectedExercise,
    this.isCreating = false,
    this.isCreated = false,
    this.errorMessage,
    this.fieldErrors,
  });

  RoutineExercisesCreateState copyWith({
    Exercise? selectedExercise,
    bool? isCreating,
    bool? isCreated,
    String? errorMessage,
    Map<String, dynamic>? fieldErrors,
  }) {
    return RoutineExercisesCreateState(
      selectedExercise: selectedExercise ?? this.selectedExercise,
      isCreating: isCreating ?? this.isCreating,
      isCreated: isCreated ?? this.isCreated,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}
