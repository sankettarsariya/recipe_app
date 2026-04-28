import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/data/models/meal_model.dart';

void main() {
  group('MealModel', () {
    final testJson = {
      'idMeal': '52772',
      'strMeal': 'Teriyaki Chicken Casserole',
      'strCategory': 'Chicken',
      'strArea': 'Japanese',
      'strInstructions': 'Preheat oven to 350° F.',
      'strMealThumb':
          'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
      'strYoutube': 'https://www.youtube.com/watch?v=4aZr5hZXP_s',
      'strIngredient1': 'soy sauce',
      'strMeasure1': '3/4 cup',
      'strIngredient2': 'water',
      'strMeasure2': '1/2 cup',
      'strIngredient3': '',
      'strMeasure3': '',
    };

    test('fromJson parses correctly', () {
      final meal = MealModel.fromJson(testJson);
      expect(meal.id, '52772');
      expect(meal.name, 'Teriyaki Chicken Casserole');
      expect(meal.category, 'Chicken');
      expect(meal.area, 'Japanese');
      expect(meal.ingredients.length, 2);
      expect(meal.ingredients[0], 'soy sauce');
      expect(meal.measures[0], '3/4 cup');
    });

    test('toJson round-trips correctly', () {
      final meal = MealModel.fromJson(testJson);
      final json = meal.toJson();
      final meal2 = MealModel.fromJson(json);
      expect(meal2.id, meal.id);
      expect(meal2.name, meal.name);
      expect(meal2.ingredients, meal.ingredients);
    });

    test('equality is based on id', () {
      final m1 = MealModel.fromJson(testJson);
      final m2 = m1.copyWith(name: 'Different Name');
      expect(m1, equals(m2));
    });

    test('copyWith updates fields', () {
      final meal = MealModel.fromJson(testJson);
      final updated = meal.copyWith(name: 'Updated');
      expect(updated.name, 'Updated');
      expect(updated.id, meal.id);
    });
  });
}
