import 'package:gym_app/features/routines/domain/entities/routine.dart';

abstract class RoutineListState {}

// Estado inicial
class RoutineListInitial extends RoutineListState {}

// Estado para mostrar el loading inicialmente
class RoutineListLoading extends RoutineListState {}

// Ejercicios cargados
class RoutinesListLoaded extends RoutineListState {
  final List<Routine> routines;
  final bool isDeleting;
  final String? errorMessage;

  // Paginación
  final int currentPage;
  final int totalPages;

  final bool isLoadingMore;

  RoutinesListLoaded({
    required this.routines,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
    this.isDeleting = false,
    this.errorMessage,
  });

  bool get hasMore => currentPage < totalPages;

  RoutinesListLoaded copyWith({
    List<Routine>? routines,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? isDeleting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RoutinesListLoaded(
      routines: routines ?? this.routines,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
