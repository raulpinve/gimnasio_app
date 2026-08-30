import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/workouts_exercises/domain/entities/workout_exercise.dart';
import 'package:gym_app/features/workouts_record/presentation/widgets/format_number.dart';

class WorkoutExerciseCard extends StatelessWidget {
  const WorkoutExerciseCard({
    super.key,
    required this.workoutExercise,
    required this.onRegisterSet,
    required this.onDelete,
    required this.isOpen,
  });

  final WorkoutExercise workoutExercise;
  final VoidCallback onRegisterSet;
  final VoidCallback onDelete;
  final bool isOpen;

  bool get _isCardio => workoutExercise.exerciseType == "cardio";

  int get _completedRecords => workoutExercise.records.length;

  int get _targetRecords =>
      _isCardio ? 0 : int.tryParse(workoutExercise.targetSets ?? "0") ?? 0;

  double get _progress {
    if (_isCardio) {
      final int completedSeconds = workoutExercise.records.fold<int>(
        0,
        (sum, record) => sum + (record.durationSeconds ?? 0),
      );

      final int targetSeconds =
          int.tryParse(workoutExercise.targetDurationSeconds ?? "0") ?? 0;

      return targetSeconds == 0
          ? 0
          : (completedSeconds / targetSeconds).clamp(0.0, 1.0);
    }

    return _targetRecords == 0
        ? 0
        : (_completedRecords / _targetRecords).clamp(0.0, 1.0);
  }

  String get _objective => _isCardio
      ? "Objetivo: ${workoutExercise.targetDistanceKm ?? 0} km · "
            "${workoutExercise.targetDurationSeconds ?? 0} s"
      : "Objetivo: ${workoutExercise.targetSets ?? 0} series × "
            "${workoutExercise.targetReps ?? 0} reps";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),

          const SizedBox(height: 8),

          Text(
            _objective,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          _buildProgressBar(context),

          const SizedBox(height: 20),

          Text(
            "Registros realizados",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          _buildRecordsList(context),

          const SizedBox(height: 20),

          if (isOpen)
            _buildRegisterButton(
              context,
              workoutExercise.exerciseType,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.push(
                "/exercises/${workoutExercise.exerciseId}",
              );
            },
            child: Text(
              workoutExercise.exerciseName ?? "Ejercicio",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _isCardio
                ? "$_completedRecords registros"
                : "$_completedRecords/$_targetRecords",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondary,
              fontSize: 12,
            ),
          ),
        ),

        if (isOpen)
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.more_vert,
              color: colorScheme.onSurfaceVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == "delete") {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: "delete",
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Eliminar",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: _progress,
        minHeight: 8,
        backgroundColor: colorScheme.onSurface.withValues(
          alpha: 0.08,
        ),
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildRecordsList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (workoutExercise.records.isEmpty) {
      return Text(
        "Sin registros en esta sesión",
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: workoutExercise.records.asMap().entries.map((entry) {
        final index = entry.key;
        final record = entry.value;

        final String primaryText;
        final String secondaryText;

        if (_isCardio) {
          primaryText = "${(record.durationSeconds ?? 0) ~/ 60} min";
          secondaryText = "${formatNumber(record.distanceKm)} km";
        } else {
          primaryText =
              "${formatNumber(record.weight)} ${record.weightUnit ?? "kg"}";
          secondaryText = "${record.reps ?? 0} reps";
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  "${index + 1}.",
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),

              Text(
                primaryText,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),

              const SizedBox(width: 6),

              Text(
                "· $secondaryText",
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRegisterButton(
    BuildContext context,
    String? exerciseType,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool isCardio = exerciseType == "cardio";

    return Material(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onRegisterSet,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCardio ? Icons.timer_outlined : Icons.add_circle_outline,
                size: 20,
                color: colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                isCardio ? "Registrar sesión" : "Registrar serie",
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
