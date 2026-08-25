import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/routines/data/api_routine_repo.dart';
import 'package:gym_app/features/routines/domain/repos/routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_cubit.dart';
import 'package:gym_app/features/workouts/data/api_workout_repo.dart';
import 'package:gym_app/features/workouts/domain/repos/workout_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/create_workout/workout_create_cubit.dart';
import 'package:gym_app/features/workouts/presentation/pages/workouts_create_page.dart';
import 'package:gym_app/features/workouts/presentation/pages/workouts_page.dart';

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
            create: (_) => RoutineListCubit(
              routineRepo: ApiRoutineRepo(),
            )..loadRoutines(),
          ),
        ],
        child: WorkoutsCreatePage(),
      );
    },
  ),

  // GoRoute(
  //   path: '/workouts',
  //   builder: (context, state) {
  //     return BlocProvider(
  //       create: (_) => WorkoutListCubit(
  //         workoutRepo: ApiWorkoutRepo(),
  //       )..loadWorkouts(),
  //       child: WorkoutsListPage(),
  //     );
  //   },
  // ),
  GoRoute(
    path: '/workouts',
    builder: (context, state) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => RoutineListCubit(
              routineRepo: ApiRoutineRepo(),
            ),
          ),
          BlocProvider(
            create: (context) => WorkoutCreateCubit(
              workoutRepo: ApiWorkoutRepo(),
            ),
          ),
        ],
        child: const WorkoutsPage(),
      );
    },
  ),
];
