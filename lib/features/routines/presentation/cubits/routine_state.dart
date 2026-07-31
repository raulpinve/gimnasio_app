import 'package:gym_app/features/routines/domain/entities/routine.dart';

abstract class RoutineState {}

// Estado inicial
class RoutineInitial extends RoutineState {}

// Estado para crear rutina
class RoutineCreating extends RoutineState {}

// Estado de exito para crear rutina
class RoutineCreated extends RoutineState {}

// Estado para eliminar rutina
class RoutineDeleting extends RoutineState {}

// Estado para indicar que la rutina fue eliminada
class RoutineDeleted extends RoutineState {}

// Estado para cargar la lista inicialmente
class RoutineLoading extends RoutineState {}

// Ejercicios cargados
class RoutinesLoaded extends RoutineState {
  final List<Routine> routines;

  // Paginación
  final int currentPage;
  final int totalPages;

  // Indica si estamos cargando otra página
  final bool isLoadingMore;

  RoutinesLoaded({
    required this.routines,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
  });

  // Indica si existen más páginas
  bool get hasMore => currentPage < totalPages;

  RoutinesLoaded copyWith({
    List<Routine>? routines,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return RoutinesLoaded(
      routines: routines ?? this.routines,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class RoutineError extends RoutineState {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  RoutineError(
    this.message, {
    this.fieldErrors,
  });
}
