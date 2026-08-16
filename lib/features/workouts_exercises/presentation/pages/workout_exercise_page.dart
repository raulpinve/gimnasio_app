import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercise_detail/workout_exercise_detail_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_detail/workout_detail_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_detail/workout_detail_state.dart';
import 'package:gym_app/features/workouts_exercises/domain/entities/workout_exercise.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercises_list/workout_exercises_list_cubit.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercises_list/workout_exercises_list_state.dart';
import 'package:gym_app/features/workouts_exercises/presentation/widgets/workout_exercise_card.dart';

class WorkoutExercisePage extends StatefulWidget {
  final String workoutId;
  const WorkoutExercisePage({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutExercisePage> createState() => _WorkoutExercisePageState();
}

class _WorkoutExercisePageState extends State<WorkoutExercisePage> {
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
      // TODO: Cambiar el workout exercise
      // await context.read<WorkoutExerciseCubit>().loadWorkoutExercises(
      //   widget.workoutId,
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
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
              child:
                  BlocBuilder<
                    WorkoutExercisesListCubit,
                    WorkoutExercisesListState
                  >(
                    builder: (context, state) {
                      // CARGA INICIAL
                      if (state is WorkoutExercisesListLoading) {
                        // TODO: SKELETON LOADER
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      // ERROR
                      if (state is WorkoutExercisesListError) {
                        return Center(
                          child: Text(state.message),
                        );
                      }

                      // ENTRENAMIENTOS CARGADOS
                      if (state is WorkoutExercisesListLoaded) {
                        if (state.workoutExercises.isEmpty) {
                          return const Center(
                            child: Text("No se encontraron ejercicios"),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<WorkoutExercisesListCubit>()
                                .loadWorkoutExercises(
                                  widget.workoutId,
                                );
                          },
                          child: ListView.separated(
                            itemBuilder: (context, index) {
                              final workoutExercise =
                                  state.workoutExercises[index];

                              return WorkoutExerciseCard(
                                key: ValueKey(workoutExercise.exerciseId),
                                workoutExercise: workoutExercise,
                                onRegisterSet: () => redirectAddBottomSheet(
                                  context,
                                  workoutExercise,
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                                  return const SizedBox(
                                    height: 16,
                                  );
                                },
                            itemCount: state.workoutExercises.length,
                          ),
                        );
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
