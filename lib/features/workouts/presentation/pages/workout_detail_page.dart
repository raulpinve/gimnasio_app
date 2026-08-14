import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercise_detail/workout_exercise_detail_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_detail/workout_detail_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_detail/workout_detail_state.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_exercise/workout_exercise_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_exercise/workout_exercise_state.dart';
import 'package:gym_app/features/workouts/presentation/widgets/workout_exercise_card.dart';
import 'package:gym_app/features/workouts/presentation/widgets/custom_app_bar.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_exercise.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
      "/workout-records/${workoutExercise.workoutExerciseId}",
    );

    // Verificamos si el contexto sigue activo en el árbol de widgets después del await
    if (!context.mounted) return;

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
                            Expanded(
                              child: Text(
                                workout.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                color: workout.estado == "abierto"
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: Text(
                                workout.estado == "abierto"
                                    ? "En curso"
                                    : "Completado",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: workout.estado == "abierto"
                                      ? Colors.blue.shade800
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ),

                            const SizedBox(width: 2),

                            IconButton(
                              onPressed: workout.estado == "abierto"
                                  ? () async {
                                      final currentContext = context;

                                      final workoutExerciseCubit =
                                          currentContext
                                              .read<
                                                WorkoutExerciseDetailCubit
                                              >();

                                      final workoutDetailCubit = currentContext
                                          .read<WorkoutDetailCubit>();

                                      final exercise = await currentContext
                                          .push<Exercise>(
                                            "/exercises/selector",
                                          );

                                      if (!mounted) return;

                                      if (exercise != null) {
                                        await workoutExerciseCubit
                                            .createWorkoutExercise(
                                              workout.id,
                                              exercise.id,
                                            );

                                        if (!mounted) return;

                                        await workoutDetailCubit
                                            .loadWorkoutById(
                                              workout.id,
                                            );
                                      }
                                    }
                                  : null,
                              icon: const Icon(Icons.add),
                              tooltip: "Agregar ejercicio",
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
