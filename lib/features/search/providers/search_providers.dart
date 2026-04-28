import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/models/meal_model.dart';
import '../../../data/repositories/meal_repository.dart';

// Raw query input
final searchQueryProvider = StateProvider<String>((ref) => '');

// Debounced stream (400ms)
final _debouncedQueryProvider = StreamProvider<String>((ref) {
  final controller = BehaviorSubject<String>();

  ref.listen<String>(searchQueryProvider, (_, next) {
    controller.add(next);
  });

  ref.onDispose(controller.close);

  return controller.stream
      .debounceTime(const Duration(milliseconds: 400))
      .distinct();
});

// Search results provider
final searchResultsProvider = FutureProvider<List<MealModel>>((ref) async {
  final debounced = ref.watch(_debouncedQueryProvider);

  return debounced.when(
    data: (query) async {
      if (query.trim().isEmpty) return [];
      return ref.watch(mealRepositoryProvider).searchMeals(query.trim());
    },
    loading: () async => [],
    error: (_, __) async => [],
  );
});
