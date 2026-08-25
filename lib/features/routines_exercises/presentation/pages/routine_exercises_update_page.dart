import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:gym_app/features/exercise/presentation/widgets/Exercise_thumbnail.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_update/routine_exercises_update_cubit.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_update/routine_exercises_update_state.dart';

class RoutineExercisesUpdatePage extends StatefulWidget {
  final String routineExerciseId;

  const RoutineExercisesUpdatePage({
    super.key,
    required this.routineExerciseId,
  });

  @override
  State<RoutineExercisesUpdatePage> createState() =>
      _RoutineExercisesUpdatePageState();
}

class _RoutineExercisesUpdatePageState
    extends State<RoutineExercisesUpdatePage> {
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
      RoutineExercisesUpdateCubit,
      RoutineExercisesUpdateState
    >(
      listener: (context, state) {
        if (state.routineExercise != null &&
            state.selectedExercise != null &&
            _targetSetsController.text.isEmpty &&
            _targetRepsController.text.isEmpty &&
            _targetDurationSecondsController.text.isEmpty &&
            _targetDistanceKmController.text.isEmpty) {
          final routineExercise = state.routineExercise!;

          _targetSetsController.text =
              routineExercise.targetSets?.toString() ?? '';

          _targetRepsController.text =
              routineExercise.targetReps?.toString() ?? '';

          _targetDurationSecondsController.text =
              routineExercise.targetDurationSeconds?.toString() ?? '';

          _targetDistanceKmController.text =
              routineExercise.targetDistanceKm?.toString() ?? '';

          setState(() {
            _selectedExercise = state.selectedExercise;
          });
        }

        if (state.isUpdated) {
          if (context.canPop()) {
            context.pop(true);
          }
        }

        if (state.errorMessage != null) {
          if (state.fieldErrors == null || state.fieldErrors!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoading;
        final isUpdating = state.isUpdating;

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

        if (isLoading) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: const Text('Editar ejercicio'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: const Text('Editar ejercicio'),
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
                _sectionHeader(context, step: 1, title: 'Ejercicio'),

                const SizedBox(height: 12),

                if (_selectedExercise != null) _buildSelectedExercise(context),

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
                    onTap: isUpdating
                        ? null
                        : () {
                            context
                                .read<RoutineExercisesUpdateCubit>()
                                .updateRoutineExercise({
                                  'targetSets':
                                      _targetSetsController.text.trim().isEmpty
                                      ? null
                                      : int.parse(
                                          _targetSetsController.text.trim(),
                                        ),

                                  'targetReps':
                                      _targetRepsController.text.trim().isEmpty
                                      ? null
                                      : int.parse(
                                          _targetRepsController.text.trim(),
                                        ),

                                  'targetDurationSeconds':
                                      _targetDurationSecondsController.text
                                          .trim()
                                          .isEmpty
                                      ? null
                                      : int.parse(
                                          _targetDurationSecondsController.text
                                              .trim(),
                                        ),

                                  'targetDistanceKm':
                                      _targetDistanceKmController.text
                                          .trim()
                                          .isEmpty
                                      ? null
                                      : double.parse(
                                          _targetDistanceKmController.text
                                              .trim(),
                                        ),
                                });
                          },
                    type: MyButtonType.primary,
                    text: 'Guardar cambios',
                    isLoading: isUpdating,
                  ),
                ),
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
        ],
      ),
    );
  }
}
