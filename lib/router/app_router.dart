import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/components/loading.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_states.dart';
import 'package:gym_app/features/auth/presentation/pages/auth_page.dart';
import 'package:gym_app/features/exercise/data/api_exercise_repo.dart';
import 'package:gym_app/features/exercise/presentation/cubits/exercise_cubit.dart';
import 'package:gym_app/features/exercise/presentation/pages/exercise_detail_page.dart';
import 'package:gym_app/features/exercise/presentation/pages/exercise_selector_page.dart';
import 'package:gym_app/features/exercise/presentation/pages/exercises_page.dart';
import 'package:gym_app/features/main/presentation/pages/main_page.dart';
import 'package:gym_app/features/routines/data/api_routine_repo.dart';
import 'package:gym_app/features/routines/domain/entities/routine.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_cubit.dart';
import 'package:gym_app/features/routines/presentation/pages/routine_create_page.dart';
import 'package:gym_app/features/routines/presentation/pages/routines_page.dart';
import 'package:gym_app/features/routines_exercises/data/api_routine_exercise_repo.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_create_cubit.dart';
import 'package:gym_app/features/routines_exercises/presentation/pages/routine_exercises_create_page.dart';
import 'package:gym_app/features/routines_exercises/presentation/pages/routine_exercises_page.dart';

GoRouter getAppRouter(BuildContext context) {
  final authCubit = context.read<AuthCubit>();

  return GoRouter(
    initialLocation: '/loading',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authCubit.state;

      if (authState is AuthLoading) {
        return state.matchedLocation == '/loading' ? null : "/loading";
      }

      if (authState is Unanthenticated && state.matchedLocation != '/auth') {
        return '/auth';
      }

      if (authState is Authenticated &&
          (state.matchedLocation == '/auth' ||
              state.matchedLocation == '/loading')) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: "/loading",
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainPage(),
      ),
      GoRoute(
        path: "/exercises",
        builder: (context, state) => ExercisesPage(),
      ),

      /** Exercises */
      // Obtener la información del ejercicio por su ID
      GoRoute(
        path: '/exercises/selector',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => ExerciseCubit(
              exerciseRepo: ApiExerciseRepo(),
            )..loadExercises(),
            child: const ExerciseSelectorPage(),
          );
        },
      ),

      // Obtener la información del ejercicio por su ID
      GoRoute(
        path: '/exercises/:exerciseId',
        builder: (context, state) {
          // Recupera el parámetro de manera segura
          final exerciseId = state.pathParameters["exerciseId"];
          return ExerciseDetailPage(exerciseId: exerciseId!);
        },
      ),

      /** Routines */
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

          return RoutineExercisesPage(
            routine: routine,
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

      // Crear una nueva rutina
      GoRoute(
        path: '/routines/create',
        builder: (_, _) => const RoutineCreatePage(),
      ),
    ],
  );
}

// Mueve esta clase justo aquí arriba
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
