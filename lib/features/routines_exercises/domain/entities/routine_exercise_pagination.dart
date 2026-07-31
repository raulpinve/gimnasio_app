import 'package:gym_app/features/routines_exercises/domain/entities/routine_exercise.dart';

class RoutineExercisePagination {
  final List<RoutineExercise> routineExercises;
  final int currentPage;
  final int totalPages;

  RoutineExercisePagination({
    required this.routineExercises,
    required this.currentPage,
    required this.totalPages,
  });

  bool get hasMore => currentPage < totalPages;
}
