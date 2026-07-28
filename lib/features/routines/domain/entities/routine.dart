class ExerciseRoutine {
  final String name;
  ExerciseRoutine({required this.name});

  factory ExerciseRoutine.fromJSON(Map<String, dynamic> json) {
    return ExerciseRoutine(
      name: json['name'],
    );
  }
}

class Routine {
  final String id;
  final String name;
  final List<ExerciseRoutine>? exercises;

  Routine({
    required this.id,
    required this.name,
    this.exercises,
  });

  factory Routine.fromJSON(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      name: json['name'],
      exercises: json['exercises'] != null
          ? (json['exercises'] as List)
                .map((e) => ExerciseRoutine.fromJSON(e))
                .toList()
          : null,
    );
  }
}
