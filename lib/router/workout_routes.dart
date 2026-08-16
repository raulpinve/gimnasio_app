import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/routines/data/api_routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_cubit.dart';
import 'package:gym_app/features/workouts/data/api_workout_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/create_workout/workout_create_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_list_cubit.dart';
import 'package:gym_app/features/workouts/presentation/pages/workouts_create_page.dart';
import 'package:gym_app/features/workouts/presentation/pages/workouts_list_page.dart';

final workoutRoutes = <GoRoute>[
  GoRoute(
    path: '/workouts/create',
    builder: (context, state) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => WorkoutCreateCubit(
              workoutRepo: ApiWorkoutRepo(),
            ),
          ),
          BlocProvider(
            create: (_) => RoutineCubit(
              routineRepo: ApiRoutineRepo(),
            )..loadRoutines(),
          ),
        ],
        child: WorkoutsCreatePage(),
      );
    },
  ),

  GoRoute(
    path: '/workouts',
    builder: (context, state) {
      return BlocProvider(
        create: (_) => WorkoutListCubit(
          workoutRepo: ApiWorkoutRepo(),
        )..loadWorkouts(),
        child: WorkoutsListPage(),
      );
    },
  ),

  // Administradar workout-exercises
  /* GoRoute(
    path: '/workout-records/:workoutExerciseId',
    builder: (context, state) {
      final workoutExerciseId = state.pathParameters['workoutExerciseId'] ?? '';

      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => WorkoutExerciseCubit(
              workoutExerciseRepo: ApiWorkoutExerciseRepo(),
            ),
          ),
          BlocProvider(
            create: (_) => WorkoutExerciseDetailCubit(
              workoutExerciseRepo: ApiWorkoutExerciseRepo(),
            )..loadWorkoutExerciseById(workoutExerciseId),
          ),
          BlocProvider(
            create: (_) =>
                WorkoutRecordCubit(workoutRecordRepo: ApiWorkoutRecord()),
          ),
        ],
        child: WorkoutRecordPage(workoutExerciseId: workoutExerciseId),
      );
    },
  ), */
];
