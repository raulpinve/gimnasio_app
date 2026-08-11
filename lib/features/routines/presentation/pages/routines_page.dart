import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/components/my_appbar_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/routines/data/api_routine_repo.dart';
import 'package:gym_app/features/routines/domain/entities/routine.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_cubit.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_state.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_cubit.dart';
import 'package:shimmer/shimmer.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  final apiRoutineRepo = ApiRoutineRepo();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoutineCubit(
        routineRepo: apiRoutineRepo,
      )..loadRoutines(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Rutinas'),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              actions: [
                MyAppbarButton(
                  onPressed: () async {
                    final response = await context.push("/routines/create");

                    // Stop execution if the user navigated away while the page was open
                    if (!context.mounted) return;

                    if (response == true) {
                      context.read<RoutineCubit>().loadRoutines();
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
                    child: BlocBuilder<RoutineCubit, RoutineState>(
                      builder: (context, state) {
                        if (state is RoutineLoading) {
                          return skeletonLoader(context);
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

                                final routine = state.routines[index];

                                return tarjetaRutina(context, routine);
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

  GestureDetector tarjetaRutina(BuildContext context, Routine routine) {
    return GestureDetector(
      onTap: () async {
        final response = await context.push<bool>(
          '/routine-exercises',
          extra: routine,
        );
        // Stop execution is the user navigated away while the page was open
        if (!context.mounted) return;

        if (response == true) {
          context.read<RoutineExercisesCubit>().loadRoutineExercises(
            routineId: routine.id,
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary, // Fondo del listTile
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

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                routine.name,
                maxLines: 3,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 6.0, // Espacio horizontal entre cada pill
                runSpacing:
                    4.0, // Espacio vertical si los pills cambian de línea
                children: [
                  if (routine.exercises == null || routine.exercises!.isEmpty)
                    _crearPill(
                      "Sin ejercicios",
                      Colors.grey.shade100,
                      Colors.grey.shade800,
                    )
                  else ...[
                    ...routine.exercises!.take(1).map((
                      exercise,
                    ) {
                      return _crearPill(
                        exercise.name,
                        Colors.blue.shade100,
                        Colors.blue.shade800,
                      );
                    }),

                    if (routine.exercises!.length > 1)
                      _crearPill(
                        "+${routine.exercises!.length - 1}",
                        Colors.grey.shade100,
                        Colors.grey.shade800,
                      ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(
                      context,
                    ).colorScheme.error,
                    size: 18,
                  ),
                ),
                onPressed: () {
                  final routineCubit = context.read<RoutineCubit>();

                  _deleteRoutineBottomSheet(
                    context,
                    routine.id,
                    routineCubit,
                  );
                },
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
      itemCount: 6,
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

Future<dynamic> _deleteRoutineBottomSheet(
  BuildContext context,
  String id,
  RoutineCubit routineCubit,
) {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: routineCubit,
        child: BlocConsumer<RoutineCubit, RoutineState>(
          listener: (context, state) {
            if (state is RoutineDeleted) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            final isLoading = state is RoutineDeleting;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "¿Eliminar ejercicio?",
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
                            context.read<RoutineCubit>().deleteRoutine(
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

//  Función auxiliar para crear los pills rápidamente
Widget _crearPill(String texto, Color fondo, Color colorTexto) {
  final String textoCorto = texto.length > 25
      ? '${texto.substring(0, 25)}...'
      : texto;
  return Container(
    decoration: BoxDecoration(
      color: fondo,
      borderRadius: BorderRadius.circular(
        12.0,
      ), // El redondeado de las esquinas
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Text(
        textoCorto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: colorTexto,
        ),
      ),
    ),
  );
}
