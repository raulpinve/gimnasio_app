import 'package:gym_app/features/workouts/domain/entities/workout.dart';

abstract class WorkoutState {}

// Estado inicial
class WorkoutInitial extends WorkoutState {}

// Estado para cargar la lista inicialmente
class WorkoutLoading extends WorkoutState {}

class WorkoutsLoaded extends WorkoutState {
  final List<Workout> workouts;
  final bool isDeleting;

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
    this.isDeleting = false,
  });

  // Indica si existen más páginas
  bool get hasMore => currentPage < totalPages;

  WorkoutsLoaded copyWith({
    List<Workout>? workouts,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? isDeleting,
  }) {
    return WorkoutsLoaded(
      workouts: workouts ?? this.workouts,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isDeleting: isDeleting ?? this.isDeleting,
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
