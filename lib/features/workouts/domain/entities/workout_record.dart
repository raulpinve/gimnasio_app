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

  factory WorkoutRecord.fromJSON(
    Map<String, dynamic> json, {
    bool? isCardio,
  }) {
    return WorkoutRecord(
      id: json['id'].toString(),

      // Si se proporciona desde el contexto, usamos ese valor.
      // Si no, usamos el valor que viene de la API.
      isCardio: isCardio ?? json['isCardio'] ?? false,

      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,

      weightUnit: json['weightUnit'],

      reps: json['reps'] != null ? int.tryParse(json['reps'].toString()) : null,

      durationSeconds: json['durationSeconds'] != null
          ? int.tryParse(json['durationSeconds'].toString())
          : null,

      distanceKm: json['distanceKm'] != null
          ? double.tryParse(json['distanceKm'].toString())
          : null,
    );
  }
}
