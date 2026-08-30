import 'package:dio/dio.dart';
import 'package:gym_app/core/network/auth_interceptor.dart';

class ApiClient {
  late final Dio dio;
  // static const String baseUrl = 'http://10.0.2.2:3000/api';https://fitness.gestorempresarial.cloud/
  static const String baseUrl = 'https://fitness.gestorempresarial.cloud/api';

  // 1. Crear una instancia estática y privada de la misma clase
  static final ApiClient _instance = ApiClient._internal();

  // 2. Un getter público para acceder a esa única instancia desde afuera
  static ApiClient get instance => _instance;

  // 3. Convertir el constructor actual en un constructor privado (_internal)
  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiClient.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(),
    );
  }
}
