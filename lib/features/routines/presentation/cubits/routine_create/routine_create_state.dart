class RoutineCreateState {
  final bool isCreating;
  final bool isCreated;
  final String? routineId;
  final String? errorMessage;
  final Map<String, dynamic>? fieldErrors;

  RoutineCreateState({
    this.isCreating = false,
    this.isCreated = false,
    this.routineId,
    this.errorMessage,
    this.fieldErrors,
  });

  RoutineCreateState copyWith({
    bool? isCreating,
    bool? isCreated,
    String? routineId,
    String? errorMessage,
    Map<String, dynamic>? fieldErrors,
  }) {
    return RoutineCreateState(
      isCreating: isCreating ?? this.isCreating,
      isCreated: isCreated ?? this.isCreated,
      routineId: routineId ?? this.routineId,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}
