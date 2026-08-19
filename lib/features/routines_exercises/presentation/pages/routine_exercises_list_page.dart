import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/widgets/refreshable_content.dart';
import 'package:gym_app/features/auth/presentation/components/my_appbar_button.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine/routine_detail_cubit.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine/routine_detail_state.dart';
import 'package:gym_app/features/routines_exercises/data/api_routine_exercise_repo.dart';
import 'package:gym_app/features/routines_exercises/domain/entities/routine_exercise.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_list/routine_exercises_list_cubit.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_list/routine_exercises_list_state.dart';

class RoutineExercisesListPage extends StatefulWidget {
  final String routineId;

  const RoutineExercisesListPage({
    super.key,
    required this.routineId,
  });

  @override
  State<RoutineExercisesListPage> createState() =>
      _RoutineExercisesListPageState();
}

class _RoutineExercisesListPageState extends State<RoutineExercisesListPage> {
  final apiRoutineExerciseRepo = ApiRoutineExerciseRepo();

  Future<void> _onRefreshRoutineExercises(String routineId) async {
    await context.read<RoutineExercisesListCubit>().loadRoutineExercises(
      routineId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoutineDetailCubit, RoutineDetailState>(
      builder: (context, state) {
        // =================================
        // ============= RUTINA ============
        // =================================

        // LOADING RUTINA
        if (state is RoutineDetailLoading || state is RoutineDetailInitial) {
          return Scaffold(
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ERROR AL CARGAR LA RUTINA
        if (state is RoutineDetailError) {
          return Scaffold(
            body: Center(
              child: Text(
                state.message,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          );
        }

        // RUTINA CARGADA
        if (state is RoutineDetailLoaded) {
          final routine = state.routine;

          return Scaffold(
            appBar: AppBar(
              title: Text(routine.name),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              actions: [
                MyAppbarButton(
                  onPressed: () async {
                    final response = await context.push<bool>(
                      "/routine-exercises/${routine.id}/create",
                    );

                    // Stop execution is the user navigated away while the page was open
                    if (!context.mounted) return;

                    if (response == true) {
                      context
                          .read<RoutineExercisesListCubit>()
                          .loadRoutineExercises(routine.id);
                    }
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ===================================
                  // ======== ROUTINE EXERCISES ========
                  // ===================================
                  Expanded(
                    child:
                        BlocBuilder<
                          RoutineExercisesListCubit,
                          RoutineExercisesListState
                        >(
                          builder: (context, state) {
                            // LOADING EXERCISES ROUTINES
                            if (state is RoutineExercisesListLoading) {
                              return skeletonLoader(context);
                            }

                            // SHOW EXERCISES ROUTINE ERROR
                            if (state is RoutineExercisesListError) {
                              return RefreshableContent(
                                child: Text(state.message),
                                onRefresh: () =>
                                    _onRefreshRoutineExercises(routine.id),
                              );
                            }

                            // ROUTINES EXERCISES LOADED
                            if (state is RoutineExercisesListLoaded) {
                              // ROUTINE EXERCISES
                              if (state.routineExercises.isEmpty) {
                                return RefreshableContent(
                                  child: Text(
                                    "No hay ejercicios para esta rutina",
                                  ),
                                  onRefresh: () =>
                                      _onRefreshRoutineExercises(routine.id),
                                );
                              }

                              return RefreshIndicator(
                                onRefresh: () =>
                                    _onRefreshRoutineExercises(routine.id),
                                child: ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemCount: state.routineExercises.length,
                                  itemBuilder: (context, index) {
                                    final exercise =
                                        state.routineExercises[index];

                                    return tarjetasExercises(
                                      exercise,
                                      context,
                                      routine.id,
                                    );
                                  },
                                ),
                              );
                            }

                            return skeletonLoader(context);
                          },
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget skeletonLoader(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

Widget tarjetasExercises(
  RoutineExercise routineExercise,
  BuildContext context,
  String routineId,
) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  final details = <String>[];

  if (routineExercise.targetSets != null) {
    details.add('Series: ${routineExercise.targetSets}');
  }

  if (routineExercise.targetReps != null) {
    details.add('Reps: ${routineExercise.targetReps}');
  }

  if (routineExercise.targetWeight != null) {
    details.add('Peso: ${routineExercise.targetWeight} kg');
  }

  if (routineExercise.targetDurationSeconds != null) {
    details.add('Duración: ${routineExercise.targetDurationSeconds} s');
  }

  if (routineExercise.targetDistanceKm != null) {
    details.add('Distancia: ${routineExercise.targetDistanceKm} km');
  }

  return GestureDetector(
    onTap: () {
      context.push(
        '/exercises/${routineExercise.exerciseId}',
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        8,
        14,
      ),
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen
          _buildRoutineExerciseImage(
            context,
            routineExercise,
          ),

          const SizedBox(width: 14),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routineExercise.exerciseName ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                // Tipo de ejercicio
                Row(
                  children: [
                    Icon(
                      routineExercise.exerciseType == 'cardio'
                          ? Icons.directions_run_outlined
                          : Icons.fitness_center_outlined,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      routineExercise.exerciseType == 'cardio'
                          ? 'Cardio'
                          : 'Fuerza',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                if (details.isNotEmpty) ...[
                  const SizedBox(height: 7),

                  Text(
                    details.join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Menú
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.more_vert,
              size: 22,
            ),
            color: colorScheme.surface,
            onSelected: (String opcion) {
              if (opcion == 'editar') {
                _redirigirAEditar(
                  context,
                  routineExercise,
                  routineId,
                );
              } else if (opcion == 'eliminar') {
                _confirmDelete(
                  context,
                  routineExercise,
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 10),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'eliminar',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 10),
                    Text('Eliminar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildRoutineExerciseImage(
  BuildContext context,
  RoutineExercise routineExercise,
) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: routineExercise.avatar?.isNotEmpty == true
        ? Image.network(
            routineExercise.avatar!,
            width: 68,
            height: 68,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              return _buildRoutineExercisePlaceholder(
                context,
                routineExercise,
              );
            },
          )
        : _buildRoutineExercisePlaceholder(
            context,
            routineExercise,
          ),
  );
}

Widget _buildRoutineExercisePlaceholder(
  BuildContext context,
  RoutineExercise routineExercise,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Container(
    width: 68,
    height: 68,
    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
    alignment: Alignment.center,
    child: Icon(
      routineExercise.exerciseType == 'cardio'
          ? Icons.directions_run_outlined
          : Icons.fitness_center_outlined,
      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
      size: 28,
    ),
  );
}

Future<void> _redirigirAEditar(
  BuildContext context,
  RoutineExercise routineExercise,
  String routineId,
) async {
  final resultado = await context.push<bool>(
    '/routine-exercises/${routineExercise.id}/update',
  );

  if (!context.mounted) return;

  if (resultado == true) {
    await context.read<RoutineExercisesListCubit>().loadRoutineExercises(
      routineId,
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  RoutineExercise routineExercises,
) async {
  final cubit = context.read<RoutineExercisesListCubit>();

  await showDialog(
    context: context,
    builder: (dialogContext) {
      bool isDeleting = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Eliminar ejercicio"),
            content: Text(
              '¿Segudro que deseas eliminar "${routineExercises.exerciseName}"?',
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

                        await cubit.deleteRoutineExercise(
                          routineExercises.id,
                        );

                        if (!dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
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
