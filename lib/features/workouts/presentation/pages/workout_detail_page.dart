import 'package:go_router/go_router.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_exercise.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_detail/workout_detail_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_detail/workout_detail_state.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_exercise/workout_exercise_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_exercise/workout_exercise_state.dart';
import 'package:gym_app/features/workouts/presentation/widgets/workout_exercise_card.dart';
import 'package:gym_app/features/workouts/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class WorkoutDetailPage extends StatefulWidget {
  final String workoutId;
  const WorkoutDetailPage({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  Future<void> redirectAddBottomSheet(
    BuildContext context,
    WorkoutExercise workoutExercise,
  ) async {
    final result = await context.push(
      "/workout-exercises/${workoutExercise.exerciseId}",
    );
    if (result == true) {
      await context.read<WorkoutExerciseCubit>().loadWorkoutExercises(
        widget.workoutId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -----------------------
            // HEADER DEL WORKOUT
            // -----------------------
            BlocBuilder<WorkoutDetailCubit, WorkoutDetailState>(
              builder: (context, state) {
                if (state is WorkoutDetailLoading) {
                  return SizedBox.shrink();
                }

                if (state is WorkoutDetailError) {
                  return SizedBox.shrink();
                }

                if (state is WorkoutDetailLoaded) {
                  final workout = state.workout;

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<WorkoutDetailCubit>().loadWorkoutById(
                        widget.workoutId,
                      );
                    },
                    child: Column(
                      children: [
                        // HEADER
                        Row(
                          children: [
                            Text(
                              workout.name,
                              style:
                                  Theme.of(
                                    context,
                                  ).textTheme.headlineSmall!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: workout.estado == "abierto"
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(
                                  12.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                child: Text(
                                  workout.estado == "abierto"
                                      ? "En progreso"
                                      : "Finalizado",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: workout.estado == "abierto"
                                        ? Colors.blue.shade800
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),

            SizedBox(
              height: 16,
            ),
            Expanded(
              child: BlocListener<WorkoutExerciseCubit, WorkoutExerciseState>(
                listener: (context, state) {
                  if (state is WorkoutExerciseSaveError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                child: BlocBuilder<WorkoutExerciseCubit, WorkoutExerciseState>(
                  builder: (context, state) {
                    if (state is WorkoutExerciseLoading ||
                        state is WorkoutExerciseSaving) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is WorkoutExerciseError) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await context
                              .read<WorkoutExerciseCubit>()
                              .loadWorkoutExercises(widget.workoutId);
                        },
                        child: CustomScrollView(
                          slivers: [
                            SliverFillRemaining(
                              child: Center(
                                child: Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Mostrar la lista tanto si se cargó inicialmente
                    // como si se guardó una serie correctamente.
                    if (state is WorkoutExercisesLoaded ||
                        state is WorkoutExerciseSaveSuccess) {
                      final workoutExercises = state is WorkoutExercisesLoaded
                          ? state.workoutExercises
                          : (state as WorkoutExerciseSaveSuccess)
                                .workoutExercises;

                      return RefreshIndicator(
                        onRefresh: () async {
                          await context
                              .read<WorkoutExerciseCubit>()
                              .loadWorkoutExercises(widget.workoutId);
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: workoutExercises.length,
                          itemBuilder: (context, index) {
                            final workoutExercise = workoutExercises[index];

                            return WorkoutExerciseCard(
                              key: ValueKey(workoutExercise.exerciseId),
                              workoutExercise: workoutExercise,
                              onRegisterSet: () => redirectAddBottomSheet(
                                context,
                                workoutExercise,
                              ),
                            );
                          },
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
