import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/components/my_appbar_button.dart';
import 'package:gym_app/features/routines/domain/entities/routine.dart';
import 'package:gym_app/features/routines_exercises/data/api_routine_exercise_repo.dart';
import 'package:gym_app/features/routines_exercises/domain/entities/routine_exercise.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_cubit.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_state.dart';

class RoutineExercisesPage extends StatefulWidget {
  final Routine routine;

  const RoutineExercisesPage({
    super.key,
    required this.routine,
  });

  @override
  State<RoutineExercisesPage> createState() => _RoutineExercisesPageState();
}

class _RoutineExercisesPageState extends State<RoutineExercisesPage> {
  final apiRoutineExerciseRepo = ApiRoutineExerciseRepo();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RoutineExercisesCubit(routineExerciseRepo: apiRoutineExerciseRepo)
            ..loadRoutineExercises(routineId: widget.routine.id),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.routine.name),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              actions: [
                MyAppbarButton(
                  onPressed: () async {
                    final response = await context.push<bool>(
                      "/routine-exercises/${widget.routine.id}/create",
                      extra: widget.routine,
                    );

                    // Stop execution is the user navigated away while the page was open
                    if (!context.mounted) return;

                    if (response == true) {
                      context
                          .read<RoutineExercisesCubit>()
                          .loadRoutineExercises(routineId: widget.routine.id);
                    }
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child:
                        BlocBuilder<
                          RoutineExercisesCubit,
                          RoutineExercisesState
                        >(
                          builder: (context, state) {
                            if (state is RoutineExercisesLoading) {
                              return skeletonLoader(context);
                            }

                            if (state is RoutineExercisesError) {
                              return RefreshIndicator(
                                onRefresh: () async {
                                  await context
                                      .read<RoutineExercisesCubit>()
                                      .loadRoutineExercises(
                                        routineId: widget.routine.id,
                                      );
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

                            if (state is RoutineExercisesLoaded) {
                              if (state.routineExercises.isEmpty) {
                                return RefreshIndicator(
                                  onRefresh: () async {
                                    await context
                                        .read<RoutineExercisesCubit>()
                                        .loadRoutineExercises(
                                          routineId: widget.routine.id,
                                        );
                                  },
                                  child: CustomScrollView(
                                    slivers: [
                                      SliverFillRemaining(
                                        child: Center(
                                          child: Text(
                                            "No hay ejercicios para esta rutina",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return RefreshIndicator(
                                onRefresh: () async {
                                  await context
                                      .read<RoutineExercisesCubit>()
                                      .loadRoutineExercises(
                                        routineId: widget.routine.id,
                                      );
                                },
                                child: ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemCount: state.routineExercises.length,
                                  itemBuilder: (context, index) {
                                    final exercise =
                                        state.routineExercises[index];

                                    return tarjetasExercises(exercise, context);
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
        },
      ),
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
) {
  final details = <String>[
    if (routineExercise.targetSets != null)
      "Ser: ${routineExercise.targetSets}",

    if (routineExercise.targetReps != null)
      "Rep: ${routineExercise.targetReps}",

    if (routineExercise.targetWeight != null)
      "P: ${routineExercise.targetWeight} kg",

    if (routineExercise.targetDurationSeconds != null)
      "Dur: ${routineExercise.targetDurationSeconds} s",

    if (routineExercise.targetDistanceKm != null)
      "Dist: ${routineExercise.targetDistanceKm} km",
  ];

  Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [
      for (int i = 0; i < details.length; i++) ...[
        Text(
          details[i],
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        if (i < details.length - 1)
          const Text(
            "•",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
      ],
    ],
  );

  return GestureDetector(
    onTap: () {
      context.push("/exercises/${routineExercise.exerciseId}");
    },
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color.fromARGB(
                255,
                35,
                35,
                35,
              ), // Fondo del listTile
        borderRadius: BorderRadius.circular(
          12,
        ), // Esquinas redondeadas

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ), // Color de la sombra
            offset: const Offset(
              0,
              4,
            ), // Dirección de la sombra (X, Y)
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14.0, // Reduce el espacio a los lados
          vertical: 5.0, // Reduce el espacio arriba y abajo
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child:
              routineExercise.avatar != null &&
                  routineExercise.avatar!.isNotEmpty
              ? Image.network(
                  routineExercise.avatar!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return const Icon(
                      Icons.image_not_supported,
                    );
                  },
                )
              : Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  color: Colors.grey.shade200,
                  child: routineExercise.exerciseType == "cardio"
                      ? const Icon(Icons.directions_run)
                      : const Icon(
                          Icons.fitness_center,
                        ),
                ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              routineExercise.exerciseName!,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (int i = 0; i < details.length; i++) ...[
                  Text(
                    details[i],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (i < details.length - 1)
                    const Text(
                      "•",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),

          color: Theme.of(context).colorScheme.surface,

          onSelected: (String opcion) {
            if (opcion == 'editar') {
              _redirigirAEditar(
                context,
                routineExercise.id,
              );
            } else if (opcion == 'eliminar') {
              _mostrarBottomSheetEliminar(
                context,
                routineExercise.id,
              );
            }
          },

          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'editar',
              child: Text(
                'Editar',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            PopupMenuItem<String>(
              value: 'eliminar',
              child: Text(
                'Eliminar',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// 1. Redirección a la pantalla de edición
void _redirigirAEditar(BuildContext context, String exerciseId) async {
  // final resultado = await context.push(
  //   '/routine-exercises/$exerciseId/update',
  // );
  // if (resultado == true) {
  //   _cargarEjercicios();
  // }
}

// 2. Despliegue del Bottom Sheet para eliminar
void _mostrarBottomSheetEliminar(BuildContext context, String id) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (bc) {
      bool isLoading = false;

      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Confirmas que deseas eliminar este ejercicio?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: Colors.grey.shade700,
                          side: const BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Expanded(
                    //   child: ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.red.shade400,
                    //       foregroundColor: Colors.white,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //     ),
                    //     onPressed: () {
                    //       // setModalState(() {
                    //       //   isLoading = true;
                    //       // });
                    //       // _deleteExercise(context, id);
                    //     },
                    //     child: isLoading
                    //         ? const SizedBox(
                    //             width: 20,
                    //             height: 20,
                    //             child: CircularProgressIndicator(
                    //               strokeWidth: 2,
                    //               color: Colors.white,
                    //             ),
                    //           )
                    //         : Text("Eliminar"),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
