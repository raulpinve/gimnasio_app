import 'package:flutter/material.dart';
import 'package:gym_app/core/enums/workout_type.dart';
import 'package:gym_app/features/workouts_record/presentation/widgets/format_number.dart';

class RecordChip extends StatelessWidget {
  const RecordChip({
    super.key,
    required this.record,
    required this.exerciseType,
    required this.onEdit,
    required this.onDelete,
  });

  final dynamic record;
  final ExerciseType exerciseType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get _isCardio => record.isCardio;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isCardio
                    ? '${(record.durationSeconds ?? 0) ~/ 60} min'
                    : '${formatNumber(record.weight)} ${record.weightUnit ?? 'Kg'}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _isCardio
                    ? '${formatNumber(record.distanceKm)} Km'
                    : '${record.reps ?? 0} reps',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(width: 4),

          SizedBox(
            width: 32,
            height: 32,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_vert,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Editar',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Eliminar',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
