import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_update_state.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_update_cubit.dart';

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
  // 1. Controladores
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

        if (isLoading) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: const Text("Editar ejercicio"),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

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
            title: Text("Editar ejercicio"),
            leading: BackButton(
              onPressed: () {
                context.pop();
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedExercise != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child:
                              (_selectedExercise?.avatar != null &&
                                  _selectedExercise!.avatar!.isNotEmpty)
                              ? Image.network(
                                  _selectedExercise!.avatar!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) {
                                    return const Icon(
                                      Icons.image_not_supported,
                                    );
                                  },
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  alignment: Alignment.center,
                                  color: Colors.grey.shade200,
                                  child: _selectedExercise?.type == "cardio"
                                      ? const Icon(Icons.directions_run)
                                      : const Icon(Icons.fitness_center),
                                ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedExercise!.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _selectedExercise?.type == "cardio"
                                  ? "Cardio"
                                  : "Fuerza",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(
                  height: 16,
                ),
                Column(
                  children: [
                    if (_selectedExercise?.type == 'strength') ...[
                      MyTextfield(
                        controller: _targetSetsController,
                        hintText: "Series",
                        obscureText: false,
                        keyboardType: TextInputType.number,
                        errorText: targetSetError,
                      ),

                      const SizedBox(height: 16),

                      MyTextfield(
                        controller: _targetRepsController,
                        hintText: "Repeticiones",
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
                        keyboardType: TextInputType.number,
                        errorText: targetDistanceKmError,
                      ),
                    ],

                    const SizedBox(height: 16),
                    MyButton(
                      onTap: () {
                        context
                            .read<RoutineExercisesUpdateCubit>()
                            .updateRoutineExercise({
                              "targetSets":
                                  _targetSetsController.text.trim().isEmpty
                                  ? null
                                  : int.parse(
                                      _targetSetsController.text.trim(),
                                    ),

                              "targetReps":
                                  _targetRepsController.text.trim().isEmpty
                                  ? null
                                  : int.parse(
                                      _targetRepsController.text.trim(),
                                    ),

                              "targetDurationSeconds":
                                  _targetDurationSecondsController.text
                                      .trim()
                                      .isEmpty
                                  ? null
                                  : int.parse(
                                      _targetDurationSecondsController.text
                                          .trim(),
                                    ),

                              "targetDistanceKm":
                                  _targetDistanceKmController.text
                                      .trim()
                                      .isEmpty
                                  ? null
                                  : double.parse(
                                      _targetDistanceKmController.text.trim(),
                                    ),
                            });
                      },
                      type: MyButtonType.primary,
                      text: "Actualizar ejercicio",
                      isLoading: isUpdating,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
