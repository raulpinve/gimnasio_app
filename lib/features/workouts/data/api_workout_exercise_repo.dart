import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/core/network/api_client.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_exercise.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_record.dart';
import 'package:gym_app/features/workouts/domain/repos/workout_exercise_repo.dart';

class ApiWorkoutExerciseRepo implements WorkoutExerciseRepo {
  final ApiClient apiClient = ApiClient.instance;

  ApiWorkoutExerciseRepo();

  @override
  Future<List<WorkoutExercise>> getAllWorkoutExercise(
    String workoutId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/workouts-exercises/active',
        queryParameters: {
          'workoutId': workoutId,
        },
      );

      final List data = response.data["data"];

      final List<WorkoutExercise> exercises = data
          .map(
            (item) => WorkoutExercise.fromJSON(item),
          )
          .toList();

      final updatedExercises = await Future.wait(
        exercises.map(
          (exercise) async {
            if (exercise.workoutExerciseId == null) {
              return exercise;
            }

            try {
              List<WorkoutRecord> records = [];

              if (exercise.exerciseType == "cardio") {
                final response = await apiClient.dio.get(
                  '/cardio-logs',
                  queryParameters: {
                    'workoutExerciseId': exercise.workoutExerciseId,
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
                    'workoutExerciseId': exercise.workoutExerciseId,
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

              return exercise.copyWith(
                records: records,
              );
            } catch (e) {
              debugPrint(
                "Error cargando registros ${exercise.exerciseName}: $e",
              );

              return exercise.copyWith(
                records: [],
              );
            }
          },
        ),
      );

      return updatedExercises;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint(
        "Error al obtener los workout exercises: $e",
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
  Future<WorkoutExercise> getWorkoutExerciseById(
    String workoutExerciseId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        "/workouts-exercises/$workoutExerciseId",
      );

      final exercise = WorkoutExercise.fromJSON(
        response.data['data'],
      );

      try {
        List<WorkoutRecord> records = [];

        if (exercise.exerciseType == "cardio") {
          final recordsResponse = await apiClient.dio.get(
            '/cardio-logs',
            queryParameters: {
              'workoutExerciseId': workoutExerciseId,
            },
          );

          final List logs = recordsResponse.data["data"];

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
          final recordsResponse = await apiClient.dio.get(
            '/workout-sets',
            queryParameters: {
              'workoutExerciseId': workoutExerciseId,
            },
          );

          final List sets = recordsResponse.data["data"];

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

        return exercise.copyWith(
          records: records,
        );
      } catch (e) {
        debugPrint(
          "Error cargando records de ${exercise.exerciseName}: $e",
        );
        return exercise;
      }
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint(
        "Error al obtener el workout exercise por Id: $e",
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      throw Exception(
        "Ocurrió un error inesperado.",
      );
    }
  }
}
