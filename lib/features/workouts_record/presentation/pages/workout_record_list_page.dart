import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/enums/workout_type.dart';
import 'package:gym_app/core/utils/snackbar_helper.dart';
import 'package:gym_app/features/workouts_exercises/domain/entities/workout_exercise.dart';
import 'package:gym_app/features/workouts_record/domain/entities/workout_record.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercise_detail/workout_exercise_detail_cubit.dart';
import 'package:gym_app/features/workouts_exercises/presentation/cubits/workout_exercise_detail/workout_exercise_detail_state.dart';
import 'package:gym_app/features/workouts_record/presentation/cubits/workout_record/workout_record_cubit.dart';
import 'package:gym_app/features/workouts_record/presentation/cubits/workout_record/workout_record_state.dart';
import 'package:gym_app/features/workouts_record/presentation/widgets/record_chip.dart';
import 'package:gym_app/features/workouts_record/presentation/widgets/switcher_form.dart';

class WorkoutRecordListPage extends StatefulWidget {
  final String workoutExerciseId;

  const WorkoutRecordListPage({
    super.key,
    required this.workoutExerciseId,
  });

  @override
  State<WorkoutRecordListPage> createState() => _WorkoutRecordListPageState();
}

class _WorkoutRecordListPageState extends State<WorkoutRecordListPage> {
  WorkoutRecord? editingRecord;

  // Controladores de fuerza
  final _weigthController = TextEditingController();
  final _repsController = TextEditingController();

  // Controladores de cardio
  final _minutesController = TextEditingController();
  final _distanceController = TextEditingController();

  bool showForm = false;

  // Evita disparar loadWorkoutRecords más de una vez.
  bool _recordsRequested = false;

