import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/meal_model.dart';
import '../../../data/repositories/meal_repository.dart';



final mealDetailProvider = FutureProvider.family<MealModel?, String>((ref, mealId) {
  return ref.watch(mealRepositoryProvider).getMealDetail(mealId);
});
