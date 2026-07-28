import 'routine.dart';

class RoutinePagination {
  final List<Routine> routines;
  final int currentPage;
  final int totalPages;

  const RoutinePagination({
    required this.routines,
    required this.currentPage,
    required this.totalPages,
  });

  bool get hasMore => currentPage < totalPages;
}