  @override
  void dispose() {
    _weigthController.dispose();
    _repsController.dispose();
    _minutesController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  ExerciseType _exerciseTypeFrom(String? type) {
    return type == "cardio" ? ExerciseType.cardio : ExerciseType.strength;
  }

  void _editWorkoutRecord(
    WorkoutRecord record,
    ExerciseType exerciseType,
  ) {
    setState(() {
      editingRecord = record;
      showForm = true;
    });

    if (exerciseType == ExerciseType.cardio) {
      _minutesController.text = ((record.durationSeconds ?? 0) ~/ 60)
          .toString();

      _distanceController.text = record.distanceKm?.toString() ?? '';

      _weigthController.clear();
      _repsController.clear();
    } else {
      _weigthController.text = record.weight?.toString() ?? '';

      _repsController.text = record.reps?.toString() ?? '';

      _minutesController.clear();
      _distanceController.clear();
    }
  }

  void _clearRecordForm() {
    _weigthController.clear();
    _repsController.clear();
    _minutesController.clear();
    _distanceController.clear();
  }

  void _submitWorkoutRecord(
    ExerciseType exerciseType,
    WorkoutExercise workoutExercise,
  ) async {
    final cubit = context.read<WorkoutRecordCubit>();
    final wasEditing =
        editingRecord != null; // guardamos antes de limpiar el form

    if (exerciseType == ExerciseType.cardio) {
      final minutes = int.tryParse(_minutesController.text.trim());
      final distance = double.tryParse(_distanceController.text.trim());

      if (minutes == null ||
          minutes <= 0 ||
          distance == null ||
          distance <= 0) {
        showMessage(
          context,
          "Ingresa minutos y distancia válidos",
          type: MessageType.error,
        );
        return;
      }

      final Map<String, dynamic> workoutRecordBody = {
        "durationSeconds": minutes * 60,
        "distanceKm": distance,
      };

      if (editingRecord != null) {
        await cubit.updateWorkoutRecord(
          editingRecord!.id,
          ExerciseType.cardio,
          workoutRecordBody,
        );
      } else {
        workoutRecordBody["workoutExerciseId"] =
            workoutExercise.workoutExerciseId;
        await cubit.createWorkoutRecord(ExerciseType.cardio, workoutRecordBody);
      }

      _handleSubmitResult(cubit, wasEditing);
      return;
    }

    final weight = double.tryParse(_weigthController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());

    if (weight == null || weight <= 0 || reps == null || reps <= 0) {
      showMessage(
        context,
        "Ingresa peso y repeticiones válidos",
        type: MessageType.error,
      );
      return;
    }

    final Map<String, dynamic> workoutRecordBody = {
      "weight": weight,
      "weightUnit": workoutExercise.suggestedWeightUnit ?? "Kg",
      "reps": reps,
    };

    if (editingRecord != null) {
      await cubit.updateWorkoutRecord(
        editingRecord!.id,
        ExerciseType.strength,
        workoutRecordBody,
      );
    } else {
      workoutRecordBody["workoutExerciseId"] =
          workoutExercise.workoutExerciseId;
      await cubit.createWorkoutRecord(ExerciseType.strength, workoutRecordBody);
    }

    _handleSubmitResult(cubit, wasEditing);
  }

  void _handleSubmitResult(WorkoutRecordCubit cubit, bool wasEditing) {
    if (!mounted) return;

    final state = cubit.state;
    final hadError = state is WorkoutRecordsLoaded && state.actionError != null;

    if (!hadError) {
      _clearRecordForm();
      setState(() {
        editingRecord = null;
        showForm = false;
      });

      showMessage(
        context,
        wasEditing
            ? 'Serie actualizada correctamente'
            : 'Serie registrada correctamente',
        type: MessageType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && context.canPop()) {
          context.pop(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80.0,
          leading: BackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop(true);
              }
            },
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocListener<WorkoutRecordCubit, WorkoutRecordState>(
            listener: (context, recordState) {
              if (recordState is WorkoutRecordsLoaded &&
                  recordState.actionError != null) {
                showMessage(
                  context,
                  recordState.actionError!,
                  type: MessageType.error,
                );
              }
            },
            child: BlocBuilder<WorkoutExerciseDetailCubit, WorkoutExerciseDetailState>(
              builder: (context, state) {
                if (state is WorkoutExerciseDetailLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is WorkoutExerciseDetailError) {
                  return Center(
                    child: Text(state.message),
                  );
                }

                if (state is WorkoutExerciseDetailLoaded) {
                  final workoutExercise = state.workoutExercise;
                  final exerciseType = _exerciseTypeFrom(
                    workoutExercise.exerciseType,
                  );

                  // Primera vez que tenemos el ejercicio cargado:
                  // pedimos sus records al nuevo cubit.
                  if (!_recordsRequested) {
                    _recordsRequested = true;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;

                      context.read<WorkoutRecordCubit>().loadWorkoutRecords(
                        workoutExercise.workoutExerciseId ??
                            widget.workoutExerciseId,
                        exerciseType,
                      );
                    });
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final workoutExerciseDetailCubit = context
                          .read<WorkoutExerciseDetailCubit>();

                      final workoutRecordCubit = context
                          .read<WorkoutRecordCubit>();

                      await workoutExerciseDetailCubit.loadWorkoutExerciseById(
                        workoutExercise.workoutExerciseId ?? "",
                      );

                      if (!mounted) return;

                      await workoutRecordCubit.loadWorkoutRecords(
                        workoutExercise.workoutExerciseId ??
                            widget.workoutExerciseId,
                        exerciseType,
                      );
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre del ejercicio
                          GestureDetector(
                            onTap: () {
                              context.push(
                                "/exercises/${workoutExercise.exerciseId}",
                              );
                            },
                            child: Text(
                              workoutExercise.exerciseName ?? "Ejercicio",
                              style: Theme.of(context).textTheme.headlineSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Objetivos del ejercicio
                          exerciseType == ExerciseType.cardio
                              ? Text(
                                  "Objetivo: "
                                  "${workoutExercise.targetDistanceKm ?? 0} km · "
                                  "${workoutExercise.targetDurationSeconds ?? 0} s",
                                )
                              : Text(
                                  "Objetivo: "
                                  "${workoutExercise.targetSets ?? 0} series × "
                                  "${workoutExercise.targetReps ?? 0} reps",
                                ),

                          const SizedBox(height: 14),

                          Divider(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),

                          // Series realizadas: ahora vienen del WorkoutRecordCubit.
                          BlocBuilder<WorkoutRecordCubit, WorkoutRecordState>(
                            builder: (context, recordState) {
                              final isSaving =
                                  recordState is WorkoutRecordsLoaded
                                  ? recordState.isSaving
                                  : false;

                              if (recordState is WorkoutRecordLoading ||
                                  recordState is WorkoutRecordInitial) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final records =
                                  recordState is WorkoutRecordsLoaded
                                  ? recordState.workoutRecords
                                  : <WorkoutRecord>[];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Solo mostrar los registros si existen
                                  if (records.isNotEmpty) ...[
                                    const SizedBox(height: 20),

                                    Text(
                                      'Series realizadas',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),

                                    const SizedBox(height: 14),

                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: records.map((record) {
                                        return RecordChip(
                                          record: record,
                                          exerciseType: exerciseType,
                                          onEdit: () => _editWorkoutRecord(
                                            record,
                                            exerciseType,
                                          ),
                                          onDelete: () =>
                                              _showDeleteRecordDialog(
                                                context,
                                                record.id,
                                                exerciseType,
                                              ),
                                        );
                                      }).toList(),
                                    ),
                                  ],

                                  // El formulario siempre está disponible
                                  SwitcherForm(
                                    showForm: showForm,
                                    isEditing: editingRecord != null,
                                    formType:
                                        exerciseType == ExerciseType.cardio
                                        ? FormType.cardioForm
                                        : FormType.strengthForm,
                                    isLoading: isSaving,

                                    weigthController: _weigthController,
                                    repsController: _repsController,
                                    minutesController: _minutesController,
                                    distanceController: _distanceController,

                                    suggestedWeightUnit:
                                        workoutExercise.suggestedWeightUnit,

                                    onShowForm: () {
                                      _clearRecordForm();

                                      setState(() {
                                        editingRecord = null;
                                        showForm = true;
                                      });
                                    },

                                    onCloseForm: () {
                                      if (isSaving) return;

                                      _clearRecordForm();

                                      setState(() {
                                        editingRecord = null;
                                        showForm = false;
                                      });
                                    },

                                    onSubmit: () {
                                      _submitWorkoutRecord(
                                        exerciseType,
                                        workoutExercise,
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteRecordDialog(
    BuildContext context,
    String workoutRecordId,
    ExerciseType exerciseType,
  ) {
    final cubit = context.read<WorkoutRecordCubit>();
    final pageContext = context; // 👈 nuevo

    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocBuilder<WorkoutRecordCubit, WorkoutRecordState>(
          bloc: cubit,
          builder: (context, state) {
            final isDeleting =
                state is WorkoutRecordsLoaded && state.isDeleting;

            return AlertDialog(
              title: const Text("Eliminar serie"),
              content: const Text("¿Quieres eliminar este registro?"),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          await cubit.deleteWorkoutRecord(
                            workoutRecordId,
                            exerciseType,
                          );

                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);

                          final newState = cubit.state;
                          final hadError =
                              newState is WorkoutRecordsLoaded &&
                              newState.actionError != null;

                          if (!hadError && pageContext.mounted) {
                            showMessage(
                              pageContext,
                              'Serie eliminada correctamente',
                              type: MessageType.success,
                            );
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          "Eliminar",
                          style: TextStyle(color: Colors.red),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
