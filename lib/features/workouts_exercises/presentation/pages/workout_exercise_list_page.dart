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
    await context.read<WorkoutExercisesListCubit>().loadWorkoutExercises(
      widget.workoutId,
    );
  }

  Future<void> _confirmDelete(
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

  // Eliminar el entrenamiento completo (no un ejercicio individual).
  // Acción destructiva y poco frecuente: vive en el menú "⋮" del AppBar.
  Future<void> _confirmDeleteWorkout(BuildContext context) async {
    final cubit = context.read<WorkoutDetailCubit>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Eliminar entrenamiento'),
              content: const Text(
                '¿Seguro que deseas eliminar este entrenamiento? '
                'Se perderán todos los ejercicios y registros asociados.',
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
                          });

                          await cubit.deleteWorkout(widget.workoutId);

                          if (!dialogContext.mounted) return;
                          Navigator.of(dialogContext).pop();

                          if (!context.mounted) return;
                          context.pop(true); // vuelve a la pantalla anterior
                        },
                  child: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
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

  // Finalizar el entrenamiento en curso. También pide confirmación porque
  // es una acción irreversible (cambia el estado a "completado").
  Future<void> _confirmFinishWorkout(BuildContext context) async {
    final cubit = context.read<WorkoutDetailCubit>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool isFinishing = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Finalizar entrenamiento'),
              content: const Text(
                '¿Seguro que deseas finalizar este entrenamiento? '
                'No podrás agregar más ejercicios después.',
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
                          setState(() {
                            isFinishing = true;
                          });

                          // TODO: reemplazar por el método real del cubit,
                          // ej: await cubit.finishWorkout(widget.workoutId);
                          await cubit.finishWorkout(widget.workoutId);

                          if (!dialogContext.mounted) return;
                          Navigator.of(dialogContext).pop();
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
            );
          },
        );
      },
    );
  }

  // Extraído: la acción de navegar a agregar ejercicio y refrescar la lista.
  // Ahora la usan tanto el estado vacío como el botón de abajo.
  Future<void> _goToAddExercise(BuildContext context, String workoutId) async {
    final exercisesCubit = context.read<WorkoutExercisesListCubit>();

    final result = await context.push<bool>(
      "/workout-exercise-add-exercise/$workoutId",
    );

    if (!context.mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ejercicio agregado")),
      );
      await exercisesCubit.loadWorkoutExercises(workoutId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          // "Finalizar": acción primaria, estilo texto, tipo "Listo" de iOS.
          // Solo se muestra si el entrenamiento sigue en curso.
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

          // "⋮" acciones destructivas/secundarias, al final del todo.
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                    ),
                  );
                } else if (state is WorkoutExerciseDetailCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ejercicio agregado con éxito'),
                    ),
                  );
                }
              },
              child: BlocBuilder<WorkoutDetailCubit, WorkoutDetailState>(
                builder: (context, state) {
                  // CARGA INICIAL WORKOUT
                  if (state is WorkoutDetailLoading) {
                    return SizedBox.shrink();
                  }

                  // ERROR DE CARGA DEL WORKOUT
                  if (state is WorkoutDetailError) {
                    return RefreshableContent(
                      onRefresh: _onRefresh,
                      child: Text(state.message),
                    );
                  }

                  // WORKOUT CARGADO
                  if (state is WorkoutDetailLoaded) {
                    final workout = state.workout;

                    // El header ahora es solo informativo: nombre + estado.
                    // El botón de agregar se movió debajo de la lista.
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            workout.name,
                            style: Theme.of(context).textTheme.headlineSmall!
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
                      ],
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.errorMessage!),
                          ),
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
                        // Estado del workout (abierto/cerrado + id), lo
                        // necesitamos acá porque el botón de agregar ahora
                        // vive dentro de este mismo ListView, como último item.
                        final workoutDetailState = context
                            .watch<WorkoutDetailCubit>()
                            .state;
                        final isOpen =
                            workoutDetailState is WorkoutDetailLoaded &&
                            workoutDetailState.workout.estado == "abierto";
                        final workoutId = widget.workoutId;

                        Widget addExerciseButton() {
                          final colorScheme = Theme.of(context).colorScheme;

                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isOpen
                                    ? () => _goToAddExercise(context, workoutId)
                                    : null,
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
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 20,
                                        color: isOpen
                                            ? colorScheme.primary
                                            : colorScheme.onSurface.withValues(
                                                alpha: 0.38,
                                              ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Agregar ejercicio',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isOpen
                                              ? colorScheme.primary
                                              : colorScheme.onSurface
                                                    .withValues(alpha: 0.38),
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
                                onDelete: () => _confirmDelete(
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
