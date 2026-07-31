import 'package:dio/dio.dart';
import 'dart:convert';

class ApiError implements Exception {
  final String message;
  final Map<String, dynamic>? fieldErrors;

  ApiError({required this.message, this.fieldErrors});

  @override
  String toString() => message;
}

ApiError handleDioError(DioException e) {
  // 1. Errores de red y timeouts...
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return ApiError(message: "Servidor no responde");
  }
  if (e.type == DioExceptionType.connectionError) {
    return ApiError(message: "No hay conexión con el servidor");
  }

  // 2. Errores con respuesta del servidor
  if (e.response != null) {
    final status = e.response?.statusCode;
    var rawData = e.response?.data; // Cambiado a var para poder transformarlo

    Map<String, dynamic>? data;
    if (rawData is String) {
      try {
        data = jsonDecode(rawData) as Map<String, dynamic>;
      } catch (_) {
        data = null; // No era un JSON válido
      }
    } else if (rawData is Map) {
      data = rawData as Map<String, dynamic>;
    }

    print(rawData);

    // Ahora extraemos el mensaje de forma segura usando el mapa ya normalizado
    final String generalMessage = (data != null)
        ? (data['message']?.toString() ?? "Error desconocido del servidor ")
        : "Error desconocido del servidor";

    if (status == 401) {
      return ApiError(message: generalMessage);
    }
    if (status == 404) {
      return ApiError(message: generalMessage);
    }
    if (status == 500) {
      return ApiError(message: generalMessage);
    }

    // Manejo unificado para errores de validación (400)
    if (status == 400 && data != null) {
      final Map<String, dynamic> errorsMap = {};
      final errorContainer = data['error'];

      if (errorContainer is Map) {
        final fieldErrorsList = errorContainer['fieldErrors'];

        if (fieldErrorsList is List) {
          for (var errorItem in fieldErrorsList) {
            if (errorItem is Map) {
              final field = errorItem['field']?.toString();
              final message = errorItem['message']?.toString();
              if (field != null && message != null) {
                errorsMap[field] = message;
              }
            }
          }
        }
      }

      return ApiError(
        message: generalMessage,
        fieldErrors: errorsMap.isNotEmpty ? errorsMap : null,
      );
    }
    // Para cualquier otro código (como el 404), usa el mensaje extraído del mapa
    return ApiError(message: generalMessage);
  }

  return ApiError(message: "Error de red desconocido");
}
