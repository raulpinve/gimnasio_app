import 'package:gym_app/features/routines/data/api_routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine/routine_detail_cubit.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_create/routine_exercises_create_cubit.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_list/routine_exercises_list_cubit.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_update/routine_exercises_update_cubit.dart';
import 'package:gym_app/features/routines_exercises/presentation/pages/routine_exercises_create_page.dart';
import 'package:gym_app/features/routines_exercises/presentation/pages/routine_exercises_page.dart';
import 'package:gym_app/features/routines_exercises/presentation/pages/routine_exercises_update_page.dart';
import 'package:gym_app/features/routines_exercises/data/api_routine_exercise_repo.dart';
import 'package:gym_app/features/exercise/data/api_exercise_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final routineExercisesRoutes = <GoRoute>[
  GoRoute(
    path: '/routine-exercises/:routineId',
    builder: (context, state) {
      final routineId = state.pathParameters["routineId"] ?? "";

      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                RoutineDetailCubit(routineRepo: ApiRoutineRepo())
                  ..loadRoutineDetail(routineId),
          ),
          BlocProvider(
            create: (_) => RoutineExercisesCubit(
              routineExerciseRepo: ApiRoutineExerciseRepo(),
            )..loadRoutineExercises(routineId: routineId),
          ),
        ],
        child: RoutineExercisesPage(
          routineId: routineId,
        ),
      );
    },
  ),

  // Agregar ejercicio a la rutina
  GoRoute(
    path: '/routine-exercises/:routineId/create',
    builder: (context, state) {
      // Capturamos el ID de los parámetros de la ruta
      final routineId = state.pathParameters["routineId"] ?? "";

      return MultiBlocProvider(
        providers: [
          // ROUTINE EXERCISES
          BlocProvider(
            create: (_) => RoutineExercisesCreateCubit(
              routineExerciseRepo: ApiRoutineExerciseRepo(),
            ),
          ),
        ],
        child: RoutineExercisesCreatePage(routineId: routineId),
      );
    },
  ),

  // Editar ejercicio en la rutina
  GoRoute(
    path: '/routine-exercises/:routineExerciseId/update',
    builder: (context, state) {
      final routineExerciseId = state.pathParameters['routineExerciseId'] ?? '';

      return BlocProvider(
        create: (_) => RoutineExercisesUpdateCubit(
          routineExerciseRepo: ApiRoutineExerciseRepo(),
          exerciseRepo: ApiExerciseRepo(),
          routineExerciseId: routineExerciseId,
        )..getRoutineExerciseById(),
        child: RoutineExercisesUpdatePage(
          routineExerciseId: routineExerciseId,
        ),
      );
    },
  ),
];
