import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/core/network/api_client.dart';
import 'package:gym_app/features/routines/domain/entities/routine.dart';
import 'package:gym_app/features/routines/domain/entities/routine_pagination.dart';
import 'package:gym_app/features/routines/domain/repos/routine_repo.dart';

class ApiRoutineRepo implements RoutineRepo {
  final ApiClient apiClient = ApiClient.instance;
  ApiRoutineRepo();

  @override
  Future<RoutinePagination> getAllRoutines({
    int page = 1,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/routines',
        queryParameters: {
          'page': page,
        },
      );

      final List data = response.data["data"];

      final routines = data.map((item) => Routine.fromJSON(item)).toList();
      final pagination = response.data["pagination"];

      return RoutinePagination(
        routines: routines,
        currentPage: pagination['currentPage'] ?? 1,
        totalPages: pagination['totalPages'] ?? 1,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al eliminar rutina: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<Routine> createRoutine({required String name}) async {
    try {
      final response = await apiClient.dio.post(
        '/routines',
        data: {
          "name": name,
        },
      );
      return Routine.fromJSON(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      debugPrint("Error creando rutina: $e");
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<Routine> getRoutine(String id) async {
    try {
      final response = await apiClient.dio.get('/routines/$id');
      final Map<String, dynamic> data = response.data["data"];
      return Routine.fromJSON(data);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      debugPrint("Error al obtener rutina: $e");
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<bool> deleteRoutine(String routineId) async {
    try {
      await apiClient.dio.delete('/routines/$routineId');
      return true;
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al eliminar rutina: $e");
      debugPrintStack(stackTrace: stackTrace);

      throw Exception("Ocurrió un error inesperado.");
    }
  }
}
