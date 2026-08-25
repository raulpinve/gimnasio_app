import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/utils/snackbar_helper.dart';
import 'package:gym_app/core/widgets/refreshable_content.dart';
import 'package:gym_app/features/auth/presentation/components/my_appbar_button.dart';
import 'package:gym_app/features/exercise/presentation/widgets/exercise_thumbnail.dart';
import 'package:gym_app/features/routines/domain/entities/routine.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine/routine_detail_cubit.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine/routine_detail_state.dart';
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
  Future<void> _onRefreshRoutineExercises(
    String routineId,
  ) async {
    await context.read<RoutineExercisesListCubit>().loadRoutineExercises(
      routineId,
    );
  }

  Future<void> _redireccionarCrear(Routine routine) async {
    final response = await context.push<bool>(
      '/routine-exercises/${routine.id}/create',
    );

    if (!mounted) return;

    if (response == true) {
      await context.read<RoutineExercisesListCubit>().loadRoutineExercises(
        routine.id,
      );

      if (!mounted) return;

      showMessage(
        context,
        'Ejercicio agregado a la rutina.',
      );
    }
  }

  Future<void> _redirigirAEditar(
    RoutineExercise routineExercise,
    String routineId,
  ) async {
    final cubit = context.read<RoutineExercisesListCubit>();

    final resultado = await context.push<bool>(
      '/routine-exercises/${routineExercise.id}/update',
    );

    if (!mounted) return;

    if (resultado == true) {
      await cubit.loadRoutineExercises(routineId);

      if (!mounted) return;

      showMessage(
        context,
        'Ejercicio actualizado correctamente.',
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    RoutineExercise routineExercise,
  ) async {
    final cubit = context.read<RoutineExercisesListCubit>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Eliminar ejercicio'),
              content: Text(
                '¿Seguro que deseas eliminar '
                '"${routineExercise.exerciseName}"?',
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
                            routineExercise.id,
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoutineDetailCubit, RoutineDetailState>(
      builder: (context, state) {
        // ================================
        // ============ RUTINA =============
        // ================================

        if (state is RoutineDetailLoading || state is RoutineDetailInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is RoutineDetailError) {
          return Scaffold(
            body: Center(
              child: Text(state.message),
            ),
          );
        }

        if (state is RoutineDetailLoaded) {
          final routine = state.routine;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              actions: [
                MyAppbarButton(
                  onPressed: () => _redireccionarCrear(routine),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================================
                  // ========= NOMBRE RUTINA =========
                  // ================================
                  Text(
                    routine.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ================================
                  // ========== EJERCICIOS ==========
                  // ================================
                  Text(
                    'Ejercicios',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child:
                        BlocBuilder<
                          RoutineExercisesListCubit,
                          RoutineExercisesListState
                        >(
                          builder: (context, state) {
                            // ================================
                            // ============ LOADING ============
                            // ================================

                            if (state is RoutineExercisesListLoading) {
                              return skeletonLoader(context);
                            }

                            // ================================
                            // ============== ERROR ============
                            // ================================

                            if (state is RoutineExercisesListError) {
                              return RefreshableContent(
                                child: Text(state.message),
                                onRefresh: () => _onRefreshRoutineExercises(
                                  routine.id,
                                ),
                              );
                            }

                            // ================================
                            // ============ CARGADOS ===========
                            // ================================

                            if (state is RoutineExercisesListLoaded) {
                              if (state.routineExercises.isEmpty) {
                                return _buildEmptyExercises(
                                  context,
                                  routine,
                                );
                              }

                              return RefreshIndicator(
                                onRefresh: () => _onRefreshRoutineExercises(
                                  routine.id,
                                ),
                                child: ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 2),
                                  itemCount: state.routineExercises.length,
                                  itemBuilder: (context, index) {
                                    final exercise =
                                        state.routineExercises[index];

                                    return exercisesCards(
                                      exercise,
                                      context,
                                      routine.id,
                                      _redirigirAEditar,
                                      _confirmDelete,
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

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget skeletonLoader(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyExercises(
    BuildContext context,
    Routine routine,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 48,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tu rutina está vacía',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            Text(
              'Añade ejercicios para comenzar.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () => _redireccionarCrear(routine),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Añadir ejercicio',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget exercisesCards(
  RoutineExercise routineExercise,
  BuildContext context,
  String routineId,
  Future<void> Function(
    RoutineExercise routineExercise,
    String routineId,
  )
  onEdit,
  Future<void> Function(
    BuildContext context,
    RoutineExercise routineExercise,
  )
  onDelete,
) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  final isCardio = routineExercise.exerciseType == 'cardio';

  final details = <String>[];

  if (routineExercise.targetSets != null) {
    details.add('${routineExercise.targetSets} series');
  }

  if (routineExercise.targetReps != null) {
    details.add('${routineExercise.targetReps} reps');
  }

  if (routineExercise.targetWeight != null) {
    details.add('${routineExercise.targetWeight} kg');
  }

  if (routineExercise.targetDurationSeconds != null) {
    final seconds = routineExercise.targetDurationSeconds!;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      details.add(
        remainingSeconds > 0
            ? '${minutes}m ${remainingSeconds}s'
            : '$minutes min',
      );
    } else {
      details.add('${remainingSeconds}s');
    }
  }

  if (routineExercise.targetDistanceKm != null) {
    details.add('${routineExercise.targetDistanceKm} km');
  }

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        context.push(
          '/exercises/${routineExercise.exerciseId}',
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ExerciseThumbnail(
              name: routineExercise.exerciseName ?? '',
              imageUrl: routineExercise.avatar,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routineExercise.exerciseName ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    isCardio ? 'Cardio' : 'Fuerza',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      details.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 4),

            SizedBox(
              width: 36,
              height: 36,
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (option) {
                  if (option == 'editar') {
                    onEdit(
                      routineExercise,
                      routineId,
                    );
                  }

                  if (option == 'eliminar') {
                    onDelete(
                      context,
                      routineExercise,
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
