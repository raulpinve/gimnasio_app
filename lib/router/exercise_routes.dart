import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/exercise/data/api_exercise_repo.dart';
import 'package:gym_app/features/exercise/presentation/cubits/exercise_list_cubit.dart';
import 'package:gym_app/features/exercise/presentation/pages/exercise_detail_page.dart';
import 'package:gym_app/features/exercise/presentation/pages/exercise_selector_page.dart';

final exerciseRoutes = <GoRoute>[
  GoRoute(
    path: '/exercises/selector',
    builder: (context, state) {
      return BlocProvider(
        create: (_) => ExerciseListCubit(
          exerciseRepo: ApiExerciseRepo(),
        )..loadExercises(),
        child: const ExerciseSelectorPage(),
      );
    },
  ),

  GoRoute(
    path: '/exercises/:exerciseId',
    builder: (context, state) {
      final exerciseId = state.pathParameters['exerciseId']!;

      return ExerciseDetailPage(
        exerciseId: exerciseId,
      );
    },
  ),
];
