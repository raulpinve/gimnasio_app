class WorkoutCreateState {
  final bool isCreating;
  final bool isCreated;
  final String? workoutId;
  final String? errorMessage;
  final Map<String, dynamic>? fieldErrors;

  const WorkoutCreateState({
    this.isCreating = false,
    this.isCreated = false,
    this.workoutId,
    this.errorMessage,
    this.fieldErrors,
  });

  WorkoutCreateState copyWith({
    bool? isCreating,
    bool? isCreated,
    String? workoutId,
    String? errorMessage,
    Map<String, dynamic>? fieldErrors,
  }) {
    return WorkoutCreateState(
      isCreating: isCreating ?? this.isCreating,
      isCreated: isCreated ?? this.isCreated,
      workoutId: workoutId ?? this.workoutId,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}
