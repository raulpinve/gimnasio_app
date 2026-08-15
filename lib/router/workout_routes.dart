import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/routines/data/api_routine_repo.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_cubit.dart';
import 'package:gym_app/features/workouts_exercises/data/api_workout_exercise_repo.dart';
import 'package:gym_app/features/workouts/data/api_workout_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/create_workout/workout_create_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_detail/workout_detail_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_exercise/workout_exercise_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_cubit.dart';
import 'package:gym_app/features/workouts_record/presentation/cubits/workout_record_cubit.dart';
import 'package:gym_app/features/workouts_exercises/presentation/pages/workout_exercise_page.dart';
import 'package:gym_app/features/workouts/presentation/pages/workouts_create_page.dart';
import 'package:gym_app/features/workouts/presentation/pages/workouts_page.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercise_detail_cubit.dart';
import 'package:gym_app/features/workouts_record/data/api_workout_record.dart';
import 'package:gym_app/features/workouts_record/presentation/pages/workout_record_page.dart';

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

  // Abrir página de workout
  GoRoute(
    path: '/workouts/:workoutId',
    builder: (context, state) {
      final workoutId = state.pathParameters['workoutId'] ?? '';

      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => WorkoutDetailCubit(
              workoutRepo: ApiWorkoutRepo(),
            )..loadWorkoutById(workoutId),
          ),

          BlocProvider(
            create: (_) => WorkoutExerciseCubit(
              workoutExerciseRepo: ApiWorkoutExerciseRepo(),
            )..loadWorkoutExercises(workoutId),
          ),

          BlocProvider(
            create: (_) => WorkoutExerciseDetailCubit(
              workoutExerciseRepo: ApiWorkoutExerciseRepo(),
            ),
          ),
        ],
        child: WorkoutExercisePage(
          workoutId: workoutId,
        ),
      );
    },
  ),

  GoRoute(
    path: '/workouts',
    builder: (context, state) {
      return BlocProvider(
        create: (_) => WorkoutCubit(
          workoutRepo: ApiWorkoutRepo(),
        )..loadWorkouts(),
        child: WorkoutsPage(),
      );
    },
  ),

  // Administradar workout-exercises
  GoRoute(
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
  ),
];
