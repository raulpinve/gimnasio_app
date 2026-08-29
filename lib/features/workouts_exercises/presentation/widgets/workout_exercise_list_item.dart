import 'package:flutter/material.dart';
import 'package:gym_app/features/workouts_exercises/domain/entities/workout_exercise.dart';

class WorkoutExerciseListItem extends StatelessWidget {
  final WorkoutExercise workoutExercise;
  final bool isOpen;
  final VoidCallback onRegisterSet;
  final VoidCallback onDelete;

  const WorkoutExerciseListItem({
    super.key,
    required this.workoutExercise,
    required this.isOpen,
    required this.onRegisterSet,
    required this.onDelete,
  });

  bool get _isCardio => workoutExercise.exerciseType == "cardio";

  String get _objetivo {
    if (_isCardio) {
      return "${workoutExercise.targetDistanceKm ?? 0} km · "
          "${workoutExercise.targetDurationSeconds ?? 0} s";
    }
    return "${workoutExercise.targetSets ?? 0} series × "
        "${workoutExercise.targetReps ?? 0} reps";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: isOpen ? onRegisterSet : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 4,
        ),
        child: Row(
          children: [
            // Icono según tipo de ejercicio
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isCardio ? Icons.directions_run : Icons.fitness_center,
                size: 18,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(width: 12),

            // Nombre + objetivo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workoutExercise.exerciseName ?? "Ejercicio",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _objetivo,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Acciones: solo visibles si el workout está abierto
            if (isOpen) ...[
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onRegisterSet,
                tooltip: "Registrar serie",
                color: colorScheme.primary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                tooltip: "Eliminar ejercicio",
                color: Colors.red,
              ),
            ] else
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}
