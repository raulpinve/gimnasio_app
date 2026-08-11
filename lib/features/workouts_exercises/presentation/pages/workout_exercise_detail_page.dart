import 'package:flutter/material.dart';
import 'package:gym_app/features/workouts/presentation/widgets/set_card.dart';
import 'package:gym_app/features/workouts_exercises/presentation/pages/widgets/switcher_form.dart';

class WorkoutExerciseDetailPage extends StatefulWidget {
  const WorkoutExerciseDetailPage({super.key});

  @override
  State<WorkoutExerciseDetailPage> createState() =>
      _WorkoutExerciseDetailPageState();
}

class _WorkoutExerciseDetailPageState extends State<WorkoutExerciseDetailPage> {
  final _weigthController = TextEditingController();
  final _repsController = TextEditingController();
  bool showForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        leading: BackButton(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Press de banca',
              style:
                  Theme.of(
                    context,
                  ).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text("Objetivo: 4 series · 10 repeticiones"),
            SizedBox(
              height: 14,
            ),
            Divider(
              color: Theme.of(context).colorScheme.tertiary,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Series realizadas',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 14,
            ),
            Wrap(
              spacing: 8,
              children: [
                GestureDetector(
                  onLongPress: () {
                    _showDeleteRecordDialog(context);
                  },
                  child: SetCard(
                    weight: "10 kg",
                    reps: "10 reps",
                  ),
                ),
              ],
            ),
            SwitcherForm(
              showForm: showForm,
              weigthController: _weigthController,
              repsController: _repsController,
              onShowForm: () {
                setState(() {
                  showForm = true;
                });
              },
              onCloseForm: () {
                setState(() {
                  showForm = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteRecordDialog(
    BuildContext context,
    // WorkoutRecord record,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar serie"),
          content: const Text("¿Quieres eliminar este registro?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                // TODO: llamamos al cubit
              },
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
