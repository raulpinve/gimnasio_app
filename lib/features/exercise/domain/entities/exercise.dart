import 'package:gym_app/core/network/api_client.dart';

class ExerciseDescription {
  final String positionInicial;
  final String ejecucion;
  final String tipsExtra;

  ExerciseDescription({
    required this.positionInicial,
    required this.ejecucion,
    required this.tipsExtra,
  });

  factory ExerciseDescription.fromJson(Map<String, dynamic> json) {
    return ExerciseDescription(
      positionInicial: json['positionInicial'] ?? '',
      ejecucion: json['ejecucion'] ?? '',
      tipsExtra: json['tipsExtra'] ?? '',
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final List<String>? muscleGroups;
  final String equipment;
  final String type;
  final String? videoUrl;
  final String? avatar;
  final String? avatarThumbnail;
  final ExerciseDescription? description;
  final String? suggestedWeight;
  final String? suggestedWeightUnit;
  final String? suggestedDurationSeconds;
  final String? suggestedDistanceKm;

  Exercise({
    required this.id,
    required this.name,
    required this.equipment,
    required this.type,
    required this.videoUrl,
    required this.avatar,
    required this.avatarThumbnail,
    required this.muscleGroups,
    this.description,
    this.suggestedWeight,
    this.suggestedWeightUnit,
    this.suggestedDurationSeconds,
    this.suggestedDistanceKm,
  });

  factory Exercise.fromJSON(Map<String, dynamic> json) {
    // Truco de limpieza rápida en una sola línea para evitar palabras "null" en strings
    String? clean(dynamic val) =>
        val == null || val.toString() == 'null' ? null : val.toString();

    final String apiClient = ApiClient.baseUrl;

    return Exercise(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Ejercicio',
      equipment: json['equipment'] ?? 'Ninguno',
      type: json['type'] ?? 'strength',
      videoUrl: json['video']?.toString(),
      muscleGroups: json['muscleGroups'] != null
          ? List<String>.from(json['muscleGroups'])
          : null,
      avatar: json['avatar'] != null
          ? "$apiClient/uploads/exercises/${json['id']}/${json['avatar']}"
          : null,
      avatarThumbnail: json['avatarThumbnail'] != null
          ? "$apiClient/api/uploads/exercises/${json['id']}/thumb-ejlgjci3dr8la170ivyt2lxqu.webp"
          : null,
      description: json['description'] != null
          ? ExerciseDescription.fromJson(json['description'])
          : null,

      suggestedWeight: clean(json['suggestedWeight']) ?? '0',
      suggestedWeightUnit: clean(json['suggestedWeightUnit']) ?? 'kg',
      suggestedDurationSeconds: clean(json['suggestedDurationSeconds']) ?? '0',
      suggestedDistanceKm: clean(json['suggestedDistanceKm']) ?? '0',
    );
  }

  @override
  String toString() {
    return 'Exercise('
        'id: $id, '
        'name: $name, '
        'equipment: $equipment, '
        'type: $type, '
        'sugWeight: $suggestedWeight, '
        'sugUnit: $suggestedWeightUnit, '
        'muscleGroups: ${muscleGroups ?? "[]"}'
        ')';
  }
}
