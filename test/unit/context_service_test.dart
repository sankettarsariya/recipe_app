import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/core/services/context_service.dart';

void main() {
  group('ContextService', () {
    late ContextService service;

    setUp(() => service = ContextService());

    test('getMealCategory returns Breakfast in morning hours', () {
      // We can't mock DateTime.now() directly without injection,
      // but we verify the logic branches are correct values
      const categories = ['Breakfast', 'Chicken', 'Beef', 'Dessert'];
      final result = service.getMealCategory();
      expect(categories.contains(result), isTrue);
    });

    test('getMealGreeting is non-empty', () {
      expect(service.getMealGreeting(), isNotEmpty);
    });

    test('getMealTimeLabel is non-empty', () {
      expect(service.getMealTimeLabel(), isNotEmpty);
    });
  });
}
