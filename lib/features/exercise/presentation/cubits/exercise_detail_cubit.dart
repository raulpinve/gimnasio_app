import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise_progress.dart';
import 'package:gym_app/features/exercise/domain/repos/exercise_repo.dart';
import 'package:gym_app/features/exercise/presentation/cubits/exercise_detail_state.dart';

class ExerciseDetailCubit extends Cubit<ExerciseDetailState> {
  final ExerciseRepo exerciseRepo;

  ExerciseDetailCubit({
    required this.exerciseRepo,
  }) : super(ExerciseDetailInitial());

  Future<void> loadExerciseDetail(String exerciseId) async {
    try {
      if (isClosed) return;
      emit(ExerciseDetailLoading());

      final results = await Future.wait([
        exerciseRepo.getExercise(exerciseId),
        exerciseRepo.getExerciseProgress(exerciseId),
      ]);

      final exercise = results[0] as Exercise;
      final progressRecord =
          results[1] as (List<ExerciseProgress> progressList, String unit);

      if (isClosed) return;

      emit(
        ExerciseDetailLoaded(
          exercise: exercise,
          progress: progressRecord.$1,
          unit: progressRecord.$2,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        ExerciseDetailError(
          "Ha ocurrido un error al momento de obtener el ejercicio. "
          "Por favor, intenta nuevamente.",
        ),
      );
    }
  }
}
