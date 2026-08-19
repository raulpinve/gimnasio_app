import 'package:gym_app/features/routines_exercises/domain/entities/routine_exercise.dart';

abstract class RoutineExercisesState {}

// Estado inicial
class RoutineExercisesInicial extends RoutineExercisesState {}

// Estado para iniciar la eliminación del ejercicio en la rutina
class RoutineExercisesDeleting extends RoutineExercisesState {}

// Estado para indicar que el ejercicio fue eliminada de la rutina
class RoutineExercisesDeleted extends RoutineExercisesState {}

// Estado para cargar el listado inicialmente
class RoutineExercisesLoading extends RoutineExercisesState {}

// Ejercicios de la rutina cargados
class RoutineExercisesLoaded extends RoutineExercisesState {
  final List<RoutineExercise> routineExercises;
  final bool isLoadingMore;

  RoutineExercisesLoaded({
    required this.routineExercises,
    this.isLoadingMore = false,
  });

  RoutineExercisesLoaded copyWith({
    List<RoutineExercise>? routineExercises,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return RoutineExercisesLoaded(
      routineExercises: routineExercises ?? this.routineExercises,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class RoutineExercisesError extends RoutineExercisesState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  RoutineExercisesError(this.message, {this.fieldErrors});
}
