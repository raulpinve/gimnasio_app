import 'package:gym_app/core/widgets/refreshable_content.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_list_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_list_state.dart';
import 'package:gym_app/features/auth/presentation/components/my_appbar_button.dart';
import 'package:gym_app/features/workouts/domain/entities/workout.dart';
import 'package:gym_app/features/workouts/data/api_workout_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WorkoutsListPage extends StatefulWidget {
  const WorkoutsListPage({super.key});
  @override
  State<WorkoutsListPage> createState() => _WorkoutsListPageState();
}

class _WorkoutsListPageState extends State<WorkoutsListPage> {
  final apiWorkoutRepo = ApiWorkoutRepo();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<WorkoutListCubit>().loadMoreWorkouts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<WorkoutListCubit>().loadWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          MyAppbarButton(
            onPressed: () async {
              final response = await context.push("/workouts/create");

              // Stop execution if the user navigated away while the page was open
              if (!context.mounted) return;

              if (response == true) {
                context.read<WorkoutListCubit>().loadWorkouts();
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
            Expanded(
              child: BlocBuilder<WorkoutListCubit, WorkoutListState>(
                builder: (context, state) {
                  // CARGA INICIAL
                  if (state is WorkoutListLoading) {
                    return skeletonLoader(context);
                  }

                  // ERROR
                  if (state is WorkoutListError) {
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: Text(state.message),
                    );
                  }

                  // ENTRENAMIENTOS CARGADOS
                  if (state is WorkoutsListLoaded) {
                    if (state.workouts.isEmpty) {
                      return RefreshableContent(
                        onRefresh: _onRefresh,
                        child: Text(
                          'No se encontraron entrenamientos',
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView.separated(
                        controller: _scrollController,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 16);
                        },
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            state.workouts.length +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          // LOADING DE PAGINACIÓN
                          if (index >= state.workouts.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final workout = state.workouts[index];
                          return workoutCard(context, workout);
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

  GestureDetector workoutCard(BuildContext context, Workout workout) {
    return GestureDetector(
      onTap: () async {
        final response = await context.push<bool>(
          '/workouts-exercises/${workout.id}',
        );

        if (!context.mounted) return;

        if (response == true) {
          context.read<WorkoutListCubit>().loadWorkouts();
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          16,
          14,
          8,
          14,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre + menú
            Row(
              children: [
                Expanded(
                  child: Text(
                    workout.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_vert,
                    size: 22,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        // Editar workout
                        break;

                      case 'delete':
                        // Eliminar workout
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () {
                        _deleteWorkoutBottomSheet(context, workout.id);
                      },
                      value: 'delete',
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

            // Estado
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: workout.estado == 'abierto'
                    ? Colors.blue.shade100
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                workout.estado == 'abierto' ? 'En progreso' : 'Finalizado',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: workout.estado == 'abierto'
                      ? Colors.blue.shade800
                      : Colors.grey.shade800,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Duración + fecha
            Row(
              children: [
                if (workout.duracion != null &&
                    workout.duracion!.isNotEmpty) ...[
                  Icon(
                    Icons.timer_outlined,
                    size: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    workout.duracion!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '•',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                Text(
                  workout.fecha ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget skeletonLoader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: 10,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? const Color(0xFF232323) : Colors.grey.shade200,
          highlightColor: isDark
              ? const Color(0xFF353535)
              : Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF232323) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de la rutina
                  Container(
                    width: double.infinity,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Pills
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      const SizedBox(width: 6),

                      Container(
                        width: 45,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Botón de eliminar
              trailing: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<dynamic> _deleteWorkoutBottomSheet(
  BuildContext context,
  String id,
) {
  final workoutCubit = context.read<WorkoutListCubit>();

  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: workoutCubit,
        child: BlocBuilder<WorkoutListCubit, WorkoutListState>(
          builder: (context, state) {
            final isLoading = state is WorkoutsListLoaded && state.isDeleting;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "¿Eliminar entrenamiento?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Esta opción no se puede deshacer.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: MyButton(
                          onTap: isLoading
                              ? null
                              : () => Navigator.pop(context),
                          text: "Cancelar",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MyButton(
                          onTap: isLoading
                              ? null
                              : () async {
                                  final deleted = await context
                                      .read<WorkoutListCubit>()
                                      .deleteWorkout(id);

                                  if (deleted && context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                          type: MyButtonType.danger,
                          isLoading: isLoading,
                          text: "Eliminar",
                        ),
                      ),
                    ],
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
