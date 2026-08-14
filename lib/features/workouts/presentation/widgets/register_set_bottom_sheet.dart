import 'package:flutter/material.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_exercise.dart';

class RegisterSetBottomSheet extends StatefulWidget {
  final WorkoutExercise workoutExercise;

  const RegisterSetBottomSheet({
    super.key,
    required this.workoutExercise,
  });

  @override
  State<RegisterSetBottomSheet> createState() => _RegisterSetBottomSheetState();
}

class _RegisterSetBottomSheetState extends State<RegisterSetBottomSheet> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Peso sugerido por el backend
    _weightController.text = widget.workoutExercise.suggestedWeight ?? "";

    // Repeticiones objetivo
    _repsController.text = widget.workoutExercise.targetReps ?? "";
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutExercise = widget.workoutExercise;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Registrar serie",
                style:
                    Theme.of(
                      context,
                    ).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 18),

              Text(
                workoutExercise.exerciseName ?? "",
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Objetivo",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${workoutExercise.targetSets ?? "-"} × ${workoutExercise.targetReps ?? "-"}",
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            "Peso sugerido",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${workoutExercise.suggestedWeight ?? "-"} ${workoutExercise.suggestedWeightUnit ?? ""}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Peso",
                  suffixText: workoutExercise.suggestedWeightUnit ?? "kg",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _repsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Repeticiones",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    /*
                    context
                        .read<WorkoutRecordCreateCubit>()
                        .createRecordWorkout(
                          workoutExercise.exerciseType == "cardio"
                              ? ExerciseType.cardio
                              : ExerciseType.strength,
                          {
                            "workoutExerciseId": workoutExercise.exerciseId,
                            "weight":
                                double.tryParse(_weightController.text) ?? 0,
                            "reps": int.tryParse(_repsController.text) ?? 0,
                            "weightUnit":
                                workoutExercise.suggestedWeightUnit ?? "kg",
                          },
                        );
                        */
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Guardar serie"),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
