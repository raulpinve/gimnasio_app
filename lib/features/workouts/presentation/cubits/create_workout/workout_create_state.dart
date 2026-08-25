class WorkoutCreateState {
  final bool isCreating;
  final bool isCreated;
  final String? workoutId;
  final String? errorMessage;
  final Map<String, dynamic>? fieldErrors;

  final String? creationType;
  final String? routineId;

  const WorkoutCreateState({
    this.isCreating = false,
    this.isCreated = false,
    this.workoutId,
    this.errorMessage,
    this.fieldErrors,
    this.creationType,
    this.routineId,
  });

  WorkoutCreateState copyWith({
    bool? isCreating,
    bool? isCreated,
    String? workoutId,
    String? errorMessage,
    Map<String, dynamic>? fieldErrors,
    String? creationType,
    String? routineId,
  }) {
    return WorkoutCreateState(
      isCreating: isCreating ?? this.isCreating,
      isCreated: isCreated ?? this.isCreated,
      workoutId: workoutId ?? this.workoutId,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      creationType: creationType ?? this.creationType,
      routineId: routineId ?? this.routineId,
    );
  }
}
