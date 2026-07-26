import 'exercise.dart';

class ExercisePagination {
  final List<Exercise> exercises;
  final int currentPage;
  final int totalPages;

  const ExercisePagination({
    required this.exercises,
    required this.currentPage,
    required this.totalPages,
  });

  bool get hasMore => currentPage < totalPages;
}
