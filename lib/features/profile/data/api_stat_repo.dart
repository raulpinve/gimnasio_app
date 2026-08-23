import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/core/network/api_client.dart';
import 'package:gym_app/features/profile/domain/entities/stats.dart';
import 'package:gym_app/features/profile/domain/repos/stat_repo.dart';

class ApiStatRepo implements StatRepo {
  final ApiClient apiClient = ApiClient.instance;

  @override
  Future<Stats> getStat() async {
    try {
      final response = await apiClient.dio.get('/users/stats');

      return Stats.fromJSON(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al obtener el usuario: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }
}
