import 'package:gym_app/core/network/api_client.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_record.dart';

class WorkoutExercise {
  final String? workoutExerciseId;
  final String? exerciseId;
  final String? exerciseName;
  final String? exerciseType;
  final String? avatarThumbnail;
  final String? avatar;

  final String? targetSets;
  final String? targetReps;
  final String? targetWeight;

  final String? targetDurationSeconds;
  final String? targetDistanceKm;

  final String? personalRecord;
  final String? suggestedWeight;
  final String? suggestedWeightUnit;

  final List<WorkoutRecord> records;

  WorkoutExercise({
    required this.workoutExerciseId,
    this.exerciseId,
    this.exerciseName,
    this.exerciseType,
    this.avatar,
    this.avatarThumbnail,
    this.targetSets,
    this.targetReps,
    this.targetWeight,
    this.targetDurationSeconds,
    this.targetDistanceKm,
    this.personalRecord,
    this.suggestedWeight,
    this.suggestedWeightUnit,
    this.records = const [],
  });

  WorkoutExercise copyWith({
    List<WorkoutRecord>? records,
  }) {
    return WorkoutExercise(
      workoutExerciseId: workoutExerciseId,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      exerciseType: exerciseType,
      avatar: avatar,
      avatarThumbnail: avatarThumbnail,
      targetSets: targetSets,
      targetReps: targetReps,
      targetWeight: targetWeight,
      targetDurationSeconds: targetDurationSeconds,
      targetDistanceKm: targetDistanceKm,
      personalRecord: personalRecord,
      suggestedWeight: suggestedWeight,
      suggestedWeightUnit: suggestedWeightUnit,
      records: records ?? this.records,
    );
  }

  factory WorkoutExercise.fromJSON(Map<String, dynamic> json) {
    final String apiClient = ApiClient.baseUrl;

    return WorkoutExercise(
      workoutExerciseId: json['workoutExerciseId']?.toString(),

      exerciseId: json['exerciseId']?.toString(),

      exerciseName: json['exerciseName'],

      exerciseType: json['exerciseType'],

      avatar: json['exerciseAvatar'] != null
          ? "$apiClient/uploads/exercises/${json['exerciseId']}/${json['exerciseAvatar']}"
          : null,

      avatarThumbnail: json['exerciseAvatarThumbnail'] != null
          ? "$apiClient/uploads/exercises/${json['exerciseId']}/${json['exerciseAvatarThumbnail']}"
          : null,

      targetSets: json['targetSets']?.toString(),

      targetReps: json['targetReps']?.toString(),

      targetWeight: json['targetWeight']?.toString(),

      targetDurationSeconds: json['targetDurationSeconds']?.toString(),

      targetDistanceKm: json['targetDistanceKm']?.toString(),

      personalRecord: json['personalRecord']?.toString(),

      suggestedWeight: json['suggestedWeight']?.toString(),

      suggestedWeightUnit: json['suggestedWeightUnit']?.toString(),

      records: json['records'] != null
          ? (json['records'] as List)
                .map(
                  (e) => WorkoutRecord.fromJSON(e),
                )
                .toList()
          : [],
    );
  }
}
