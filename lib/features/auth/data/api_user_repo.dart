import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/core/network/api_client.dart';
import 'package:gym_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_app/features/auth/domain/repos/user_repo.dart';

class ApiUserRepo implements UserRepo {
  final ApiClient apiClient;

  ApiUserRepo({
    required this.apiClient,
  });

  @override
  Future<AppUser> getCurrentUser() async {
    try {
      final response = await apiClient.dio.get('/auth/me');

      return AppUser.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al obtener el usuario: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }

  @override
  Future<void> createCurrentUser({
    required String firstName,
    required String lastName,
    required String username,
  }) async {
    try {
      await apiClient.dio.post(
        '/auth/me',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
        },
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e, stackTrace) {
      debugPrint("Error al crear el usuario: $e");
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Ocurrió un error inesperado.");
    }
  }
}
