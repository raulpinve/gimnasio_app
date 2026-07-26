import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/exercise/data/api_exercise_repo.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise_progress.dart';
import 'package:gym_app/features/exercise/presentation/constants/exercise_constants.dart';
import 'package:gym_app/features/exercise/presentation/cubits/exercise_detail_cubit.dart';
import 'package:gym_app/features/exercise/presentation/cubits/exercise_detail_state.dart';

class ExerciseDetailPage extends StatelessWidget {
  final String exerciseId;

  const ExerciseDetailPage({
    super.key,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    final apiExerciseRepo = ApiExerciseRepo();

    return BlocProvider(
      create: (context) => ExerciseDetailCubit(
        exerciseRepo: apiExerciseRepo,
      )..loadExerciseDetail(exerciseId),
      child: const _ExerciseDetailView(),
    );
  }
}

class _ExerciseDetailView extends StatelessWidget {
  const _ExerciseDetailView();

  @override
  Widget build(BuildContext context) {
    double anchoPantalla = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: BlocBuilder<ExerciseDetailCubit, ExerciseDetailState>(
        builder: (context, state) {
          if (state is ExerciseDetailLoading ||
              state is ExerciseDetailInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ExerciseDetailError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            );
          }

          if (state is ExerciseDetailLoaded) {
            final exercise = state.exercise;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      22,
                    ),
                    child: SizedBox(
                      width: anchoPantalla,
                      height: 300,
                      child:
                          (exercise.avatar != null &&
                              exercise.avatar!.isNotEmpty)
                          ? Image.network(
                              exercise.avatar!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (
                                    BuildContext context,
                                    Object error,
                                    StackTrace? stackTrace,
                                  ) {
                                    debugPrint(
                                      'Error cargando la imagen: $error',
                                    );

                                    if (stackTrace != null) {
                                      debugPrint(stackTrace.toString());
                                    }

                                    return const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                    );
                                  },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                              ),
                              width: double.infinity,
                              height: double.infinity,
                              alignment: Alignment.center,
                              child: exercise.type == "cardio"
                                  ? const Icon(
                                      Icons.directions_run,
                                      size: 70,
                                    )
                                  : const Icon(
                                      Icons.fitness_center,
                                      size: 70,
                                    ),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    exercise.name,
                    style: TextTheme.of(context).headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  especificaciones(context, exercise),
                  SizedBox(
                    height: 20,
                  ),

                  grafica(
                    progress: state.progress,
                    unit: state.unit,
                  ),
                  indicaciones(context, exercise),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget grafica({
    required List<ExerciseProgress> progress,
    required String unit,
  }) {
    if (progress.length < 2) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.0,
            ),
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(22)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "GRÁFICA DE PROGRESO",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    // 🌟 CORREGIDO: Muestra dinámicamente Kg o Lbs según tu variable unit
                    Text(
                      unit.toLowerCase() == 'lb' ? "Lbs" : "Kg",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      // 🌟 1. FIJAR LÍMITES EN EL EJE Y PARA EVITAR EL DESORDEN
                      // Buscamos el valor más alto en tus datos para darle un tope a la gráfica
                      minY: 0,
                      maxY: progress.isEmpty
                          ? 30
                          : (progress
                                        .map((e) => e.value)
                                        .reduce((a, b) => a > b ? a : b) +
                                    5)
                                .roundToDouble(),

                      // Fijamos también el eje X como lo vimos antes
                      minX: 0,
                      maxX: progress.isEmpty
                          ? 1
                          : (progress.length - 1).toDouble(),

                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= progress.length)
                                return SizedBox.shrink();
                              if (index > 0 &&
                                  progress[index].date ==
                                      progress[index - 1].date) {
                                return SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                meta: meta,
                                space: 8,
                                child: Text(
                                  progress[index].date,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // 🌟 2. EL CAMBIO EN EL EJE IZQUIERDO (Y)
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            // Ajusta este intervalo: '5' significa que pintará 0, 5, 10, 15, 20...
                            // Si tus pesos son muy altos (ej. más de 100kg), cámbialo por '10' o '20'
                            interval: 5,
                            getTitlesWidget: (value, meta) {
                              // Evitamos pintar números negativos innecesarios
                              if (value < 0) return const SizedBox();

                              return SideTitleWidget(
                                meta: meta,
                                space: 8,
                                child: Text(
                                  value.toStringAsFixed(
                                    0,
                                  ), // Elimina los decimales (.0) para que no ocupen espacio
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        border: const Border(
                          left: BorderSide(color: Colors.grey),
                          bottom: BorderSide(color: Colors.grey),
                          top: BorderSide.none,
                          right: BorderSide.none,
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: progress
                              .asMap()
                              .entries
                              .map(
                                (entry) => FlSpot(
                                  entry.key.toDouble(),
                                  entry.value.value,
                                ),
                              )
                              .toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 4,
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }

  // Especificaciones
  Widget especificaciones(BuildContext context, Exercise exercise) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.0,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(22)),
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
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ESPECIFICACIONES",
              style:
                  TextTheme.of(
                    context,
                  ).bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- TARJETA 1: TIPO ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withValues(
                      alpha: 0.4,
                    ), // Bloque de color pastel muy limpio y plano
                    borderRadius: const BorderRadius.all(
                      Radius.circular(16),
                    ), // Esquinas redondeadas modernas
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      // Usamos Row principal para aprovechar mejor el espacio horizontal
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors
                                .white, // El icono resalta sobre un círculo blanco limpio
                            shape: BoxShape.circle,
                          ),
                          child: exercise.type == "strength"
                              ? const Icon(
                                  Icons.fitness_center_rounded,
                                  size: 24,
                                  color: Colors.blue,
                                )
                              : const Icon(
                                  Icons.directions_run_rounded,
                                  size: 24,
                                  color: Colors.blue,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TIPO",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: Colors
                                    .blue
                                    .shade700, // Texto a juego con el bloque
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Fuerza",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12), // Separación limpia entre bloques
                // --- TARJETA 2: EQUIPO ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors
                        .grey
                        .shade100, // Bloque gris neutro y plano para contrastar
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.sports_gymnastics_rounded,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "EQUIPO",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: Colors.grey.shade600,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ExerciseConstants.opcionesEquipos[exercise
                                      .equipment] ??
                                  "Sin equipo",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade100,
                  width: 1.0,
                ),
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade50,
                  ),
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.all(
                    Radius.circular(22),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GRUPOS MUSCULARES",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8.0,
                        children: (exercise.muscleGroups ?? []).map((muscle) {
                          final nombreMusculo =
                              ExerciseConstants
                                  .opcionesGruposMusculares[muscle] ??
                              muscle;

                          return Chip(
                            label: Text(
                              nombreMusculo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget indicaciones(BuildContext context, Exercise exercise) {
    final description = exercise.description;

    if (description == null ||
        (description.positionInicial.isEmpty &&
            description.ejecucion.isEmpty &&
            description.tipsExtra.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.0,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(22)),
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
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((exercise.description?.positionInicial ?? '').isNotEmpty) ...[
              Text(
                "Posición inicial",
                style: TextTheme.of(
                  context,
                ).bodyLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(exercise.description!.positionInicial),
              const SizedBox(
                height: 14,
              ),
            ],

            if ((exercise.description?.ejecucion ?? '').isNotEmpty) ...[
              Text(
                "Ejecución",
                style: TextTheme.of(
                  context,
                ).bodyLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(exercise.description!.ejecucion),
              const SizedBox(
                height: 14,
              ),
            ],

            if ((exercise.description?.tipsExtra ?? '').isNotEmpty) ...[
              Text(
                "Tips extras",
                style: TextTheme.of(
                  context,
                ).bodyLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(exercise.description!.tipsExtra),
            ],
          ],
        ),
      ),
    );
  }
}
