import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/workouts_exercises/data/api_workout_exercise_repo.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercise_detail/workout_exercise_detail_cubit.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercises_list/workout_exercises_list_cubit.dart';
import 'package:gym_app/features/workouts_record/data/api_workout_record.dart';
import 'package:gym_app/features/workouts_record/presentation/cubits/workout_record/workout_record_cubit.dart';
import 'package:gym_app/features/workouts_record/presentation/pages/workout_record_list_page.dart';

final workoutRecordRoutes = <GoRoute>[
  GoRoute(
    path: '/workout-records/:workoutExerciseId',
    builder: (context, state) {
      final workoutExerciseId = state.pathParameters['workoutExerciseId'] ?? '';

      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => WorkoutExercisesListCubit(
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
        child: WorkoutRecordListPage(workoutExerciseId: workoutExerciseId),
      );
    },
  ),
];
