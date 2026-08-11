import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/components/my_appbar_button.dart';
import 'package:gym_app/features/workouts/data/api_workout_repo.dart';
import 'package:gym_app/features/workouts/domain/entities/workout.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/workout_list/workout_state.dart';
import 'package:shimmer/shimmer.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});
  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  final apiWorkoutRepo = ApiWorkoutRepo();

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
                context.read<WorkoutCubit>().loadWorkouts();
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
              child: BlocBuilder<WorkoutCubit, WorkoutState>(
                builder: (context, state) {
                  if (state is WorkoutLoading) {
                    return skeletonLoader(context);
                  }

                  if (state is WorkoutError) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<WorkoutCubit>().loadWorkouts();
                      },
                      child: CustomScrollView(
                        slivers: [
                          SliverFillRemaining(
                            child: Center(
                              child: Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is WorkoutsLoaded) {
                    if (state.workouts.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await context.read<WorkoutCubit>().loadWorkouts();
                        },
                        child: CustomScrollView(
                          slivers: [
                            SliverFillRemaining(
                              child: Center(
                                child: Text('No hay rutinas'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<WorkoutCubit>().loadWorkouts();
                      },
                      child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 16);
                        },
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            state.workouts.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Botón "Cargar más"
                          if (index == state.workouts.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: state.isLoadingMore
                                      ? null
                                      : () {
                                          context
                                              .read<WorkoutCubit>()
                                              .loadMoreWorkouts();
                                        },
                                  icon: state.isLoadingMore
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.add),
                                  label: Text(
                                    state.isLoadingMore
                                        ? 'Cargando...'
                                        : 'Cargar más',
                                  ),
                                ),
                              ),
                            );
                          }

                          final workout = state.workouts[index];
                          return tarjetaRutina(context, workout);
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

  GestureDetector tarjetaRutina(BuildContext context, Workout workout) {
    return GestureDetector(
      onTap: () async {
        final response = await context.push<bool>(
          '/workouts/${workout.id}',
        );
        if (!context.mounted) return;

        if (response == true) {
          context.read<WorkoutCubit>().loadWorkouts();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.tertiary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.05,
              ),
              offset: const Offset(
                0,
                4,
              ),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workout.name,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: workout.estado == "abierto"
                          ? Colors.blue.shade100
                          : Colors.grey.shade100, // Tu color de fondo
                      borderRadius: BorderRadius.circular(
                        12.0,
                      ), // El redondeado de las esquinas
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
                        maxLines: 1,
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
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  if (workout.duracion != "") ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100, // Tu color de fondo
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ), // El redondeado de las esquinas
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          workout.duracion ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "•",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    workout.fecha ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
/*
Future<dynamic> _deleteWorkoutBottomSheet(
  BuildContext context,
  String id,
  WorkoutCubit workoutCubit,
) {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: workoutCubit,
        child: BlocConsumer<WorkoutCubit, WorkoutState>(
          listener: (context, state) {
            if (state is WorkoutDeleted) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            final isLoading = state is WorkoutDeleting;

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
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    "Esta opción no se puede deshacer.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
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
                          onTap: () {
                            context.read<WorkoutCubit>().deleteWorkout(
                              id,
                            );
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
*/