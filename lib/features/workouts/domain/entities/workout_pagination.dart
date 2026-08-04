import 'workout.dart';

class WorkoutPagination {
  final List<Workout> workouts;
  final int currentPage;
  final int totalPages;

  WorkoutPagination({
    required this.workouts,
    required this.currentPage,
    required this.totalPages,
  });

  bool get hasMore => currentPage < totalPages;
}
