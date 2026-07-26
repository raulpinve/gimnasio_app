import 'package:dio/dio.dart';
import 'package:gym_app/core/errors/api_error_handler.dart';
import 'package:gym_app/core/network/api_client.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise_pagination.dart';
import 'package:gym_app/features/exercise/domain/entities/exercise_progress.dart';
import 'package:gym_app/features/exercise/domain/repos/exercise_repo.dart';

class ApiExerciseRepo implements ExerciseRepo {
  final ApiClient apiClient = ApiClient.instance;
  ApiExerciseRepo();

  @override
  Future<ExercisePagination> getAllExercises({
    int page = 1,
    String name = "",
    String muscleGroup = "",
  }) async {
    try {
      final response = await apiClient.dio.get(
        '/exercises',
        queryParameters: {
          'page': page,
          if (name.isNotEmpty) 'name': name,
          if (muscleGroup.isNotEmpty) 'muscleGroup': muscleGroup,
        },
      );

      final List data = response.data["data"];

      final exercises = data
          .map(
            (item) => Exercise.fromJSON(item),
          )
          .toList();

      final pagination = response.data['pagination'];

      return ExercisePagination(
        exercises: exercises,
        currentPage: pagination['currentPage'] ?? 1,
        totalPages: pagination['totalPages'] ?? 1,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception(
        "Error inesperado: $e",
      );
    }
  }

  @override
  Future<Exercise> createExercise({
    required String name,
    required List<String> muscleGroups,
    String? equipment,
    required String type,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/exercises',
        data: {
          'name': name,
          'muscleGroups': muscleGroups,
          'equipment': equipment,
          'type': type,
        },
      );

      return Exercise.fromJSON(response.data['data']);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception(
        "Error inesperado: $e",
      );
    }
  }

  @override
  Future<Exercise> getExercise(String id) async {
    try {
      final response = await apiClient.dio.get('/exercises/$id');
      final Map<String, dynamic> data = response.data["data"];
      return Exercise.fromJSON(data);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

  @override
  Future<(List<ExerciseProgress> progressList, String unit)>
  getExerciseProgress(
    String exerciseId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/exercises/$exerciseId/progress',
      );

      final Map<String, dynamic> responseData = response.data;

      final progressList = (responseData['data'] as List? ?? [])
          .map(
            (item) => ExerciseProgress.fromJson(item as Map<String, dynamic>),
          )
          .toList();
      final unit = responseData['unit']?.toString() ?? 'kg';

      return (progressList, unit);
    } on DioException catch (e) {
      throw handleDioError(e);
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }
}
