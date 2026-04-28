import 'package:hive/hive.dart';

part 'meal_model.g.dart';

@HiveType(typeId: 0)
class MealModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? category;

  @HiveField(3)
  final String? area;

  @HiveField(4)
  final String? instructions;

  @HiveField(5)
  final String? thumbnailUrl;

  @HiveField(6)
  final List<String> ingredients;

  @HiveField(7)
  final List<String> measures;

  @HiveField(8)
  final String? youtubeUrl;

  MealModel({
    required this.id,
    required this.name,
    this.category,
    this.area,
    this.instructions,
    this.thumbnailUrl,
    this.ingredients = const [],
    this.measures = const [],
    this.youtubeUrl,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final measures = <String>[];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString().trim());
        measures.add(measure?.toString().trim() ?? '');
      }
    }

    return MealModel(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'],
      area: json['strArea'],
      instructions: json['strInstructions'],
      thumbnailUrl: json['strMealThumb'],
      ingredients: ingredients,
      measures: measures,
      youtubeUrl: json['strYoutube'],
    );
  }

  Map<String, dynamic> toJson() => {
        'idMeal': id,
        'strMeal': name,
        'strCategory': category,
        'strArea': area,
        'strInstructions': instructions,
        'strMealThumb': thumbnailUrl,
        'strYoutube': youtubeUrl,
        for (int i = 0; i < ingredients.length; i++) ...{
          'strIngredient${i + 1}': ingredients[i],
          'strMeasure${i + 1}': measures[i],
        },
      };

  MealModel copyWith({
    String? id,
    String? name,
    String? category,
    String? area,
    String? instructions,
    String? thumbnailUrl,
    List<String>? ingredients,
    List<String>? measures,
    String? youtubeUrl,
  }) {
    return MealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      area: area ?? this.area,
      instructions: instructions ?? this.instructions,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      ingredients: ingredients ?? this.ingredients,
      measures: measures ?? this.measures,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CategoryModel {
  final String name;
  final String? thumbnailUrl;
  final String? description;

  const CategoryModel({
    required this.name,
    this.thumbnailUrl,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        name: json['strCategory'] ?? '',
        thumbnailUrl: json['strCategoryThumb'],
        description: json['strCategoryDescription'],
      );
}
