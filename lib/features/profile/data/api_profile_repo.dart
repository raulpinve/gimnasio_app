import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/core/network/api_client.dart';
import 'package:gym_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_app/features/profile/domain/repos/profile_repo.dart';

class ApiProfileRepo implements ProfileRepo {
  final apiClient = ApiClient.instance;
  ApiProfileRepo();

  @override
  Future<AppUser> updateProfile(
    Map<String, dynamic> profileBody,
  ) async {
    try {
      final response = await apiClient.dio.put(
        "/users",
        data: profileBody,
      );
      final Map<String, dynamic> data = response.data['data'];
      return AppUser.fromJson(data);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al actualizar el perfil del usuario: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }
}
