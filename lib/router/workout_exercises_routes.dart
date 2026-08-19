import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/workouts/data/api_workout_repo.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_detail/workout_detail_cubit.dart';
import 'package:gym_app/features/workouts_exercises/data/api_workout_exercise_repo.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercise_detail/workout_exercise_detail_cubit.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercises_list/workout_exercises_list_cubit.dart';
import 'package:gym_app/features/workouts_exercises/presentation/pages/workout_exercise_list_page.dart';

final workoutExercisesRoutes = <GoRoute>[
  // Abrir página de workout
  GoRoute(
    path: '/workouts-exercises/:workoutId',
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
            create: (_) => WorkoutExercisesListCubit(
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
];
