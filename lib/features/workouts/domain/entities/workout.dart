class Workout {
  final String id;
  final String name;
  final String routineName;
  final String estado;
  final String? duracion;
  final String? fecha;

  Workout({
    required this.id,
    required this.name,
    required this.routineName,
    required this.estado,
    this.duracion,
    required this.fecha,
  });

  factory Workout.fromJSON(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'] ?? "Workout",
      routineName: json['routineName'] ?? "Rutina",
      estado: json['estado'] ?? "abierto",
      duracion: json['duracion'] ?? "",
      fecha: json['fecha'] ?? "",
    );
  }
}
