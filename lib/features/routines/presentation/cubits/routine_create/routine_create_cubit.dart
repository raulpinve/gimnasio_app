import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/features/routines/domain/repos/routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_create/routine_create_state.dart';

class RoutineCreateCubit extends Cubit<RoutineCreateState> {
  final RoutineRepo routineRepo;

  RoutineCreateCubit({
    required this.routineRepo,
  }) : super(
         RoutineCreateState(),
       );

  // Agregar workout
  Future<void> createRoutine({
    required String name,
  }) async {
    try {
      if (isClosed) return;

      emit(
        state.copyWith(
          isCreating: true,
          errorMessage: null,
          fieldErrors: null,
        ),
      );

      final routine = await routineRepo.createRoutine(
        name: name,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          isCreating: false,
          isCreated: true,
          routineId: routine.id,
        ),
      );
    } on ApiError catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          isCreating: false,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isCreating: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
