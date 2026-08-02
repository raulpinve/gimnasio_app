import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/features/routines/domain/repos/routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_state.dart';

class RoutineCubit extends Cubit<RoutineState> {
  final RoutineRepo routineRepo;
  RoutineCubit({required this.routineRepo}) : super(RoutineInitial());

  // Cargar ejercicios
  Future<void> loadRoutines({
    int page = 1,
  }) async {
    try {
      if (page == 1) {
        emit(RoutineLoading());
      }

      final result = await routineRepo.getAllRoutines(page: page);

      // SI ES LA PRIMERA PÁGINA
      // Reemplazamos la lista completa
      if (page == 1) {
        emit(
          RoutinesLoaded(
            routines: result.routines,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
          ),
        );

        return;
      }

      // SI ES UNA PÁGINA SIGUIENTE
      // Agregamos las nuevas rutinas existentes
      if (state is RoutinesLoaded) {
        final currentState = state as RoutinesLoaded;

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
          RoutineError("Ha ocurrido un error al intentar obtener las rutinas"),
        );
      }

      // Si falla "Cargar más", conservamos la lista actual
      if (state is RoutinesLoaded) {
        final currentState = state as RoutinesLoaded;

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
    if (state is! RoutinesLoaded) {
      return;
    }

    final currentState = state as RoutinesLoaded;

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

      if (state is! RoutinesLoaded) {
        return;
      }

      final updatedState = state as RoutinesLoaded;

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

      if (state is RoutinesLoaded) {
        final currentState = state as RoutinesLoaded;

        emit(
          currentState.copyWith(
            isLoadingMore: false,
          ),
        );
      }
    }
  }

  // Create routines
  Future<void> createRoutine({
    required String name,
  }) async {
    try {
      if (isClosed) return;

      emit(RoutineCreating());

      await routineRepo.createRoutine(
        name: name,
      );

      emit(RoutineCreated());
    } on ApiError catch (e) {
      if (isClosed) return;
      emit(
        RoutineError(
          e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        RoutineError(
          "Ocurrió un error inesperado.",
        ),
      );
    }
  }

  // Delete routine
  Future<void> deleteRoutine(String routineId) async {
    try {
      emit(RoutineDeleting());

      await routineRepo.deleteRoutine(routineId);

      emit(RoutineDeleted());
      await loadRoutines();
    } catch (e) {
      emit(RoutineError(e.toString()));
    }
  }

  // Obtener una rutina específica por su ID usando el método exacto del repositorio
  Future<void> loadRoutineById(String routineId) async {
    try {
      if (isClosed) return;
      emit(SingleRoutineLoading());

      // Llama a getRoutine tal como está en tu RoutineRepo
      final routine = await routineRepo.getRoutine(routineId);

      if (isClosed) return;
      emit(SingleRoutineLoaded(routine: routine));
    } catch (e) {
      if (isClosed) return;
      emit(RoutineError("No se pudo cargar la información de la rutina."));
    }
  }
}
