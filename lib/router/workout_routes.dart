import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/routines/data/api_routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_cubit.dart';
import 'package:gym_app/features/workouts/data/api_workout_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/active_workout/active_workout_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/create_workout/workout_create_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_list_cubit.dart';
import 'package:gym_app/features/workouts/presentation/pages/workouts_list_page.dart';
import 'package:gym_app/features/workouts/presentation/pages/workouts_page.dart';

final workoutRoutes = <GoRoute>[
  GoRoute(
    path: '/workouts-list',
    builder: (context, state) {
      return BlocProvider(
        create: (_) => WorkoutListCubit(
          workoutRepo: ApiWorkoutRepo(),
        )..loadWorkouts(),
        child: WorkoutsListPage(),
      );
    },
  ),
  /*GoRoute(
    path: '/workouts',
    builder: (context, state) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => RoutineListCubit(
              routineRepo: ApiRoutineRepo(),
            )..loadRoutines(),
          ),
          BlocProvider(
            create: (context) => WorkoutCreateCubit(
              workoutRepo: ApiWorkoutRepo(),
            ),
          ),
          BlocProvider(
            create: (_) => WorkoutListCubit(
              workoutRepo: ApiWorkoutRepo(),
            )..loadWorkouts(),
          ),
          BlocProvider(
            create: (_) => ActiveWorkoutCubit(
              workoutRepo: ApiWorkoutRepo(),
            )..loadActiveWorkout(),
          ),
        ],
        child: const WorkoutsPage(),
      );
    },
  ), */
];
