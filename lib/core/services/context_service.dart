import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

final contextServiceProvider =
    Provider<ContextService>((ref) => ContextService());

// Country → Cuisine mapping for TheMealDB areas
const _countryCuisineMap = {
  'IN': 'Indian',
  'CN': 'Chinese',
  'JP': 'Japanese',
  'TH': 'Thai',
  'IT': 'Italian',
  'FR': 'French',
  'MX': 'Mexican',
  'US': 'American',
  'GB': 'British',
  'GR': 'Greek',
  'ES': 'Spanish',
  'TR': 'Turkish',
  'MA': 'Moroccan',
  'EG': 'Egyptian',
  'PH': 'Filipino',
  'VN': 'Vietnamese',
  'KR': 'Korean',
  'CA': 'Canadian',
  'NG': 'Nigerian',
  'JM': 'Jamaican',
};

class MealContext {
  final String category;
  final String greeting;
  final String? suggestedArea;

  const MealContext({
    required this.category,
    required this.greeting,
    this.suggestedArea,
  });
}

class ContextService {
  /// Returns meal category based on current hour
  String getMealCategory() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Breakfast';
    if (hour >= 11 && hour < 16) return 'Chicken'; // Lunch
    if (hour >= 16 && hour < 23) return 'Beef'; // Dinner
    return 'Dessert'; // Late night
  }

  String getMealGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Good morning!';
    if (hour >= 11 && hour < 16) return 'Good afternoon!';
    if (hour >= 16 && hour < 20) return 'Good evening!';
    return 'Late night cravings? 🌙';
  }

  String getMealTimeLabel() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Breakfast ideas';
    if (hour >= 11 && hour < 16) return 'Lunch ideas';
    if (hour >= 16 && hour < 23) return 'Dinner ideas';
    return 'Late night bites';
  }

  /// Tries to get user's cuisine area from GPS. Returns null if denied.
  Future<String?> getCuisineFromLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;

      final countryCode = placemarks.first.isoCountryCode ?? '';
      return _countryCuisineMap[countryCode.toUpperCase()];
    } catch (_) {
      return null;
    }
  }

  Future<MealContext> getFullContext() async {
    final category = getMealCategory();
    final greeting = getMealGreeting();
    final area = await getCuisineFromLocation();
    return MealContext(
        category: category, greeting: greeting, suggestedArea: area);
  }
}
