import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/routines/domain/entities/routine.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_cubit.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_state.dart';
import 'package:gym_app/features/workouts/presentation/cubits/create_workout/workout_create_cubit.dart';
import 'package:gym_app/features/workouts/presentation/cubits/create_workout/workout_create_state.dart';

class WorkoutsCreatePage extends StatefulWidget {
  const WorkoutsCreatePage({super.key});

  @override
  State<WorkoutsCreatePage> createState() => _WorkoutsCreatePageState();
}

class _WorkoutsCreatePageState extends State<WorkoutsCreatePage> {
  String? _selectedRoutineId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutCreateCubit, WorkoutCreateState>(
      listener: (context, state) {
        if (state.isCreated && state.workoutId != null) {
          context.push(
            "/workouts/${state.workoutId}",
          );
        }

        if (state.errorMessage != null) {
          if (state.fieldErrors == null || state.fieldErrors!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final isCreating = state.isCreating;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: isCreating
                  ? null
                  : () {
                      if (context.canPop()) {
                        context.pop();
                      }
                    },
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "¿Qué quieres entrenar hoy?",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Selecciona una rutina para empezar:",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: BlocBuilder<RoutineCubit, RoutineState>(
                      builder: (context, state) {
                        if (state is RoutineLoading) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is RoutineError) {
                          return RefreshIndicator(
                            onRefresh: () async {
                              await context.read<RoutineCubit>().loadRoutines();
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

                        if (state is RoutinesLoaded) {
                          if (state.routines.isEmpty) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                await context
                                    .read<RoutineCubit>()
                                    .loadRoutines();
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
                          final colorScheme = Theme.of(context).colorScheme;

                          return RefreshIndicator(
                            onRefresh: () async {
                              await context.read<RoutineCubit>().loadRoutines();
                            },
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount:
                                  state.routines.length +
                                  (state.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Botón "Cargar más"
                                if (index == state.routines.length) {
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
                                                    .read<RoutineCubit>()
                                                    .loadMoreRoutines();
                                              },
                                        icon: state.isLoadingMore
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
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

                                final rutina = state.routines[index];
                                final isSelected =
                                    _selectedRoutineId == rutina.id;

                                final activeColor =
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.blue
                                    : Colors.blue.shade900;

                                return card(
                                  context,
                                  isSelected,
                                  activeColor,
                                  isCreating,
                                  index,
                                  rutina,
                                  colorScheme,
                                );
                              },
                            ),
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón Dinámico de Siguiente
                  buttonCreate(isCreating, context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SizedBox buttonCreate(
    bool isCreating,
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (_selectedRoutineId == null || isCreating)
            ? null
            : () {
                context.read<WorkoutCreateCubit>().createWorkout({
                  "routineId": _selectedRoutineId,
                });
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedRoutineId != null
              ? Theme.of(context).brightness == Brightness.light
                    ? Colors.blue
                    : Colors.blue.shade900
              : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isCreating
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Siguiente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Card card(
    BuildContext context,
    bool isSelected,
    Color activeColor,
    bool isCreating,
    int index,
    Routine rutina,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: Theme.of(context).brightness == Brightness.light
          ? isSelected
                ? 2
                : 1
          : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? activeColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isCreating
            ? null
            : () {
                setState(() {
                  _selectedRoutineId = rutina.id;
                });
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rutina.name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),

                    if (rutina.exercises != null &&
                        rutina.exercises!.isNotEmpty) ...[
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: rutina.exercises!
                            .map(
                              (
                                exercise,
                              ) => pills(
                                context,
                                colorScheme,
                                exercise,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? activeColor : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container pills(
    BuildContext context,
    ColorScheme colorScheme,
    ExerciseRoutine exercise,
  ) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 150,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(
                  context,
                ).brightness ==
                Brightness.light
            ? Colors.blue.shade200
            : colorScheme.primary,
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        exercise.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color:
              Theme.of(
                    context,
                  ).brightness ==
                  Brightness.light
              ? Colors.blue.shade900
              : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
