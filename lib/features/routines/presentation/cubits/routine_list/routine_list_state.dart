import 'package:gym_app/features/routines/domain/entities/routine.dart';

abstract class RoutineListState {}

// Estado inicial
class RoutineListInitial extends RoutineListState {}

// Estado para cargar la lista inicialmente
class RoutineListLoading extends RoutineListState {}

class RoutinesListLoaded extends RoutineListState {
  final List<Routine> routines;
  final bool isCreating;
  final bool isDeleting;
  final String? errorMessage;
  final Map<String, dynamic>? fieldErrors;
  final String? newlyCreatedRoutineId;

  RoutinesListLoaded({
    required this.routines,
    this.isCreating = false,
    this.isDeleting = false,
    this.errorMessage,
    this.fieldErrors,
    this.newlyCreatedRoutineId,
  });

  RoutinesListLoaded copyWith({
    List<Routine>? routines,
    bool? isCreating,
    bool? isDeleting,
    String? errorMessage,
    Map<String, dynamic>? fieldErrors,
    String? newlyCreatedRoutineId,
    bool clearError = false,
  }) {
    return RoutinesListLoaded(
      routines: routines ?? this.routines,
      isCreating: isCreating ?? this.isCreating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      fieldErrors: clearError ? null : fieldErrors ?? this.fieldErrors,
      newlyCreatedRoutineId:
          newlyCreatedRoutineId ?? this.newlyCreatedRoutineId,
    );
  }
}

class RoutineListError extends RoutineListState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  RoutineListError(
    this.message, {
    this.fieldErrors,
  });
}
