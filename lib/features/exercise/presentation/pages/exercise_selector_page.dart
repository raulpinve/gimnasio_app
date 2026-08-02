import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/components/my_dropdown.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';

import 'package:gym_app/features/exercise/presentation/cubits/exercise_cubit.dart';
import 'package:gym_app/features/exercise/presentation/cubits/exercise_state.dart';
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
      context.read<ExerciseCubit>().loadMoreExercises();
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
            context.read<ExerciseCubit>().filterByMuscleGroup(
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
                      context.read<ExerciseCubit>().searchExercises(value);
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
              child: BlocBuilder<ExerciseCubit, ExerciseState>(
                builder: (context, state) {
                  // CARGA INICIAL
                  if (state is ExerciseLoading) {
                    return skeletonLoader(context);
                  }

                  // ERROR
                  if (state is ExerciseError) {
                    return Center(
                      child: Text(state.message),
                    );
                  }

                  // EJERCICIOS CARGADOS
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
                        await context.read<ExerciseCubit>().loadExercises();
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        itemCount:
                            state.exercises.length +
                            (state.isLoadingMore ? 1 : 0),
                        separatorBuilder: (context, index) => SizedBox(
                          height: 12,
                        ),

                        itemBuilder: (context, index) {
                          // LOADING DE PAGINACIÓN
                          if (index >= state.exercises.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          // EJERCICIO
                          final exercise = state.exercises[index];
                          return GestureDetector(
                            onTap: () {
                              // Devolvemos el ejercicio
                              if (context.canPop()) {
                                context.pop(exercise);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : const Color.fromARGB(255, 35, 35, 35),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.05,
                                    ),
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 14,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        8.0,
                                      ),
                                      child:
                                          exercise.avatar != null &&
                                              exercise.avatar!.isNotEmpty
                                          ? Image.network(
                                              exercise.avatar!,
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
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.tertiary,
                                              child: exercise.type == "cardio"
                                                  ? const Icon(
                                                      Icons
                                                          .directions_run_outlined,
                                                    )
                                                  : const Icon(
                                                      Icons
                                                          .fitness_center_outlined,
                                                    ),
                                            ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exercise.name,
                                            maxLines: 3,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            exercise.type == "strength"
                                                ? "Fuerza"
                                                : "Cardio",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  // ESTADO INICIAL
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
