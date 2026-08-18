import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/routines/domain/repos/routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_state.dart';

class RoutineListCubit extends Cubit<RoutineListState> {
  final RoutineRepo routineRepo;
  RoutineListCubit({required this.routineRepo}) : super(RoutineListInitial());

  // ============================================================
  // CARGAR RUTINAS
  // ============================================================
  Future<void> loadRoutines({
    int page = 1,
  }) async {
    try {
      // PRIMERA PÁGINA
      if (page == 1) {
        emit(RoutineListLoading());
      }

      final result = await routineRepo.getAllRoutines(page: page);

      // SI ES LA PRIMERA PÁGINA
      // Reemplazamos la lista completa
      if (page == 1) {
        emit(
          RoutinesListLoaded(
            routines: result.routines,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            isLoadingMore: false,
          ),
        );

        return;
      }

      // SI ES UNA PÁGINA SIGUIENTE
      // Agregamos las nuevas rutinas existentes
      if (state is RoutinesListLoaded) {
        final currentState = state as RoutinesListLoaded;

        emit(
          currentState.copyWith(
            routines: [
              ...currentState.routines,
              ...result.routines,
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
          RoutineListError(
            e.toString(),
          ),
        );
      }

      // Si falla "Cargar más", conservamos la lista actual
      if (state is RoutinesListLoaded) {
        final currentState = state as RoutinesListLoaded;

        emit(
          currentState.copyWith(
            isLoadingMore: false,
          ),
        );
      }
    }
  }

  // Cargar siguiente página
  Future<void> loadMoreRoutines() async {
    if (state is! RoutinesListLoaded) {
      return;
    }

    final currentState = state as RoutinesListLoaded;

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

      final result = await routineRepo.getAllRoutines(
        page: nextPage,
      );

      if (state is! RoutinesListLoaded) {
        return;
      }

      final updatedState = state as RoutinesListLoaded;

      emit(
        updatedState.copyWith(
          routines: [
            ...updatedState.routines,
            ...result.routines,
          ],
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      if (state is RoutinesListLoaded) {
        final currentState = state as RoutinesListLoaded;

        emit(
          currentState.copyWith(
            isLoadingMore: false,
          ),
        );
      }
    }
  }

  Future<bool> deleteRoutine(String routineId) async {
    if (isClosed) return false;

    if (state is! RoutinesListLoaded) {
      return false;
    }
    final currentState = state as RoutinesListLoaded;

    emit(
      currentState.copyWith(
        isDeleting: true,
        clearError: true,
      ),
    );

    try {
      await routineRepo.deleteRoutine(routineId);

      if (isClosed) return false;

      final updatedRoutines = currentState.routines
          .where((routine) => routine.id != routineId)
          .toList();

      emit(
        currentState.copyWith(
          routines: updatedRoutines,
          isDeleting: false,
        ),
      );
      return true;
    } catch (e) {
      if (isClosed) return false;

      emit(
        currentState.copyWith(
          isDeleting: false,
          errorMessage: 'No se pudo eliminar la rutina: ${e.toString()}',
        ),
      );
      return false;
    }
  }
}
