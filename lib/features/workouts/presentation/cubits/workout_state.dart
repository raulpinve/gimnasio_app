import 'package:gym_app/features/workouts/domain/entities/workout.dart';

abstract class WorkoutState {}

// Estado inicial
class WorkoutInitial extends WorkoutState {}

// Estado para cargar la lista inicialmente
class WorkoutLoading extends WorkoutState {}

// Estado para crear rutina
class WorkoutCreating extends WorkoutState {}

// Estado de exito para crear rutina
class WorkoutCreated extends WorkoutState {}

// Estado para indicar que se elimina un workout
class WorkoutDeleting extends WorkoutState {}

// Estado para indicar que el workout fue eliminado
class WorkoutDeleted extends WorkoutState {}

// Workouts cargados
class WorkoutsLoaded extends WorkoutState {
  final List<Workout> workouts;

  // Paginación
  final int currentPage;
  final int totalPages;

  // Indica si estamos cargando otra página
  final bool isLoadingMore;

  WorkoutsLoaded({
    required this.workouts,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
  });

  // Indica si existen más páginas
  bool get hasMore => currentPage < totalPages;

  WorkoutsLoaded copyWith({
    List<Workout>? workouts,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return WorkoutsLoaded(
      workouts: workouts ?? this.workouts,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class WorkoutError extends WorkoutState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  WorkoutError(
    this.message, {
    this.fieldErrors,
  });
}
