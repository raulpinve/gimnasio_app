import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/exercise/data/api_exercise_repo.dart';
import 'package:gym_app/features/routines/data/api_routine_repo.dart';
import 'package:gym_app/features/routines/domain/entities/routine.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_cubit.dart';
import 'package:gym_app/features/routines/presentation/pages/routine_create_page.dart';
import 'package:gym_app/features/routines/presentation/pages/routines_page.dart';
import 'package:gym_app/features/routines_exercises/data/api_routine_exercise_repo.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_create_cubit.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_cubit.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_update_cubit.dart';
import 'package:gym_app/features/routines_exercises/presentation/pages/routine_exercises_create_page.dart';
import 'package:gym_app/features/routines_exercises/presentation/pages/routine_exercises_page.dart';
import 'package:gym_app/features/routines_exercises/presentation/pages/routine_exercises_update_page.dart';

final routineRoutes = <GoRoute>[
  // Abrir la rutina
  GoRoute(
    path: '/routines',
    builder: (context, state) {
      return RoutinesPage();
    },
  ),

  // Abrir información de rutina
  GoRoute(
    path: '/routine-exercises',
    builder: (context, state) {
      final routine = state.extra as Routine;
      return BlocProvider(
        create: (_) =>
            RoutineExercisesCubit(
              routineExerciseRepo: ApiRoutineExerciseRepo(),
            )..loadRoutineExercises(
              routineId: routine.id,
            ),
        child: RoutineExercisesPage(
          routine: routine,
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
          BlocProvider(
            create: (_) => RoutineExercisesCreateCubit(
              routineExerciseRepo: ApiRoutineExerciseRepo(),
            ),
          ),
          BlocProvider(
            create: (_) =>
                RoutineCubit(routineRepo: ApiRoutineRepo())
                  ..loadRoutineById(routineId),
          ),
        ],
        child: RoutineExercisesCreatePage(
          routineId: routineId,
        ),
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

  // Crear una nueva rutina
  GoRoute(
    path: '/routines/create',
    builder: (_, _) => const RoutineCreatePage(),
  ),
];
