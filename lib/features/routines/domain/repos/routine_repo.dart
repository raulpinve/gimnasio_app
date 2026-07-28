import 'package:gym_app/features/routines/domain/entities/routine.dart';
import 'package:gym_app/features/routines/domain/entities/routine_pagination.dart';

abstract class RoutineRepo {
  Future<RoutinePagination> getAllRoutines({
    int page = 1,
  });

  Future<Routine> getRoutine(String id);

  Future<Routine> createRoutine({
    required String name,
  });

  Future<void> deleteRoutine(String routineId);
}
