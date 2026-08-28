import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/workouts/domain/repos/workout_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_list_state.dart';

class WorkoutListCubit extends Cubit<WorkoutListState> {
  final WorkoutRepo workoutRepo;

  // Rutina actualmente seleccionada para filtrar.
  // null = todas las rutinas.
  String? _routineId;

  WorkoutListCubit({
    required this.workoutRepo,
  }) : super(WorkoutListInitial());

  // ============================================================
  // CARGAR WORKOUTS
  // ============================================================
  Future<void> loadWorkouts({
    int page = 1,
    bool showLoading = true,
    String? routineId,
  }) async {
    if (isClosed) return;

    // Solo cambiamos el filtro cuando empezamos desde la primera página.
    if (page == 1) {
      _routineId = routineId;
    }

    try {
      // PRIMERA PÁGINA
      if (page == 1 && showLoading) {
        emit(WorkoutListLoading());
      }

      final result = await workoutRepo.getAllWorkouts(
        page: page,
        routineId: _routineId,
      );

      if (isClosed) return;

      // SI ES LA PRIMERA PÁGINA
      // Reemplazamos la lista completa.
      if (page == 1) {
        emit(
          WorkoutsListLoaded(
            workouts: result.workouts,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            isLoadingMore: false,
          ),
        );
        return;
      }

      // SI ES UNA PÁGINA SIGUIENTE
      // Agregamos los nuevos workouts.
      if (state is WorkoutsListLoaded) {
        final currentState = state as WorkoutsListLoaded;

        emit(
          currentState.copyWith(
            workouts: [
              ...currentState.workouts,
              ...result.workouts,
            ],
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            isLoadingMore: false,
          ),
        );
      }
    } catch (e) {
      if (isClosed) return;

      // Error durante carga inicial.
      if (page == 1 && showLoading) {
        emit(
          WorkoutListError(
            e.toString(),
          ),
        );
      }

      // Error cargando una página adicional.
      if (state is WorkoutsListLoaded) {
        final currentState = state as WorkoutsListLoaded;

        emit(
          currentState.copyWith(
            isLoadingMore: false,
          ),
        );
      }
    }
  }

  // ============================================================
  // FILTRAR POR RUTINA
  // ============================================================
  Future<void> filterByRoutine(String? routineId) async {
    await loadWorkouts(
      page: 1,
      routineId: routineId,
    );
  }

  // ============================================================
  // CARGAR SIGUIENTE PÁGINA
  // ============================================================
  Future<void> loadMoreWorkouts() async {
    if (state is! WorkoutsListLoaded) {
      return;
    }

    final currentState = state as WorkoutsListLoaded;

    if (currentState.isLoadingMore) {
      return;
    }

    if (!currentState.hasMore) {
      return;
    }

    emit(
      currentState.copyWith(
        isLoadingMore: true,
      ),
    );

    try {
      final nextPage = currentState.currentPage + 1;

      await Future.delayed(
        const Duration(seconds: 3),
      );

      final result = await workoutRepo.getAllWorkouts(
        page: nextPage,
        routineId: _routineId,
      );

      if (state is! WorkoutsListLoaded) {
        return;
      }

      final updatedState = state as WorkoutsListLoaded;

      emit(
        updatedState.copyWith(
          workouts: [
            ...updatedState.workouts,
            ...result.workouts,
          ],
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      if (state is WorkoutsListLoaded) {
        final currentState = state as WorkoutsListLoaded;

        emit(
          currentState.copyWith(
            isLoadingMore: false,
          ),
        );
      }
    }
  }

  // ============================================================
  // ELIMINAR WORKOUT
  // ============================================================
  Future<bool> deleteWorkout(String workoutId) async {
    if (isClosed) return false;

    if (state is! WorkoutsListLoaded) {
      return false;
    }

    final currentState = state as WorkoutsListLoaded;

    emit(
      currentState.copyWith(
        isDeleting: true,
      ),
    );

    try {
      await workoutRepo.deleteWorkout(workoutId);

      if (isClosed) return false;

      final updatedWorkouts = currentState.workouts
          .where((workout) => workout.id != workoutId)
          .toList();

      emit(
        currentState.copyWith(
          workouts: updatedWorkouts,
          isDeleting: false,
        ),
      );

      return true;
    } catch (e) {
      if (isClosed) return false;

      emit(
        currentState.copyWith(
          isDeleting: false,
        ),
      );

      return false;
    }
  }
}
