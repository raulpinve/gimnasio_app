import 'package:gym_app/core/utils/snackbar_helper.dart';
import 'package:gym_app/core/widgets/refreshable_content.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercise_detail/workout_exercise_detail_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_detail/workout_detail_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_detail/workout_detail_state.dart';
import 'package:gym_app/features/workouts_exercises/domain/entities/workout_exercise.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercise_detail/workout_exercise_detail_state.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercises_list/workout_exercises_list_cubit.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercises_list/workout_exercises_list_state.dart';
import 'package:gym_app/features/workouts_exercises/presentation/widgets/workout_exercise_card.dart';
import 'package:gym_app/features/workouts/domain/entities/workout.dart';

class WorkoutExercisePage extends StatefulWidget {
  final String workoutId;
  const WorkoutExercisePage({
    super.key,
    required this.workoutId,
  });

  @override
  State<WorkoutExercisePage> createState() => _WorkoutExerciseListPageState();
}

class _WorkoutExerciseListPageState extends State<WorkoutExercisePage> {
  Future<void> redirectAddWorkoutRecord(
    BuildContext context,
    WorkoutExercise workoutExercise,
  ) async {
    final result = await context.push(
      "/workout-records/${workoutExercise.workoutExerciseId}",
    );

    if (!context.mounted) return;

    if (result == true) {
      await _onRefresh();
    }
  }

  Future<void> _onRefresh() async {
    final exercisesCubit = context.read<WorkoutExercisesListCubit>();
    final workoutCubit = context.read<WorkoutDetailCubit>();

    await exercisesCubit.loadWorkoutExercises(widget.workoutId);
    await workoutCubit.loadWorkoutById(widget.workoutId);
  }

