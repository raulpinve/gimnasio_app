import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/workouts/domain/entities/workout.dart';

Widget recentWorkoutCard(
  BuildContext context, {
  required Workout workout,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        context.push("/workouts-exercises/${workout.id}");
      },
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Text(
              formatWorkoutDate(workout.fecha),
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    workout.duracion?.isNotEmpty == true
                        ? '${workout.duracion} min'
                        : workout.estado == 'abierto'
                        ? 'En curso'
                        : '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    ),
  );
}

String formatWorkoutDate(String? fecha) {
  if (fecha == null || fecha.isEmpty) return '';

  final date = DateTime.tryParse(fecha);

  if (date == null) return '';

  const months = [
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC',
  ];

  return '${date.day} ${months[date.month - 1]}';
}
