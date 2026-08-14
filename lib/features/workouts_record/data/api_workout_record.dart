import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:gym_app/core/enums/workout_type.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/core/network/api_client.dart';
import 'package:gym_app/features/workouts_record/domain/entities/workout_record.dart';
import 'package:gym_app/features/workouts_record/domain/repos/workout_record_repo.dart';

class ApiWorkoutRecord implements WorkoutRecordRepo {
  final ApiClient apiClient = ApiClient.instance;

  ApiWorkoutRecord();

  @override
  Future<WorkoutRecord> createWorkoutRecord(
    ExerciseType exerciseType,
    Map<String, dynamic> workoutRecordBody,
  ) async {
    try {
      final bool isCardio = exerciseType == ExerciseType.cardio;

      final String url = isCardio ? "/cardio-logs" : "/workout-sets";

      final response = await apiClient.dio.post(
        url,
        data: workoutRecordBody,
      );

      return WorkoutRecord.fromJSON(
        response.data['data'],
        isCardio: isCardio,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al crear el workout record: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<List<WorkoutRecord>> getAllWorkoutRecords(
    String workoutExerciseId,
    ExerciseType exerciseType,
  ) async {
    try {
      List<WorkoutRecord> records = [];

      if (exerciseType == ExerciseType.cardio) {
        final response = await apiClient.dio.get(
          '/cardio-logs',
          queryParameters: {
            'workoutExerciseId': workoutExerciseId,
          },
        );

        final List logs = response.data["data"];

        records = logs.map(
          (log) {
            return WorkoutRecord(
              id: log["id"].toString(),
              isCardio: true,
              durationSeconds: log["durationSeconds"],
              distanceKm: log["distanceKm"] != null
                  ? double.tryParse(
                      log["distanceKm"].toString(),
                    )
                  : null,
            );
          },
        ).toList();
      } else {
        final response = await apiClient.dio.get(
          '/workout-sets',
          queryParameters: {
            'workoutExerciseId': workoutExerciseId,
          },
        );

        final List sets = response.data["data"];

        records = sets.map(
          (set) {
            return WorkoutRecord(
              id: set["id"].toString(),
              isCardio: false,
              weight: set["weight"] != null
                  ? double.tryParse(
                      set["weight"].toString(),
                    )
                  : null,
              weightUnit: set["weightUnit"],
              reps: set["reps"],
            );
          },
        ).toList();
      }

      return records;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint(
        "Error al obtener los registros del workout exercise: $e",
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      throw Exception(
        "Ocurrió un error inesperado.",
      );
    }
  }

  @override
  Future<WorkoutRecord> updateWorkoutRecord(
    String workoutRecordId,
    ExerciseType exerciseType,
    Map<String, dynamic> workoutRecordBody,
  ) async {
    try {
      final bool isCardio = exerciseType == ExerciseType.cardio;

      final String url = isCardio
          ? "/cardio-logs/$workoutRecordId"
          : "/workout-sets/$workoutRecordId";

      final response = await apiClient.dio.patch(
        url,
        data: workoutRecordBody,
      );

      return WorkoutRecord.fromJSON(
        response.data['data'],
        isCardio: isCardio,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al actualizar el workout record: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<void> deleteWorkoutRecord(
    String workoutRecordId,
    ExerciseType exerciseType,
  ) async {
    try {
      final bool isCardio = exerciseType == ExerciseType.cardio;

      final String url = isCardio
          ? "/cardio-logs/$workoutRecordId"
          : "/workout-sets/$workoutRecordId";

      await apiClient.dio.delete(url);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al eliminar el workout record: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }
}
