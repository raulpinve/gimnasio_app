import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/components/loading.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_states.dart';
import 'package:gym_app/features/auth/presentation/pages/auth_page.dart';
import 'package:gym_app/features/exercise/presentation/pages/exercise_detail_page.dart';
import 'package:gym_app/features/exercise/presentation/pages/exercises_page.dart';
import 'package:gym_app/features/main/presentation/pages/main_page.dart';
import 'package:gym_app/features/routines/presentation/pages/routine_create_page.dart';

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
        path: '/exercises/:exerciseId',
        builder: (context, state) {
          // Recupera el parámetro de manera segura
          final exerciseId = state.pathParameters["exerciseId"];
          return ExerciseDetailPage(exerciseId: exerciseId!);
        },
      ),

      /** Routines */
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
