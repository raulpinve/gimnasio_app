import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/widgets/refreshable_content.dart';
import 'package:gym_app/features/auth/presentation/components/my_appbar_button.dart';
import 'package:gym_app/features/routines/data/api_routine_repo.dart';
import 'package:gym_app/features/routines/domain/entities/routine.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_cubit.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_state.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_list/routine_exercises_list_cubit.dart';
import 'package:shimmer/shimmer.dart';

class RoutineListPage extends StatefulWidget {
  const RoutineListPage({super.key});

  @override
  State<RoutineListPage> createState() => _RoutineListPageState();
}

class _RoutineListPageState extends State<RoutineListPage> {
  final apiRoutineRepo = ApiRoutineRepo();

  Future<void> _onRefresh() async {
    await context.read<RoutineListCubit>().loadRoutines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          MyAppbarButton(
            onPressed: () async {
              final response = await context.push("/routines/create");

              // Stop execution if the user navigated away while the page was open
              if (!context.mounted) return;

              if (response == true) {
                context.read<RoutineListCubit>().loadRoutines();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rutina creada correctamente'),
                  ),
                );
              }
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mis rutinas",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 24,
            ),
            Expanded(
              child: BlocBuilder<RoutineListCubit, RoutineListState>(
                builder: (context, state) {
                  // CARGA INICIAL
                  if (state is RoutineListLoading) {
                    return skeletonLoader(context);
                  }

                  // ERROR
                  if (state is RoutineListError) {
                    return RefreshableContent(
                      onRefresh: _onRefresh,
                      child: Text(state.message),
                    );
                  }

                  // RUTINAS CARGADAS
                  if (state is RoutinesListLoaded) {
                    if (state.routines.isEmpty) {
                      return RefreshableContent(
                        onRefresh: _onRefresh,
                        child: Text("No hay rutinas por mostrar"),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            state.routines.length +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          // LOADING DE PAGINACIÓN
                          if (index >= state.routines.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final routine = state.routines[index];
                          return routineCard(context, routine);
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

  Widget routineCard(
    BuildContext context,
    Routine routine,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final exercises = routine.exercises ?? [];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final response = await context.push<bool>(
            '/routine-exercises/${routine.id}',
          );

          if (!context.mounted) return;

          if (response == true) {
            context.read<RoutineExercisesListCubit>().loadRoutineExercises(
              routine.id,
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            12,
            16,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          exercises.isEmpty
                              ? 'Sin ejercicios'
                              : '${exercises.length} ${exercises.length == 1 ? 'ejercicio' : 'ejercicios'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

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
                      onSelected: (value) {
                        switch (value) {
                          case 'delete':
                            _confirmDeleteWorkout(
                              context,
                              routine,
                            );
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'delete',
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

              if (exercises.isNotEmpty) ...[
                const SizedBox(height: 16),

                Text(
                  exercises
                      .take(3)
                      .map((exercise) => exercise.name)
                      .join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),

                if (exercises.length > 3) ...[
                  const SizedBox(height: 4),

                  Text(
                    '+${exercises.length - 3} más',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ],
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

Future<void> _confirmDeleteWorkout(
  BuildContext context,
  Routine routine,
) async {
  final cubit = context.read<RoutineListCubit>();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      bool isDeleting = false;
      String? errorMessage;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Eliminar rutina'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Seguro que deseas eliminar "${routine.name}"?',
                ),

                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
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

                        final deleted = await cubit.deleteRoutine(
                          routine.id,
                        );

                        if (!dialogContext.mounted) return;

                        if (deleted) {
                          Navigator.of(dialogContext).pop();
                        } else {
                          final state = cubit.state;

                          setState(() {
                            isDeleting = false;
                            errorMessage = state is RoutinesListLoaded
                                ? state.errorMessage ??
                                      'No se pudo eliminar la rutina.'
                                : 'No se pudo eliminar la rutina.';
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
