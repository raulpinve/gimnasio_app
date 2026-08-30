import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/routines/domain/entities/routine.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine_list/routine_list_cubit.dart';

class RoutineCard extends StatefulWidget {
  final Routine routine;
  final bool isHighlighted;
  final VoidCallback onDelete;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onDelete,
    this.isHighlighted = false,
  });

  @override
  State<RoutineCard> createState() => _RoutineCardState();
}

class _RoutineCardState extends State<RoutineCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    if (widget.isHighlighted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final exercises = widget.routine.exercises ?? [];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final response = await context.push<bool>(
            '/routine-exercises/${widget.routine.id}',
          );

          if (!context.mounted) return;

          if (response == true) {
            context.read<RoutineListCubit>().loadRoutines();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            final progress = 1 - _fadeAnimation.value; // 1 -> 0

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: widget.isHighlighted
                    ? colorScheme.primary.withValues(alpha: 0.06 * progress)
                    : null,
                border: widget.isHighlighted
                    ? Border.all(
                        color: colorScheme.primary.withValues(
                          alpha: 0.3 + (0.7 * progress),
                        ),
                        width: 1.5,
                      )
                    : null,
              ),
              child: child,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.routine.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercises.isEmpty
                              ? 'Sin ejercicios'
                              : '${exercises.length} ${exercises.length == 1 ? 'ejercicio' : 'ejercicios'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Colors.grey.shade500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'delete':
                            widget.onDelete();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20),
                              SizedBox(width: 10),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (exercises.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  exercises
                      .take(3)
                      .map((exercise) => exercise.name)
                      .join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (exercises.length > 3) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${exercises.length - 3} más',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
