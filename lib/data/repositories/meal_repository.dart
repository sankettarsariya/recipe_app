import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/api_datasource.dart';
import '../datasources/local_datasource.dart';
import '../models/meal_model.dart';

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepository(
    api: ref.watch(apiDataSourceProvider),
    local: ref.watch(localDataSourceProvider),
  );
});

class MealRepository {
  final ApiDataSource _api;
  final LocalDataSource _local;

  MealRepository({required ApiDataSource api, required LocalDataSource local})
      : _api = api,
        _local = local;

  /// Fetches meals by category. Returns cached data if network fails.
  Future<List<MealModel>> getMealsByCategory(String category) async {
    try {
      final meals = await _api.getMealsByCategory(category);
      await _local.cacheMeals('cat_$category', meals);
      return meals;
    } on DioException {
      return _local.getCachedMeals('cat_$category') ?? [];
    }
  }

  /// Fetches meal detail. Returns cached detail if network fails.
  Future<MealModel?> getMealDetail(String id) async {
    try {
      final meal = await _api.getMealDetail(id);
      if (meal != null) await _local.cacheMealDetail(meal);
      return meal;
    } on DioException {
      return _local.getCachedMealDetail(id) ??
          _local.getFavorites().where((m) => m.id == id).firstOrNull;
    }
  }

  /// Search with fallback to favorites on error.
  Future<List<MealModel>> searchMeals(String query) async {
    try {
      final meals = await _api.searchMeals(query);
      await _local.cacheMeals('search_$query', meals);
      return meals;
    } on DioException {
      return _local.getCachedMeals('search_$query') ?? [];
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final cats = await _api.getCategories();
      return cats;
    } on DioException {
      return [];
    }
  }

  Future<List<MealModel>> getMealsByArea(String area) async {
    try {
      final meals = await _api.getMealsByArea(area);
      await _local.cacheMeals('area_$area', meals);
      return meals;
    } on DioException {
      return _local.getCachedMeals('area_$area') ?? [];
    }
  }

  Future<MealModel?> getRandomMeal() async {
    try {
      return await _api.getRandomMeal();
    } on DioException {
      final favs = _local.getFavorites();
      if (favs.isNotEmpty) return favs.first;
      return null;
    }
  }

  // ── Favorites ──────────────────────────────────────────────
  List<MealModel> getFavorites() => _local.getFavorites();
  bool isFavorite(String mealId) => _local.isFavorite(mealId);
  Future<void> addFavorite(MealModel meal) => _local.addFavorite(meal);
  Future<void> removeFavorite(String mealId) => _local.removeFavorite(mealId);
}
