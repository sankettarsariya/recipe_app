import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/meal_model.dart';
import '../../../data/repositories/meal_repository.dart';


class FavoritesNotifier extends Notifier<List<MealModel>> {
  @override
  List<MealModel> build() {
    return ref.watch(mealRepositoryProvider).getFavorites();
  }

  Future<void> toggle(MealModel meal) async {
    final repo = ref.read(mealRepositoryProvider);
    if (repo.isFavorite(meal.id)) {
      await repo.removeFavorite(meal.id);
    } else {
      await repo.addFavorite(meal);
    }
    state = repo.getFavorites();
  }

  bool isFavorite(String mealId) {
    return ref.read(mealRepositoryProvider).isFavorite(mealId);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<MealModel>>(
  FavoritesNotifier.new,
);

// Convenience bool provider for a specific meal
final isFavoriteProvider = Provider.family<bool, String>((ref, mealId) {
  ref.watch(favoritesProvider); // rebuild when favorites change
  return ref.read(mealRepositoryProvider).isFavorite(mealId);
});
