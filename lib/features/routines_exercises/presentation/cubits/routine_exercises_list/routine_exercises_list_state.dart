import 'package:gym_app/features/routines_exercises/domain/entities/routine_exercise.dart';

abstract class RoutineExercisesListState {}

// Estado inicial
class RoutineExercisesListInicial extends RoutineExercisesListState {}

// Estado para mostrar el loading inicialmente
class RoutineExercisesListLoading extends RoutineExercisesListState {}

// Ejercicios de la rutina cargados
class RoutineExercisesListLoaded extends RoutineExercisesListState {
  final List<RoutineExercise> routineExercises;
  final bool isLoadingMore;
  final bool isDeleting;

  RoutineExercisesListLoaded({
    required this.routineExercises,
    this.isLoadingMore = false,
    this.isDeleting = false,
  });

  RoutineExercisesListLoaded copyWith({
    List<RoutineExercise>? routineExercises,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? isDeleting,
  }) {
    return RoutineExercisesListLoaded(
      routineExercises: routineExercises ?? this.routineExercises,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

class RoutineExercisesListError extends RoutineExercisesListState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  RoutineExercisesListError(this.message, {this.fieldErrors});
}
