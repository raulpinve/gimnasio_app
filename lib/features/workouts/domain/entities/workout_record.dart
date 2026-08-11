class WorkoutRecord {
  final String id;
  final bool isCardio;

  final double? weight;
  final String? weightUnit;
  final int? reps;

  final int? durationSeconds;
  final double? distanceKm;

  WorkoutRecord({
    required this.id,
    required this.isCardio,
    this.weight,
    this.weightUnit,
    this.reps,
    this.durationSeconds,
    this.distanceKm,
  });

  factory WorkoutRecord.fromJSON(Map<String, dynamic> json) {
    return WorkoutRecord(
      id: json['id'],
      isCardio: json['isCardio'] ?? false,

      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,

      weightUnit: json['weightUnit'],

      reps: json['reps'],

      durationSeconds: json['durationSeconds'],

      distanceKm: json['distanceKm'] != null
          ? double.tryParse(json['distanceKm'].toString())
          : null,
    );
  }
}
