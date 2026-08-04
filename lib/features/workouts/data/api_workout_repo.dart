import 'package:dio/dio.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/core/network/api_client.dart';
import 'package:gym_app/features/workouts/domain/entities/workout.dart';
import 'package:gym_app/features/workouts/domain/entities/workout_pagination.dart';
import 'package:gym_app/features/workouts/domain/repos/workout_repo.dart';
import 'package:flutter/foundation.dart';

class ApiWorkoutRepo implements WorkoutRepo {
  final ApiClient apiClient = ApiClient.instance;

  @override
  Future<Workout> createWorkout({
    required Map<String, dynamic> workoutBody,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/workouts',
        data: workoutBody,
      );
      return Workout.fromJSON(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      debugPrint("Error creando el workout: $e");
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<WorkoutPagination> getAllWorkouts({int page = 1}) async {
    try {
      final response = await apiClient.dio.get(
        '/workouts',
        queryParameters: {
          'page': page,
        },
      );

      final List data = response.data["data"];

      final workouts = data.map((item) => Workout.fromJSON(item)).toList();
      final pagination = response.data["pagination"];

      return WorkoutPagination(
        workouts: workouts,
        currentPage: pagination['currentPage'] ?? 1,
        totalPages: pagination['totalPages'] ?? 1,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al obtener todos los workouts: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<Workout> getWorkout(String id) async {
    try {
      final response = await apiClient.dio.get('/workouts/$id');
      final Map<String, dynamic> data = response.data["data"];
      return Workout.fromJSON(data);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      debugPrint("Error al obtener el workout: $e");
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<Workout> updateWorkout(
    String workoutId,
    Map<String, dynamic> workoutBody,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/routines',
        data: workoutBody,
      );
      return Workout.fromJSON(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      debugPrint("Error actualizando workout: $e");
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<bool> deleteWorkout(String workoutId) async {
    try {
      await apiClient.dio.delete('/workouts/$workoutId');
      return true;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al eliminar el entrenamiento: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }
}
