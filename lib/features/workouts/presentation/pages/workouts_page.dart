import 'package:gym_app/features/workouts/presentation/cubits/active_workout/active_workout_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/active_workout/active_workout_state.dart';
import 'package:gym_app/features/workouts/presentation/cubits/create_workout/workout_create_cubit.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/utils/snackbar_helper.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_state.dart';
import 'package:gym_app/features/workouts/presentation/cubits/create_workout/workout_create_state.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_list_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_list_state.dart';
import 'package:gym_app/features/workouts/presentation/widgets/recent_workout_card.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  Future<void> onRefresh() async {
    await Future.wait([
      context.read<RoutineListCubit>().loadRoutines(showLoading: false),
      context.read<WorkoutListCubit>().loadWorkouts(showLoading: false),
      context.read<ActiveWorkoutCubit>().loadActiveWorkout(showLoading: false),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<WorkoutCreateCubit, WorkoutCreateState>(
          listener: (context, state) async {
            if (state.isCreated && state.workoutId != null) {
              if (!context.mounted) return;

              await context.push(
                '/workouts-exercises/${state.workoutId}',
              );

              if (!context.mounted) return;

              await onRefresh();
            }

            if (state.errorMessage != null) {
              if (!context.mounted) return;

              showMessage(context, state.errorMessage!);
            }
          },
        ),
      ],
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SafeArea(
                child: BlocBuilder<ActiveWorkoutCubit, ActiveWorkoutState>(
                  builder: (context, state) {
                    if (state is ActiveWorkoutLoading) {
                      return const CircularProgressIndicator();
                    }

                    if (state is ActiveWorkoutLoaded) {
                      final workout = state.workout;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (workout == null) ...[
                            const SizedBox(height: 18),

                            Text(
                              '¿Qué vas a entrenar hoy?',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),

                            Text(
                              'Elige cómo quieres empezar tu entrenamiento.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),

                            const SizedBox(height: 20),

                            _buildFreeWorkoutCard(context),

                            const SizedBox(height: 32),

                            Text(
                              'Tus rutinas',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildRoutines(context),
                            const SizedBox(height: 20),
                          ],

                          if (workout != null) ...[
                            const SizedBox(height: 18),
                            Text(
                              'Continúa tu entrenamiento',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildWorkoutActive(context, workout.id),
                            const SizedBox(height: 32),
                          ],

                          _buildRecentSection(context),
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutActive(BuildContext context, String? workoutId) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (workoutId != null) {
            context.push("/workouts-exercises/$workoutId");
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entrenamiento en curso',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Tienes un entrenamiento pendiente. Continúa donde lo dejaste.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withValues(
                          alpha: 0.82,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(
                    alpha: 0.14,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreeWorkoutCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final workoutState = context.watch<WorkoutCreateCubit>().state;

    final isLoading =
        workoutState.isCreating && workoutState.creationType == 'free';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                context.read<WorkoutCreateCubit>().createWorkout({}, 'free');
              },
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entrenamiento libre',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Empieza desde cero y agrega los ejercicios que quieras.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withValues(
                          alpha: 0.82,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(
                    alpha: 0.14,
                  ),
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward_rounded,
                        color: colorScheme.onPrimary,
                        size: 20,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutines(BuildContext context) {
    final state = context.watch<RoutineListCubit>().state;

    if (state is RoutineListLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is RoutineListError) {
      return Text(
        state.message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
      );
    }

    if (state is RoutinesListLoaded) {
      if (state.routines.isEmpty) {
        return Text(
          'No tienes rutinas creadas.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      }

      final workoutState = context.watch<WorkoutCreateCubit>().state;

      return Column(
        children: [
          for (int i = 0; i < state.routines.length; i++) ...[
            _buildRoutineCard(
              context,
              routine: state.routines[i],
              isLoading:
                  workoutState.isCreating &&
                  workoutState.creationType == 'routine' &&
                  workoutState.routineId == state.routines[i].id,
            ),

            if (i < state.routines.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildRoutineCard(
    BuildContext context, {
    required dynamic routine,
    required bool isLoading,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                context.read<WorkoutCreateCubit>().createWorkout(
                  {
                    'routineId': routine.id,
                  },
                  'routine',
                  routineId: routine.id,
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      routine.exercises
                              ?.map((exercise) => exercise.name)
                              .join(' · ') ??
                          '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    final state = context.watch<WorkoutListCubit>().state;

    if (state is WorkoutListLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is WorkoutListError) {
      return const SizedBox.shrink();
    }

    if (state is! WorkoutsListLoaded || state.workouts.isEmpty) {
      return const SizedBox.shrink();
    }

    final recentWorkouts = state.workouts.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recientes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push("/workouts-list");
              },
              child: const Text('Ver todo →'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        for (int i = 0; i < recentWorkouts.length; i++) ...[
          recentWorkoutCard(
            context,
            workout: recentWorkouts[i],
          ),

          if (i < recentWorkouts.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}