  Future<void> _confirmDeleteExercise(
    BuildContext context,
    WorkoutExercise workoutExercise,
  ) async {
    final cubit = context.read<WorkoutExercisesListCubit>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool isDeleting = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Eliminar ejercicio'),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Seguro que deseas eliminar '
                    '"${workoutExercise.exerciseName}"?',
                  ),

                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),

              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),

                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setState(() {
                            isDeleting = true;
                            errorMessage = null;
                          });

                          final success = await cubit.deleteWorkoutExercise(
                            workoutExercise.workoutExerciseId ?? '',
                          );

                          if (!dialogContext.mounted) return;

                          if (success) {
                            Navigator.of(dialogContext).pop();

                            showMessage(
                              context,
                              'Ejercicio eliminado correctamente.',
                              type: MessageType.success,
                            );
                          } else {
                            final state = cubit.state;

                            setState(() {
                              isDeleting = false;
                              errorMessage = state is WorkoutExercisesListLoaded
                                  ? state.errorMessage ??
                                        'No se pudo eliminar el ejercicio.'
                                  : 'No se pudo eliminar el ejercicio.';
                            });
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteWorkout(BuildContext context) async {
    final cubit = context.read<WorkoutDetailCubit>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: cubit,
          child: BlocListener<WorkoutDetailCubit, WorkoutDetailState>(
            listener: (context, state) {
              if (state is WorkoutDetailDeleted) {
                Navigator.of(dialogContext).pop();

                if (context.mounted) {
                  context.pop(true);
                  showMessage(
                    context,
                    'Entrenamiento eliminado con éxito',
                    type: MessageType.success,
                  );
                }
              }
            },
            child: BlocBuilder<WorkoutDetailCubit, WorkoutDetailState>(
              builder: (context, state) {
                final isDeleting = state is WorkoutDetailDeleting;

                return AlertDialog(
                  title: const Text('Eliminar entrenamiento'),
                  content: state is WorkoutDetailError
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '¿Seguro que deseas eliminar este entrenamiento? '
                              'Se perderán todos los ejercicios y registros asociados.',
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          '¿Seguro que deseas eliminar este entrenamiento? '
                          'Se perderán todos los ejercicios y registros asociados.',
                        ),
                  actions: [
                    TextButton(
                      onPressed: isDeleting
                          ? null
                          : () {
                              Navigator.of(dialogContext).pop();
                            },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: isDeleting
                          ? null
                          : () async {
                              await cubit.deleteWorkout(widget.workoutId);
                            },
                      child: isDeleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Eliminar'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmFinishWorkout(BuildContext context) async {
    final cubit = context.read<WorkoutDetailCubit>();
    final pageContext = context;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool isFinishing = false;
        String? errorMessage;

        return BlocProvider.value(
          value: cubit,
          child: StatefulBuilder(
            builder: (context, setState) {
              return BlocListener<WorkoutDetailCubit, WorkoutDetailState>(
                listener: (context, state) {
                  if (state is WorkoutDetailFinishing) {
                    setState(() {
                      isFinishing = true;
                      errorMessage = null;
                    });
                  }

                  if (state is WorkoutDetailError) {
                    setState(() {
                      isFinishing = false;
                      errorMessage = state.message;
                    });
                  }

                  if (state is WorkoutDetailFinished) {
                    Navigator.of(dialogContext).pop();

                    if (pageContext.mounted) {
                      showMessage(
                        pageContext, // 👈 usamos el context de la página, no el del diálogo
                        'Entrenamiento finalizado con éxito',
                        type: MessageType.success,
                      );
                    }
                  }
                },
                child: AlertDialog(
                  title: const Text('Finalizar entrenamiento'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¿Seguro que deseas finalizar este entrenamiento? '
                        'No podrás agregar más ejercicios después.',
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: isFinishing
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: isFinishing
                          ? null
                          : () async {
                              await cubit.finishWorkout(widget.workoutId);
                            },
                      child: isFinishing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Finalizar'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _goToAddExercise(BuildContext context, String workoutId) async {
    final exercisesCubit = context.read<WorkoutExercisesListCubit>();

    final result = await context.push<bool>(
      "/workout-exercise-add-exercise/$workoutId",
    );

    if (!context.mounted) return;

    if (result == true) {
      showMessage(
        context,
        "Ejercicio agregado",
        type: MessageType.success,
      );
      await exercisesCubit.loadWorkoutExercises(workoutId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.pop(true);
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          BlocBuilder<WorkoutDetailCubit, WorkoutDetailState>(
            builder: (context, state) {
              final isOpen =
                  state is WorkoutDetailLoaded &&
                  state.workout.estado == "abierto";

              if (!isOpen) return const SizedBox.shrink();

              return TextButton(
                onPressed: () => _confirmFinishWorkout(context),
                child: const Text(
                  'Finalizar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'eliminar') {
                _confirmDeleteWorkout(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'eliminar',
                child: Text('Eliminar entrenamiento'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            BlocListener<
              WorkoutExerciseDetailCubit,
              WorkoutExerciseDetailState
            >(
              listener: (context, state) {
                if (state is WorkoutExerciseDetailError) {
                  showMessage(
                    context,
                    state.message,
                    type: MessageType.error,
                  );
                } else if (state is WorkoutExerciseDetailCreated) {
                  showMessage(
                    context,
                    'Ejercicio agregado con éxito',
                    type: MessageType.success,
                  );
                }
              },
              child: BlocBuilder<WorkoutDetailCubit, WorkoutDetailState>(
                builder: (context, state) {
                  Workout? workout;

                  if (state is WorkoutDetailLoaded) {
                    workout = state.workout;
                  } else if (state is WorkoutDetailFinishing) {
                    workout = state.workout;
                  } else if (state is WorkoutDetailError) {
                    workout = state.workout;
                  }

                  if (workout == null) {
                    return const SizedBox.shrink();
                  }

                  final colorScheme = Theme.of(context).colorScheme;

                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          workout.name,
                          style: Theme.of(context).textTheme.headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: workout.estado == "abierto"
                              ? colorScheme.primary.withValues(alpha: 0.12)
                              : colorScheme.onSurface.withValues(alpha: 0.08),
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
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            Expanded(
              child:
                  BlocConsumer<
                    WorkoutExercisesListCubit,
                    WorkoutExercisesListState
                  >(
                    listener: (context, state) {
                      if (state is WorkoutExercisesListLoaded &&
                          state.errorMessage != null) {
                        showMessage(
                          context,
                          state.errorMessage!,
                          type: MessageType.error,
                        );
                      }
                    },
                    builder: (context, state) {
                      // LOADING INICIAL
                      if (state is WorkoutExercisesListLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      // ERROR
                      if (state is WorkoutExercisesListError) {
                        return RefreshableContent(
                          onRefresh: _onRefresh,
                          child: Text(state.message),
                        );
                      }

                      // ENTRENAMIENTOS CARGADOS
                      if (state is WorkoutExercisesListLoaded) {
                        final workoutDetailState = context
                            .watch<WorkoutDetailCubit>()
                            .state;

                        final isOpen = switch (workoutDetailState) {
                          WorkoutDetailLoaded state =>
                            state.workout.estado == "abierto",
                          WorkoutDetailFinishing state =>
                            state.workout.estado == "abierto",
                          WorkoutDetailError state =>
                            state.workout?.estado == "abierto",
                          _ => false,
                        };
                        final workoutId = widget.workoutId;

                        Widget addExerciseButton() {
                          final colorScheme = Theme.of(context).colorScheme;

                          if (!isOpen) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    _goToAddExercise(context, workoutId),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 20,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Agregar ejercicio',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        if (state.workoutExercises.isEmpty) {
                          // Sin ejercicios: mostramos el mensaje y, debajo,
                          // el botón para agregar el primero.
                          return RefreshableContent(
                            onRefresh: _onRefresh,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("No se encontraron ejercicios"),
                                const SizedBox(height: 16),
                                addExerciseButton(),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView.separated(
                            // +1: el último item es el botón de agregar,
                            // así scrollea junto con los ejercicios.
                            itemCount: state.workoutExercises.length + 1,
                            separatorBuilder:
                                (BuildContext context, int index) {
                                  return const SizedBox(
                                    height: 16,
                                  );
                                },
                            itemBuilder: (context, index) {
                              if (index == state.workoutExercises.length) {
                                return addExerciseButton();
                              }

                              final workoutExercise =
                                  state.workoutExercises[index];

                              return WorkoutExerciseCard(
                                key: ValueKey(workoutExercise.exerciseId),
                                workoutExercise: workoutExercise,
                                onRegisterSet: () => redirectAddWorkoutRecord(
                                  context,
                                  workoutExercise,
                                ),
                                isOpen: isOpen,
                                onDelete: () => _confirmDeleteExercise(
                                  context,
                                  workoutExercise,
                                ),
                              );
                            },
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

Widget skeletonLoader(BuildContext context) {
  return Center(
    child: CircularProgressIndicator(),
  );
}
