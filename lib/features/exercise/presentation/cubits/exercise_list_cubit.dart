import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/exercise/domain/repos/exercise_repo.dart';
import 'exercise_list_state.dart';

class ExerciseListCubit extends Cubit<ExerciseListState> {
  final ExerciseRepo exerciseRepo;

  ExerciseListCubit({
    required this.exerciseRepo,
  }) : super(ExerciseInitial());

  // ============================================================
  // CARGAR EJERCICIOS
  // ============================================================

  Future<void> loadExercises({
    int page = 1,
    String name = "",
    String muscleGroup = "",
  }) async {
    try {
      // ==========================================================
      // PRIMERA PÁGINA
      // ==========================================================
      if (page == 1) {
        emit(ExerciseLoading());
      }

      final result = await exerciseRepo.getAllExercises(
        page: page,
        name: name,
        muscleGroup: muscleGroup,
      );

      // ==========================================================
      // SI ES LA PRIMERA PÁGINA
      // Reemplazamos la lista completa
      // ==========================================================
      if (page == 1) {
        emit(
          ExercisesLoaded(
            exercises: result.exercises,
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            isLoadingMore: false,
            name: name,
            muscleGroup: muscleGroup,
          ),
        );

        return;
      }

      // ==========================================================
      // SI ES UNA PÁGINA SIGUIENTE
      // Agregamos los nuevos ejercicios a los existentes
      // ==========================================================
      if (state is ExercisesLoaded) {
        final currentState = state as ExercisesLoaded;

        emit(
          currentState.copyWith(
            exercises: [
              ...currentState.exercises,
              ...result.exercises,
            ],
            currentPage: result.currentPage,
            totalPages: result.totalPages,
            isLoadingMore: false,
          ),
        );
      }
    } catch (e) {
      if (isClosed) return;

      // Si es una carga inicial, mostramos error normal
      if (page == 1) {
        emit(
          ExerciseError(
            e.toString(),
          ),
        );
        return;
      }

      // Si falla "Cargar más", conservamos la lista actual
      if (state is ExercisesLoaded) {
        final currentState = state as ExercisesLoaded;

        emit(
          currentState.copyWith(
            isLoadingMore: false,
          ),
        );
      }
    }
  }

  // ============================================================
  // CARGAR SIGUIENTE PÁGINA
  // ============================================================

  Future<void> loadMoreExercises() async {
    // ----------------------------------------------------------
    // Comprobamos que tengamos una lista cargada
    // ----------------------------------------------------------

    if (state is! ExercisesLoaded) {
      return;
    }

    final currentState = state as ExercisesLoaded;

    // ----------------------------------------------------------
    // Evitamos hacer varias peticiones al mismo tiempo
    // ----------------------------------------------------------

    if (currentState.isLoadingMore) {
      return;
    }

    // ----------------------------------------------------------
    // Comprobamos si existen más páginas
    // ----------------------------------------------------------

    if (!currentState.hasMore) {
      return;
    }

    // ----------------------------------------------------------
    // Indicamos que estamos cargando otra página
    // ----------------------------------------------------------

    emit(
      currentState.copyWith(
        isLoadingMore: true,
      ),
    );

    try {
      final nextPage = currentState.currentPage + 1;

      final result = await exerciseRepo.getAllExercises(
        page: nextPage,
        name: currentState.name,
        muscleGroup: currentState.muscleGroup,
      );

      // --------------------------------------------------------
      // Agregamos los nuevos ejercicios a los anteriores
      // --------------------------------------------------------

      emit(
        currentState.copyWith(
          exercises: [
            ...currentState.exercises,
            ...result.exercises,
          ],
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      // --------------------------------------------------------
      // Si falla la carga, mantenemos los ejercicios actuales
      // --------------------------------------------------------

      emit(
        currentState.copyWith(
          isLoadingMore: false,
        ),
      );
    }
  }

  // ============================================================
  // BUSCAR
  // ============================================================

  Future<void> searchExercises(String name) async {
    String muscleGroup = "";

    if (state is ExercisesLoaded) {
      final currentState = state as ExercisesLoaded;

      muscleGroup = currentState.muscleGroup;
    }

    await loadExercises(
      page: 1,
      name: name,
      muscleGroup: muscleGroup,
    );
  }

  // ============================================================
  // FILTRAR POR GRUPO MUSCULAR
  // ============================================================

  Future<void> filterByMuscleGroup(
    String muscleGroup,
  ) async {
    String name = "";

    if (state is ExercisesLoaded) {
      final currentState = state as ExercisesLoaded;

      name = currentState.name;
    }

    await loadExercises(
      page: 1,
      name: name,
      muscleGroup: muscleGroup,
    );
  }

  // ============================================================
  // CREAR EJERCICIO
  // ============================================================

  Future<void> createExercise({
    required String name,
    required List<String> muscleGroups,
    String? equipment,
    required String type,
  }) async {
    try {
      emit(ExerciseCreating());

      await exerciseRepo.createExercise(
        name: name,
        muscleGroups: muscleGroups,
        equipment: equipment,
        type: type,
      );

      // Después de crear, recargamos la lista
      await loadExercises();
    } catch (e) {
      emit(
        ExerciseError(
          e.toString(),
        ),
      );
    }
  }
}
