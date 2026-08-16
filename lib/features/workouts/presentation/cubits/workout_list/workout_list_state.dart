import 'package:gym_app/features/workouts/domain/entities/workout.dart';

abstract class WorkoutListState {}

// Estado inicial
class WorkoutListInitial extends WorkoutListState {}

// Estado para cargar la lista inicialmente
class WorkoutListLoading extends WorkoutListState {}

class WorkoutsListLoaded extends WorkoutListState {
  final List<Workout> workouts;
  final bool isDeleting;

  // Paginación
  final int currentPage;
  final int totalPages;

  // Indica si estamos cargando otra página
  final bool isLoadingMore;

  WorkoutsListLoaded({
    required this.workouts,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
    this.isDeleting = false,
  });

  // Indica si existen más páginas
  bool get hasMore => currentPage < totalPages;

  WorkoutsListLoaded copyWith({
    List<Workout>? workouts,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? isDeleting,
  }) {
    return WorkoutsListLoaded(
      workouts: workouts ?? this.workouts,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

class WorkoutListError extends WorkoutListState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  WorkoutListError(
    this.message, {
    this.fieldErrors,
  });
}
