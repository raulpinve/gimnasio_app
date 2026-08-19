import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:gym_app/features/auth/presentation/cubits/auth_states.dart';
import 'package:gym_app/router/routine_exercises_routes.dart';
import 'package:gym_app/router/routine_routes.dart';
import 'package:gym_app/router/workout_exercises_routes.dart';
import 'package:gym_app/router/workout_routes.dart';
import 'exercise_routes.dart';
import 'auth_routes.dart';

GoRouter getAppRouter(BuildContext context) {
  final authCubit = context.read<AuthCubit>();

  return GoRouter(
    initialLocation: '/loading',
    // initialLocation:
    //     '/routine-exercises/9e40775e-5d40-4eba-a159-cbc8dda96070/create',
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
      ...authRoutes,
      ...exerciseRoutes,
      ...routineRoutes,
      ...routineExercisesRoutes,
      ...workoutRoutes,
      ...workoutExercisesRoutes,
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
