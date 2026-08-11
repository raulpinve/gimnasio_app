import 'package:flutter/material.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_exercise.dart';

class WorkoutExerciseSpecs extends StatelessWidget {
  final WorkoutExercise workoutExercise;

  const WorkoutExerciseSpecs({
    super.key,
    required this.workoutExercise,
  });

  @override
  Widget build(BuildContext context) {
    final details = <String>[
      if (workoutExercise.targetSets != null)
        "Ser: ${workoutExercise.targetSets}",
      if (workoutExercise.targetReps != null)
        "Rep: ${workoutExercise.targetReps}",
      if (workoutExercise.targetWeight != null)
        "P: ${workoutExercise.targetWeight} kg",
      if (workoutExercise.targetDurationSeconds != null)
        "Dur: ${workoutExercise.targetDurationSeconds} s",
      if (workoutExercise.targetDistanceKm != null)
        "Dist: ${workoutExercise.targetDistanceKm} km",
      if (workoutExercise.personalRecord != null)
        "RP: ${workoutExercise.personalRecord} kg",
      if (workoutExercise.suggestedWeight != null)
        "Sug: ${workoutExercise.suggestedWeight} ${workoutExercise.suggestedWeightUnit ?? 'kg'}",
    ];

    if (details.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < details.length; i++) ...[
          Text(
            details[i],
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (i < details.length - 1)
            const Text(
              "•",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.0, // Centra verticalmente el punto
              ),
            ),
        ],
      ],
    );
  }
}
