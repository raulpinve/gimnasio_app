import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/routines_exercises/domain/repos/routine_exercise_repo.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_state.dart';

class RoutineExercisesCubit extends Cubit<RoutineExercisesState> {
  final RoutineExerciseRepo routineExerciseRepo;

  // Guardamos el ID de la rutina actual
  String? _routineId;

  RoutineExercisesCubit({required this.routineExerciseRepo})
    : super(RoutineExercisesInicial());

  // Cargar ejercicios
  Future<void> loadRoutineExercises({
    int page = 1,
    required String routineId,
  }) async {
    // Guardamos la rutina actual
    _routineId = routineId;

    try {
      if (page == 1) {
        emit(RoutineExercisesLoading());
      }
      final result = await routineExerciseRepo.getAllRoutinesExercises(
        routineId: routineId,
      );

      // SI ES LA PRIMERA PÁGINA
      // Reemplazamos la lista completa
      if (page == 1) {
        emit(
          RoutineExercisesLoaded(
            routineExercises: result,
          ),
        );

        return;
      }

      // SI ES UNA PÁGINA SIGUIENTE
      // Agregamos las nuevas rutinas existentes
      if (state is RoutineExercisesLoaded) {
        final currentState = state as RoutineExercisesLoaded;

        emit(
          currentState.copyWith(
            routineExercises: [
              ...currentState.routineExercises,
            ],
            isLoadingMore: false,
          ),
        );
      }
    } catch (e) {
      if (isClosed) return;

      // Si es una carga inicial, mostramos el error normal
      if (page == 1) {
        emit(
          RoutineExercisesError(
            "Ha ocurrido un error al intentar obtener las rutinas",
          ),
        );
      }

      // Si falla "Cargar más", conservamos la lista actual
      if (state is RoutineExercisesLoaded) {
        final currentState = state as RoutineExercisesLoaded;

        emit(
          currentState.copyWith(
            isLoadingMore: false,
          ),
        );
      }
    }
  }

  // Delete routine
  Future<void> deleteRoutineExercise(String routineExerciseId) async {
    try {
      emit(RoutineExercisesDeleting());

      await routineExerciseRepo.deleteRoutineExercise(routineExerciseId);

      emit(RoutineExercisesDeleted());

      if (_routineId != null) {
        await loadRoutineExercises(
          routineId: _routineId!,
        );
      }
    } catch (e) {
      emit(RoutineExercisesError("Ocurrió un error inesperado"));
    }
  }
}
