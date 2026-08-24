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
import 'package:gym_app/features/exercise/presentation/widgets/Exercise_thumbnail.dart';

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
      body: SafeArea(
        child: BlocBuilder<ExerciseDetailCubit, ExerciseDetailState>(
          builder: (context, state) {
            // LOADING EXERCISES
            if (state is ExerciseDetailLoading ||
                state is ExerciseDetailInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            // SHOW EXERCISE ERROR
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

            // EXERCISE LOADED
            if (state is ExerciseDetailLoaded) {
              final exercise = state.exercise;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ExerciseThumbnail(
                        name: exercise.name,
                        imageUrl: exercise.avatar,
                        size: 200,
                      ),
                    ),
                    SizedBox(
                      height: 28,
                    ),
                    Text(
                      exercise.name,
                      style:
                          Theme.of(
                            context,
                          ).textTheme.headlineSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(
                      height: 28,
                    ),
                    _especificaciones(context, exercise),
                    SizedBox(
                      height: 20,
                    ),

                    grafica(
                      context: context,
                      progress: state.progress,
                      unit: state.unit,
                    ),

                    _indicaciones(context, exercise),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildExerciseHero(
    BuildContext context,
    Exercise exercise,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: exercise.avatar?.isNotEmpty == true
                ? Image.network(
                    exercise.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          exercise.type == 'cardio'
                              ? Icons.directions_run_rounded
                              : Icons.fitness_center_rounded,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  )
                : Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      exercise.type == 'cardio'
                          ? Icons.directions_run_rounded
                          : Icons.fitness_center_rounded,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          exercise.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          [
            ExerciseConstants.opcionesEquipos[exercise.equipment] ??
                'Sin equipo',
            ...(exercise.muscleGroups ?? [])
                .take(3)
                .map(
                  (muscle) =>
                      ExerciseConstants.opcionesGruposMusculares[muscle] ??
                      muscle,
                ),
          ].join('  ·  '),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget grafica({
    required BuildContext context,
    required List<ExerciseProgress> progress,
    required String unit,
  }) {
    if (progress.length < 2) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final maxValue =
        progress.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                unit.toLowerCase() == 'lb' ? 'Lbs' : 'Kg',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 230,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxValue.roundToDouble(),
                minX: 0,
                maxX: (progress.length - 1).toDouble(),

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                      strokeWidth: 1,
                    );
                  },
                ),

                borderData: FlBorderData(show: false),

                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
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
                    color: colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorScheme.primary.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _especificaciones(
    BuildContext context,
    Exercise exercise,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final muscles = (exercise.muscleGroups ?? [])
        .map(
          (muscle) =>
              ExerciseConstants.opcionesGruposMusculares[muscle] ?? muscle,
        )
        .join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context,
            'Tipo',
            exercise.type == 'strength' ? 'Fuerza' : 'Cardio',
          ),
          _buildInfoDivider(context),
          _buildInfoRow(
            context,
            'Equipo',
            ExerciseConstants.opcionesEquipos[exercise.equipment] ??
                'Sin equipo',
          ),
          if (muscles.isNotEmpty) ...[
            _buildInfoDivider(context),
            _buildInfoRow(
              context,
              'Músculos',
              muscles,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDivider(BuildContext context) {
    return Divider(
      height: 1,
      color: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
    );
  }

  Widget _indicaciones(
    BuildContext context,
    Exercise exercise,
  ) {
    final description = exercise.description;

    if (description == null) {
      return const SizedBox.shrink();
    }

    final sections = <MapEntry<String, String>>[
      MapEntry('Posición inicial', description.positionInicial),
      MapEntry('Ejecución', description.ejecucion),
      MapEntry('Consejos', description.tipsExtra),
    ].where((entry) => entry.value.trim().isNotEmpty).toList();

    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cómo realizarlo',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 18),

          for (int i = 0; i < sections.length; i++) ...[
            Text(
              sections[i].key,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              sections[i].value,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            if (i != sections.length - 1) ...[
              const SizedBox(height: 18),
              Divider(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 2),
            ],
          ],
        ],
      ),
    );
  }
}
