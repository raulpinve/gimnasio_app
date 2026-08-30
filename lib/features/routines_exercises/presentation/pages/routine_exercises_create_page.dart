import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/utils/snackbar_helper.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:gym_app/features/exercise/presentation/widgets/Exercise_thumbnail.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine/routine_detail_cubit.dart';
import 'package:gym_app/features/routines/presentation/cubits/routine/routine_detail_state.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_create/routine_exercises_create_cubit.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_create/routine_exercises_create_state.dart';

class RoutineExercisesCreatePage extends StatefulWidget {
  final String routineId;

  const RoutineExercisesCreatePage({
    super.key,
    required this.routineId,
  });

  @override
  State<RoutineExercisesCreatePage> createState() =>
      _RoutineExercisesCreatePageState();
}

class _RoutineExercisesCreatePageState
    extends State<RoutineExercisesCreatePage> {
  final TextEditingController _targetSetsController = TextEditingController();

  final TextEditingController _targetRepsController = TextEditingController();

  final TextEditingController _targetDurationSecondsController =
      TextEditingController();

  final TextEditingController _targetDistanceKmController =
      TextEditingController();

  Exercise? _selectedExercise;

  @override
  void dispose() {
    _targetSetsController.dispose();
    _targetRepsController.dispose();
    _targetDurationSecondsController.dispose();
    _targetDistanceKmController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      RoutineExercisesCreateCubit,
      RoutineExercisesCreateState
    >(
      listener: (context, state) {
        if (state.isCreated) {
          if (context.canPop()) {
            context.pop(true);
          }
        }

        if (state.errorMessage != null) {
          if (state.fieldErrors == null || state.fieldErrors!.isEmpty) {
            showMessage(
              context,
              state.errorMessage!,
              type: MessageType.error,
            );
          }
        }
      },
      builder: (context, state) {
        final isCreating = state.isCreating;

        String? targetSetError;
        String? targetRepsError;
        String? targetDurationSecondsError;
        String? targetDistanceKmError;

        if (state.fieldErrors != null) {
          targetSetError = state.fieldErrors!['targetSet']?.toString();

          targetRepsError = state.fieldErrors!['targetReps']?.toString();

          targetDurationSecondsError = state
              .fieldErrors!['targetDurationSeconds']
              ?.toString();

          targetDistanceKmError = state.fieldErrors!['targetDistanceKm']
              ?.toString();
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: const Text('Agregar ejercicio'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<RoutineDetailCubit, RoutineDetailState>(
                  builder: (context, routineState) {
                    if (routineState is RoutineDetailLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RUTINA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            routineState.routine.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      );
                    }

                    if (routineState is RoutineDetailLoading) {
                      return Text(
                        'Cargando rutina...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 28),

                _sectionHeader(context, step: 1, title: 'Elige el ejercicio'),

                const SizedBox(height: 12),

                if (_selectedExercise == null) _buildExerciseSelector(context),

                if (_selectedExercise != null) _buildSelectedExercise(context),

                if (_selectedExercise != null) ...[
                  const SizedBox(height: 28),

                  _sectionHeader(context, step: 2, title: 'Define el objetivo'),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (_selectedExercise?.type == 'strength') ...[
                          MyTextfield(
                            controller: _targetSetsController,
                            hintText: 'Series',
                            obscureText: false,
                            keyboardType: TextInputType.number,
                            errorText: targetSetError,
                          ),

                          const SizedBox(height: 16),

                          MyTextfield(
                            controller: _targetRepsController,
                            hintText: 'Repeticiones',
                            obscureText: false,
                            keyboardType: TextInputType.number,
                            errorText: targetRepsError,
                          ),
                        ],

                        if (_selectedExercise?.type == 'cardio') ...[
                          MyTextfield(
                            controller: _targetDurationSecondsController,
                            hintText: 'Duración (segundos)',
                            obscureText: false,
                            keyboardType: TextInputType.number,
                            errorText: targetDurationSecondsError,
                          ),

                          const SizedBox(height: 16),

                          MyTextfield(
                            controller: _targetDistanceKmController,
                            hintText: 'Distancia (km)',
                            obscureText: false,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            errorText: targetDistanceKmError,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: MyButton(
                      onTap: isCreating
                          ? null
                          : () {
                              context
                                  .read<RoutineExercisesCreateCubit>()
                                  .createRoutineExercise({
                                    'targetSets': _targetSetsController.text
                                        .trim(),
                                    'targetReps': _targetRepsController.text
                                        .trim(),
                                    'targetDurationSeconds':
                                        _targetDurationSecondsController.text
                                            .trim(),
                                    'targetDistanceKm':
                                        _targetDistanceKmController.text.trim(),
                                    'routineId': widget.routineId,
                                    'exerciseId': _selectedExercise?.id,
                                  });
                            },
                      type: MyButtonType.primary,
                      text: 'Agregar ejercicio',
                      isLoading: isCreating,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required int step,
    required String title,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(
              alpha: 0.12,
            ),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$step',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        final exercise = await context.push<Exercise>(
          '/exercises/selector',
        );

        if (!context.mounted) return;

        if (exercise != null) {
          setState(() {
            _selectedExercise = exercise;
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              size: 34,
              color: colorScheme.primary,
            ),

            const SizedBox(height: 10),

            const Text(
              'Seleccionar ejercicio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Elige un ejercicio para configurar',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedExercise(BuildContext context) {
    final exercise = _selectedExercise!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ExerciseThumbnail(
            name: exercise.name,
            imageUrl: exercise.avatar,
            size: 64,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    exercise.type == 'cardio' ? 'Cardio' : 'Fuerza',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              setState(() {
                _selectedExercise = null;

                _targetSetsController.clear();
                _targetRepsController.clear();
                _targetDurationSecondsController.clear();
                _targetDistanceKmController.clear();
              });
            },
            icon: const Icon(
              Icons.close_rounded,
            ),
            tooltip: 'Cambiar ejercicio',
          ),
        ],
      ),
    );
  }
}
