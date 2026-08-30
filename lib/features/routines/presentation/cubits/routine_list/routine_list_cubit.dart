import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';

import 'package:gym_app/features/routines/domain/repos/routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_state.dart';

class RoutineListCubit extends Cubit<RoutineListState> {
  final RoutineRepo routineRepo;

  RoutineListCubit({
    required this.routineRepo,
  }) : super(RoutineListInitial());

  // ============================================================
  // CARGAR RUTINAS
  // ============================================================

  Future<void> loadRoutines() async {
    if (isClosed) return;

    emit(RoutineListLoading());

    try {
      final result = await routineRepo.getAllRoutines();

      if (isClosed) return;

      emit(
        RoutinesListLoaded(
          routines: result.routines,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        RoutineListError(
          e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // ELIMINAR RUTINA
  // ============================================================

  Future<bool> deleteRoutine(String routineId) async {
    if (isClosed) return false;

    if (state is! RoutinesListLoaded) {
      return false;
    }

    final currentState = state as RoutinesListLoaded;

    emit(
      currentState.copyWith(
        isDeleting: true,
        errorMessage: null,
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
          errorMessage: 'No se pudo eliminar la rutina',
        ),
      );

      return false;
    }
  }

  // ============================================================
  // CREAR RUTINA
  // ============================================================

  Future<void> createRoutine({
    required String name,
  }) async {
    if (isClosed) return;

    if (state is! RoutinesListLoaded) {
      return;
    }

    emit(
      (state as RoutinesListLoaded).copyWith(
        isCreating: true,
        clearError: true,
      ),
    );

    try {
      final routine = await routineRepo.createRoutine(
        name: name,
      );

      if (isClosed) return;

      if (state is! RoutinesListLoaded) {
        return;
      }

      final currentState = state as RoutinesListLoaded;

      emit(
        currentState.copyWith(
          routines: [
            routine,
            ...currentState.routines,
          ],
          isCreating: false,
          newlyCreatedRoutineId: routine.id,
        ),
      );
    } on ApiError catch (e) {
      if (isClosed) return;

      if (state is RoutinesListLoaded) {
        emit(
          (state as RoutinesListLoaded).copyWith(
            isCreating: false,
            errorMessage: e.message,
            fieldErrors: e.fieldErrors,
          ),
        );
      }
    } catch (e) {
      if (isClosed) return;

      if (state is RoutinesListLoaded) {
        emit(
          (state as RoutinesListLoaded).copyWith(
            isCreating: false,
            errorMessage: 'Ocurrió un error inesperado',
          ),
        );
      }
    }
  }
}
