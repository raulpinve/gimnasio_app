import 'package:flutter/material.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_exercise.dart';
import 'package:gym_app/features/workouts/presentation/widgets/set_card.dart';
import 'package:gym_app/features/workouts_exercises/presentation/widgets/format_number.dart';

class WorkoutExerciseCard extends StatelessWidget {
  const WorkoutExerciseCard({
    super.key,
    required this.workoutExercise,
    required this.onRegisterSet,
  });

  final WorkoutExercise workoutExercise;
  final VoidCallback onRegisterSet;

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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        color: Theme.of(context).colorScheme.tertiary, //
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          Text(_objective, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          _buildProgressBar(),
          const SizedBox(height: 20),
          const Text(
            "Registros realizados",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildRecordsList(),
          const SizedBox(height: 20),
          _buildRegisterButton(context, workoutExercise.exerciseType),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            workoutExercise.exerciseName ?? "Ejercicio",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _isCardio
                ? "$_completedRecords registros"
                : "$_completedRecords/$_targetRecords",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(value: _progress, minHeight: 8),
    );
  }

  Widget _buildRecordsList() {
    if (workoutExercise.records.isEmpty) {
      return Text(
        "Sin registros en esta sesión",
        style: TextStyle(color: Colors.grey.shade600),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: workoutExercise.records.map((record) {
        if (_isCardio) {
          return SetCard(
            primaryText: "${formatNumber(record.distanceKm)} km",
            secondaryText: "${record.durationSeconds ?? 0}s",
            color: Colors.grey.shade100,
          );
        }

        return SetCard(
          primaryText:
              "${formatNumber(record.weight)} ${record.weightUnit ?? "kg"}",
          secondaryText: "${record.reps ?? 0} reps",
          color: Colors.grey.shade100,
        );
      }).toList(),
    );
  }

  Widget _buildRegisterButton(BuildContext context, String? exerciseType) {
    return Material(
      color: Theme.of(context).colorScheme.secondary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onRegisterSet,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                exerciseType == "cardio"
                    ? "Registrar sesión"
                    : exerciseType == "strength"
                    ? "Registrar serie"
                    : "Registrar datos",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _setCard({
  required String weight,
  required String reps,
}) {
  return Container(
    width: 80,
    padding: const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 8,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Column(
      children: [
        Text(
          weight,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          reps,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
