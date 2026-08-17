import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/extensions/string_extensions.dart';
import 'package:gym_app/core/widgets/refreshable_content.dart';
import 'package:gym_app/features/auth/presentation/components/my_dropdown.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';
import 'package:gym_app/features/exercise/data/api_exercise_repo.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:gym_app/features/exercise/presentation/constants/exercise_constants.dart';
import 'package:gym_app/features/exercise/presentation/cubits/exercise_list_cubit.dart';
import 'package:gym_app/features/exercise/presentation/cubits/exercise_list_state.dart';
import 'package:shimmer/shimmer.dart';

class ExercisesListPage extends StatefulWidget {
  const ExercisesListPage({super.key});

  @override
  State<ExercisesListPage> createState() => _ExercisesListPageState();
}

class _ExercisesListPageState extends State<ExercisesListPage> {
  final apiExerciseRepo = ApiExerciseRepo();
  final _buscarEjercicio = TextEditingController();
  String? selectedMusculo;

  final ScrollController _scrollController = ScrollController();
  final mapaMusculos = ExerciseConstants.opcionesGruposMusculares;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // context.read<ExerciseCubit>().loadMoreExercises();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ExerciseListCubit>().loadMoreExercises();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<ExerciseListCubit>().loadExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: BlocBuilder<ExerciseListCubit, ExerciseListState>(
                builder: (context, state) {
                  // CARGA INICIAL
                  if (state is ExerciseLoading) {
                    return skeletonLoader(context);
                  }

                  // ERROR
                  if (state is ExerciseError) {
                    return RefreshableContent(
                      onRefresh: _onRefresh,
                      child: Text(state.message),
                    );
                  }

                  // ENTRENAMIENTOS CARGADOS
                  if (state is ExercisesLoaded) {
                    // NO HAY EJERCICIOS
                    if (state.exercises.isEmpty) {
                      return RefreshableContent(
                        onRefresh: _onRefresh,
                        child: Text("No hay ejercicios"),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            state.exercises.length + (state.hasMore ? 1 : 0),
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
                          final exercise = state.exercises[index];

                          return _buildExerciseCard(context, exercise);
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

  Widget _buildExerciseCard(
    BuildContext context,
    Exercise exercise,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        context.push('/exercises/${exercise.id}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildExerciseImage(context, exercise),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    exercise.equipment.capitalize(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  if (exercise.muscleGroups?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 7),
                    Text(
                      exercise.muscleGroups!
                          .take(2)
                          .map((e) => mapaMusculos[e] ?? e)
                          .join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseImage(
    BuildContext context,
    Exercise exercise,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: exercise.avatarThumbnail?.isNotEmpty == true
          ? Image.network(
              exercise.avatarThumbnail!,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return _buildExercisePlaceholder(context, exercise);
              },
            )
          : _buildExercisePlaceholder(context, exercise),
    );
  }

  Widget _buildExercisePlaceholder(
    BuildContext context,
    Exercise exercise,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 64,
      height: 64,
      color: colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: Icon(
        exercise.type == 'cardio'
            ? Icons.directions_run_outlined
            : Icons.fitness_center_outlined,
        color: colorScheme.onPrimaryContainer,
        size: 28,
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
              context.read<ExerciseListCubit>().searchExercises(value);
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
            context.read<ExerciseListCubit>().filterByMuscleGroup(
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
