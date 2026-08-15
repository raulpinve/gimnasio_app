import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/workouts/domain/repos/workout_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_state.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  final WorkoutRepo workoutRepo;
  WorkoutCubit({required this.workoutRepo}) : super(WorkoutInitial());

  // ============================================================
  // CARGAR WORKOUTS
  // ============================================================
  Future<void> loadWorkouts({
    int page = 1,
  }) async {
    try {
      // ==========================================================
      // PRIMERA PÁGINA
      // ==========================================================

      if (page == 1) {
        emit(WorkoutLoading());
      }

      final result = await workoutRepo.getAllWorkouts(page: page);

      // SI ES LA PRIMERA PÁGINA
      // Reemplazamos la lista completa
      if (page == 1) {
        emit(
          WorkoutsLoaded(
            workouts: result.workouts,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            isLoadingMore: false,
          ),
        );

        return;
      }

      // SI ES UNA PÁGINA SIGUIENTE
      // Agregamos las nuevas rutinas existentes
      if (state is WorkoutsLoaded) {
        final currentState = state as WorkoutsLoaded;

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

      // Si es una carga inicial, mostramos el error normal
      if (page == 1) {
        emit(
          WorkoutError(
            "Ha ocurrido un error al intentar obtener los entrenamientos",
          ),
        );
      }

      // Si falla "Cargar más", conservamos la lista actual
      if (state is WorkoutsLoaded) {
        final currentState = state as WorkoutsLoaded;

        emit(
          currentState.copyWith(
            isLoadingMore: false,
          ),
        );
      }
    }
  }

  // Cargar siguiente página
  Future<void> loadMoreWorkouts() async {
    if (state is! WorkoutsLoaded) {
      return;
    }
    final currentState = state as WorkoutsLoaded;

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
      );

      if (state is! WorkoutsLoaded) {
        return;
      }

      final updatedState = state as WorkoutsLoaded;

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

      if (state is WorkoutsLoaded) {
        final currentState = state as WorkoutsLoaded;

        emit(
          currentState.copyWith(
            isLoadingMore: false,
          ),
        );
      }
    }
  }

  Future<bool> deleteWorkout(String id) async {
    if (isClosed) return false;

    if (state is! WorkoutsLoaded) {
      return false;
    }

    final currentState = state as WorkoutsLoaded;

    emit(
      currentState.copyWith(
        isDeleting: true,
      ),
    );

    try {
      await workoutRepo.deleteWorkout(id);

      if (isClosed) return false;

      final updatedWorkouts = currentState.workouts
          .where((workout) => workout.id != id)
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
