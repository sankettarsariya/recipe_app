import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/context_service.dart';
import '../../../data/models/meal_model.dart';
import '../../../data/repositories/meal_repository.dart';



// ── Context ──────────────────────────────────────────────────
final mealContextProvider = FutureProvider<MealContext>((ref) async {
  final contextService = ref.watch(contextServiceProvider);
  return contextService.getFullContext();
});

// ── Meals by context (time + location) ───────────────────────
final homeMealsProvider = FutureProvider<List<MealModel>>((ref) async {
  final repo = ref.watch(mealRepositoryProvider);
  final contextAsync = ref.watch(mealContextProvider);

  return contextAsync.when(
    data: (ctx) async {
      if (ctx.suggestedArea != null) {
        final areaMeals = await repo.getMealsByArea(ctx.suggestedArea!);
        if (areaMeals.isNotEmpty) return areaMeals;
      }
      return repo.getMealsByCategory(ctx.category);
    },
    loading: () async => [],
    error: (_, __) async => repo.getMealsByCategory('Chicken'),
  );
});

// Categories
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(mealRepositoryProvider).getCategories();
});

//  Selected category filter
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredMealsProvider = FutureProvider<List<MealModel>>((ref) async {
  final selected = ref.watch(selectedCategoryProvider);
  final repo = ref.watch(mealRepositoryProvider);

  if (selected == null) {
    return ref.watch(homeMealsProvider.future);
  }
  return repo.getMealsByCategory(selected);
});
