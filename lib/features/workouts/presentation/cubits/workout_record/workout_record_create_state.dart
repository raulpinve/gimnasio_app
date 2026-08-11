class WorkoutRecordCreateState {
  final bool isCreating;
  final bool isCreated;
  final String? workoutExerciseId;
  final String? errorMessage;
  final Map<String, dynamic>? fieldErrors;

  WorkoutRecordCreateState({
    this.isCreating = false,
    this.isCreated = false,
    this.workoutExerciseId,
    this.errorMessage,
    this.fieldErrors,
  });

  WorkoutRecordCreateState copyWith({
    bool? isCreating,
    bool? isCreated,
    String? workoutExerciseId,
    String? errorMessage,
    Map<String, dynamic>? fieldErrors,
  }) {
    return WorkoutRecordCreateState(
      isCreating: isCreating ?? this.isCreating,
      isCreated: isCreated ?? this.isCreated,
      workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}
