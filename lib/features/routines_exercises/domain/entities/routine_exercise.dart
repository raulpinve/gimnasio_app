import 'package:gym_app/core/network/api_client.dart';

class RoutineExercise {
  final String id;
  final int? targetSets;
  final int? targetReps;
  final int? targetWeight;
  final int? targetDurationSeconds;
  final double? targetDistanceKm;
  final String? avatar;
  final String? avatarThumbnail;
  final String? exerciseName;
  final String? exerciseType;
  final String? exerciseId;

  RoutineExercise({
    this.targetSets,
    this.targetReps,
    this.targetWeight,
    this.targetDurationSeconds,
    this.targetDistanceKm,
    this.exerciseName,
    this.exerciseType,
    required this.id,
    this.avatar,
    this.avatarThumbnail,
    this.exerciseId,
  });

  factory RoutineExercise.fromJSON(Map<String, dynamic> json) {
    return RoutineExercise(
      id: json['id'] ?? '',
      targetSets: json['targetSets'],
      targetReps: json['targetReps'],
      targetWeight: json['targetWeight'],
      targetDurationSeconds: json['targetDurationSeconds'],
      targetDistanceKm: json['targetDistanceKm'] != null
          ? double.parse(json['targetDistanceKm'].toString())
          : null,
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      exerciseType: json['exerciseType'],
      avatar: json['avatar'] != null
          ? "${ApiClient.baseUrl}/uploads/exercises/${json['exerciseId']}/${json['avatar']}"
          : null,
      avatarThumbnail: json['avatarThumbnail'] != null
          ? "${ApiClient.baseUrl}/uploads/exercises/${json['exerciseId']}/${json['avatarThumbnail']}"
          : null,
    );
  }

  @override
  String toString() {
    return 'RoutineExercise('
        'id: $id, '
        'exerciseName: $exerciseName, '
        'exerciseType: $exerciseType, '
        'targetSets: $targetSets, '
        'targetReps: $targetReps, '
        'targetWeight: $targetWeight, '
        'targetDurationSeconds: $targetDurationSeconds, '
        'targetDistanceKm: $targetDistanceKm'
        ')';
  }
}
