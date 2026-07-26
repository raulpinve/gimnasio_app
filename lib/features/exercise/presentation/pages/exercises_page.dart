import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/components/my_dropdown.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';
import 'package:gym_app/features/exercise/data/api_exercise_repo.dart';
import 'package:gym_app/features/exercise/presentation/constants/exercise_constants.dart';
import 'package:gym_app/features/exercise/presentation/cubits/exercise_cubit.dart';
import 'package:gym_app/features/exercise/presentation/cubits/exercise_state.dart';
import 'package:shimmer/shimmer.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final apiExerciseRepo = ApiExerciseRepo();
  final _buscarEjercicio = TextEditingController();

  String? selectedMusculo;

  final mapaMusculos = ExerciseConstants.opcionesGruposMusculares;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ExerciseCubit(exerciseRepo: apiExerciseRepo)..loadExercises(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ejercicios'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  return filtros(context);
                },
              ),
              SizedBox(
                height: 18,
              ),
              Expanded(
                child: BlocBuilder<ExerciseCubit, ExerciseState>(
                  builder: (context, state) {
                    if (state is ExerciseLoading) {
                      return skeletonLoader(context);
                    }

                    if (state is ExerciseError) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await context.read<ExerciseCubit>().loadExercises();
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

                    if (state is ExercisesLoaded) {
                      if (state.exercises.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            await context.read<ExerciseCubit>().loadExercises();
                          },
                          child: CustomScrollView(
                            slivers: [
                              SliverFillRemaining(
                                child: Center(
                                  child: Text('No hay ejercicios'),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await context.read<ExerciseCubit>().loadExercises();
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount:
                              state.exercises.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Botón "Cargar más"
                            if (index == state.exercises.length) {
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
                                                .read<ExerciseCubit>()
                                                .loadMoreExercises();
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
                            final exercise = state.exercises[index];

                            return GestureDetector(
                              onTap: () {
                                context.push('/exercises/${exercise.id}');
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
                                margin: EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 14,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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

                                      const SizedBox(width: 16),

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
                                            Wrap(
                                              spacing: 6.0,
                                              runSpacing: 4.0,
                                              children:
                                                  (exercise.muscleGroups ?? [])
                                                      .map((
                                                        musculo,
                                                      ) {
                                                        return _crearPill(
                                                          musculo,
                                                          Colors.blue.shade100,
                                                          Colors.blue.shade800,
                                                        );
                                                      })
                                                      .toList(),
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
                    return skeletonLoader(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearPill(String texto, Color fondo, Color colorTexto) {
    return Container(
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(
          12.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: Text(
          mapaMusculos[texto] ?? texto,
          maxLines: 2,
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

  Row filtros(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: MyTextfield(
            controller: _buscarEjercicio,
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
    );
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
            height: 76,
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

                // Texto
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        width: 120,
                        height: 12,
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
}
