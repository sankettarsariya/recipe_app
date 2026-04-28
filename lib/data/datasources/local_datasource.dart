import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/meal_model.dart';

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource(
    favoritesBox: Hive.box<MealModel>('favorites'),
    cacheBox: Hive.box<String>('cache'),
  );
});

class LocalDataSource {
  final Box<MealModel> _favoritesBox;
  final Box<String> _cacheBox;

  LocalDataSource({
    required Box<MealModel> favoritesBox,
    required Box<String> cacheBox,
  })  : _favoritesBox = favoritesBox,
        _cacheBox = cacheBox;

  // ── Favorites ──────────────────────────────────────────────
  List<MealModel> getFavorites() => _favoritesBox.values.toList();

  bool isFavorite(String mealId) => _favoritesBox.containsKey(mealId);

  Future<void> addFavorite(MealModel meal) => _favoritesBox.put(meal.id, meal);

  Future<void> removeFavorite(String mealId) => _favoritesBox.delete(mealId);

  // ── Cache ───────────────────────────────────────────────────
  Future<void> cacheMeals(String key, List<MealModel> meals) async {
    final jsonList = meals.map((m) => m.toJson()).toList();
    await _cacheBox.put(key, jsonEncode(jsonList));
  }

  List<MealModel>? getCachedMeals(String key) {
    final raw = _cacheBox.get(key);
    if (raw == null) return null;
    try {
      final List decoded = jsonDecode(raw) as List;
      return decoded.map((m) => MealModel.fromJson(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheMealDetail(MealModel meal) async {
    await _cacheBox.put('detail_${meal.id}', jsonEncode(meal.toJson()));
  }

  MealModel? getCachedMealDetail(String mealId) {
    final raw = _cacheBox.get('detail_$mealId');
    if (raw == null) return null;
    try {
      return MealModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
