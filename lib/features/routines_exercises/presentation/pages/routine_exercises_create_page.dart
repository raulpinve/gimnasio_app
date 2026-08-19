import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/auth/presentation/components/my_button.dart';
import 'package:gym_app/features/auth/presentation/components/my_textfield.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_create/routine_exercises_create_cubit.dart';
import 'package:gym_app/features/routines_exercises/presentation/cubits/routine_exercises_create/routine_exercises_create_state.dart';

class RoutineExercisesCreatePage extends StatefulWidget {
  final String routineId;
  const RoutineExercisesCreatePage({super.key, required this.routineId});

  @override
  State<RoutineExercisesCreatePage> createState() =>
      _RoutineExercisesCreatePageState();
}

class _RoutineExercisesCreatePageState
    extends State<RoutineExercisesCreatePage> {
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
              ),
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
            // 2. Quitamos las comillas estáticas y metemos el BlocBuilder para escuchar el RoutineCubit
            /*title: BlocBuilder<RoutineCubit, RoutineState>(
              builder: (context, routineState) {
                if (routineState is SingleRoutineLoading) {
                  return Text("Cargando...");
                }
                if (routineState is SingleRoutineLoaded) {
                  routineId = routineState.routine.id;
                  return Text(
                    routineState.routine.name,
                  );
                }
                if (routineState is RoutineError) {
                  return const Text("Error al cargar");
                }
                return const Text("Cargando...");
              },
            ),*/
            title: Text("Agregar ejercicio"),
            leading: IconButton(
              onPressed: () async {
                context.pop();
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),

          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedExercise == null) ...[
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      title: const Text('Seleccionar ejercicio'),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () async {
                        final exercise = await context.push<Exercise>(
                          '/exercises/selector',
                        );
                        if (exercise != null) {
                          setState(() {
                            _selectedExercise = exercise;
                          });
                        }
                      },
                    ),
                  ),
                ],

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
                        trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedExercise = null;
                            });
                          },
                          icon: Icon(Icons.cancel),
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
                            .read<RoutineExercisesCreateCubit>()
                            .createRoutineExercise({
                              "targetSets": _targetSetsController.text.trim(),
                              "targetReps": _targetRepsController.text.trim(),
                              "targetDurationSeconds":
                                  _targetDurationSecondsController.text.trim(),
                              "targetDistanceKm": _targetDistanceKmController
                                  .text
                                  .trim(),
                              "routineId": widget.routineId,
                              "exerciseId": _selectedExercise?.id,
                            });
                      },
                      type: MyButtonType.primary,
                      text: "Agregar ejercicio",
                      isLoading: isCreating,
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
