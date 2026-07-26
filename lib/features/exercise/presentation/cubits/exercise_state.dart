import 'package:gym_app/features/exercise/domain/entities/exercise.dart';

abstract class ExerciseState {}

// Estado inicial
class ExerciseInitial extends ExerciseState {}

// Estado para crear ejercicio
class ExerciseCreating extends ExerciseState {}

// Estado para cargar la lista inicialmente
class ExerciseLoading extends ExerciseState {}

// Ejercicios cargados
class ExercisesLoaded extends ExerciseState {
  final List<Exercise> exercises;

  // Paginación
  final int currentPage;
  final int totalPages;

  // Indica si estamos cargando otra página
  final bool isLoadingMore;

  // Filtros actuales
  final String name;
  final String muscleGroup;

  ExercisesLoaded({
    required this.exercises,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
    this.name = "",
    this.muscleGroup = "",
  });

  // Indica si existen más páginas
  bool get hasMore => currentPage < totalPages;

  ExercisesLoaded copyWith({
    List<Exercise>? exercises,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    String? name,
    String? muscleGroup,
  }) {
    return ExercisesLoaded(
      exercises: exercises ?? this.exercises,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
    );
  }
}

// Error
class ExerciseError extends ExerciseState {
  final String message;
  ExerciseError(this.message);
}
