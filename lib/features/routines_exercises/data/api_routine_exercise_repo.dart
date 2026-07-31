import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/core/network/api_client.dart';
import 'package:gym_app/features/routines_exercises/domain/entities/routine_exercise.dart';
import 'package:gym_app/features/routines_exercises/domain/repos/routine_exercise_repo.dart';

class ApiRoutineExerciseRepo implements RoutineExerciseRepo {
  final apiClient = ApiClient.instance;
  ApiRoutineExerciseRepo();

  @override
  Future<RoutineExercise> createRoutineExercise({required String name}) async {
    try {
      final response = await apiClient.dio.post(
        '/routine-exercises',
        data: {
          'name': name,
        },
      );
      return RoutineExercise.fromJSON(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error creando los ejercicios de la rutina: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<List<RoutineExercise>> getAllRoutinesExercises({
    int page = 1,
    required String routineId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/routine-exercises/routine/$routineId',
        queryParameters: {
          'routineId': routineId,
        },
      );
      final List data = response.data['data'];

      final routinesExercises = data
          .map((item) => RoutineExercise.fromJSON(item))
          .toList();

      return routinesExercises;
    } on DioException catch (e) {
      print("Error: $e");
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al obtener los ejercicios de la rutina: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<RoutineExercise> getRoutineExercise(String routineExerciseId) async {
    try {
      final response = await apiClient.dio.get(
        "/routine-exercises/$routineExerciseId",
      );
      final Map<String, dynamic> data = response.data["data"];
      return RoutineExercise.fromJSON(data);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al obtener los ejercicios de la rutina: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<RoutineExercise> updateRoutineExercise({
    required String name,
    required String routineExerciseId,
  }) async {
    try {
      final response = await apiClient.dio.patch(
        "/routine-exercises/$routineExerciseId",
        data: {
          'name': name,
        },
      );
      final Map<String, dynamic> data = response.data['data'];
      return RoutineExercise.fromJSON(data);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al actualizar los ejercicios de la rutina: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<void> deleteRoutineExercise(String routineExerciseId) async {
    try {
      await apiClient.dio.delete(
        "/routine-exercises/$routineExerciseId",
        options: Options(responseType: ResponseType.plain),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al eliminar los ejercicios de la rutina: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrio un error inesperado.");
    }
  }
}
