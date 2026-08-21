import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/components/my_dropdown.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise.dart';

import 'package:gym_app/features/exercise/presentation/cubits/exercise_list_cubit.dart';
import 'package:gym_app/features/exercise/presentation/cubits/exercise_list_state.dart';
import 'package:shimmer/shimmer.dart';

class ExerciseSelectorPage extends StatefulWidget {
  const ExerciseSelectorPage({super.key});

  @override
  State<ExerciseSelectorPage> createState() => _ExerciseSelectorPageState();
}

class _ExerciseSelectorPageState extends State<ExerciseSelectorPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? selectedMusculo;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ExerciseListCubit>().loadMoreExercises();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget dropdown() {
    const opciones = [
      DropdownMenuItem(value: "", child: Text("Todos")),
      DropdownMenuItem(value: "pecho", child: Text("Pecho")),
      DropdownMenuItem(value: "espalda", child: Text("Espalda")),
      DropdownMenuItem(value: "lumbares", child: Text("Lumbares")),
      DropdownMenuItem(value: "hombros", child: Text("Hombros")),
      DropdownMenuItem(value: "biceps", child: Text("Biceps")),
      DropdownMenuItem(value: "triceps", child: Text("Triceps")),
      DropdownMenuItem(value: "antebrazos", child: Text("Antebrazos")),
      DropdownMenuItem(value: "cuadriceps", child: Text("Cuadriceps")),
      DropdownMenuItem(value: "isquios", child: Text("Isquios")),
      DropdownMenuItem(value: "gluteos", child: Text("Gluteos")),
      DropdownMenuItem(value: "gemelos", child: Text("Gémelos")),
      DropdownMenuItem(value: "aductores", child: Text("Aductores")),
      DropdownMenuItem(value: "abs", child: Text("Abdominales")),
      DropdownMenuItem(value: "cardio", child: Text("Cardio")),
      DropdownMenuItem(value: "full_body", child: Text("Cuerpo completo")),
    ];

    return Builder(
      builder: (context) {
        return MyDropdown<String>(
          value: selectedMusculo,
          hintText: 'Músculo',
          items: opciones,
          onChanged: (value) {
            selectedMusculo = value;
            context.read<ExerciseListCubit>().filterByMuscleGroup(
              selectedMusculo ?? "",
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar ejercicio'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop(); // Ahora sí regresa correctamente atrás sin bucles
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // BUSCADOR
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: MyTextfield(
                    controller: _searchController,
                    hintText: "Buscar ejercicio...",
                    obscureText: false,
                    onChanged: (value) {
                      context.read<ExerciseListCubit>().searchExercises(value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: dropdown(),
                ),
              ],
            ),

            SizedBox(
              height: 12,
            ),

            // LISTA
            Expanded(
              child: BlocBuilder<ExerciseListCubit, ExerciseListState>(
                builder: (context, state) {
                  if (state is ExerciseLoading) {
                    return skeletonLoader(context);
                  }

                  if (state is ExerciseError) {
                    return Center(
                      child: Text(state.message),
                    );
                  }

                  if (state is ExercisesLoaded) {
                    if (state.exercises.isEmpty) {
                      return const Center(
                        child: Text(
                          'No se encontraron ejercicios',
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<ExerciseListCubit>().loadExercises();
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        itemCount:
                            state.exercises.length +
                            (state.isLoadingMore ? 1 : 0),
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          if (index >= state.exercises.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final exercise = state.exercises[index];
                          final theme = Theme.of(context);
                          final colorScheme = theme.colorScheme;

                          return GestureDetector(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop(exercise);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                14,
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
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: exercise.avatar?.isNotEmpty == true
                                        ? Image.network(
                                            exercise.avatar!,
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) {
                                              return _buildExercisePlaceholder(
                                                context,
                                                exercise,
                                              );
                                            },
                                          )
                                        : _buildExercisePlaceholder(
                                            context,
                                            exercise,
                                          ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),

                                        const SizedBox(height: 8),

                                        Row(
                                          children: [
                                            Icon(
                                              exercise.type == 'cardio'
                                                  ? Icons
                                                        .directions_run_outlined
                                                  : Icons
                                                        .fitness_center_outlined,
                                              size: 15,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              exercise.type == 'strength'
                                                  ? 'Fuerza'
                                                  : 'Cardio',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
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

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildExercisePlaceholder(
  BuildContext context,
  Exercise exercise,
) {
  final colorScheme = Theme.of(context).colorScheme;

  return Container(
    width: 64,
    height: 64,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(
      exercise.type == 'cardio'
          ? Icons.directions_run_outlined
          : Icons.fitness_center_outlined,
      color: colorScheme.onSurfaceVariant,
      size: 26,
    ),
  );
}

Widget skeletonLoader(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Shimmer.fromColors(
    baseColor: isDark
        ? const Color.fromARGB(255, 55, 55, 55)
        : Colors.grey.shade300,
    highlightColor: isDark
        ? const Color.fromARGB(255, 80, 80, 80)
        : Colors.grey.shade100,
    child: ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              const SizedBox(width: 16),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del ejercicio
                    Container(
                      width: double.infinity,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tipo de ejercicio
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
