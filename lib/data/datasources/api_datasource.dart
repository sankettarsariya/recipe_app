import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal_model.dart';

final apiDataSourceProvider = Provider<ApiDataSource>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://www.themealdb.com/api/json/v1/1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  dio.interceptors.add(LogInterceptor(responseBody: false));
  return ApiDataSource(dio);
});

class ApiDataSource {
  final Dio _dio;

  ApiDataSource(this._dio);

  Future<List<MealModel>> getMealsByCategory(String category) async {
    final response = await _dio.get('/filter.php', queryParameters: {'c': category});
    final List meals = response.data['meals'] ?? [];
    return meals.map((m) => MealModel.fromJson(m as Map<String, dynamic>)).toList();
  }

  Future<MealModel?> getMealDetail(String id) async {
    final response = await _dio.get('/lookup.php', queryParameters: {'i': id});
    final List meals = response.data['meals'] ?? [];
    if (meals.isEmpty) return null;
    return MealModel.fromJson(meals[0] as Map<String, dynamic>);
  }

  Future<List<MealModel>> searchMeals(String query) async {
    final response = await _dio.get('/search.php', queryParameters: {'s': query});
    final List meals = response.data['meals'] ?? [];
    return meals.map((m) => MealModel.fromJson(m as Map<String, dynamic>)).toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get('/categories.php');
    final List categories = response.data['categories'] ?? [];
    return categories.map((c) => CategoryModel.fromJson(c as Map<String, dynamic>)).toList();
  }

  Future<List<MealModel>> getMealsByArea(String area) async {
    final response = await _dio.get('/filter.php', queryParameters: {'a': area});
    final List meals = response.data['meals'] ?? [];
    return meals.map((m) => MealModel.fromJson(m as Map<String, dynamic>)).toList();
  }

  Future<MealModel?> getRandomMeal() async {
    final response = await _dio.get('/random.php');
    final List meals = response.data['meals'] ?? [];
    if (meals.isEmpty) return null;
    return MealModel.fromJson(meals[0] as Map<String, dynamic>);
  }
}
