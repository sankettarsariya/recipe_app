# 🍽️ Recipe Discovery App

A production-grade Flutter application demonstrating context-aware recipe suggestions, offline-first architecture, Riverpod state management, and automated CI/CD pipelines.

---

## 📱 Features

### Smart Discovery
- **Time-based suggestions**: Breakfast (5–11 AM) · Lunch (11 AM–4 PM) · Dinner (4–11 PM)
- **Location-based cuisine**: Uses device GPS to detect country → prioritizes regional cuisine
- **Category browsing**: Filter recipes by category with a horizontal chip selector
- **Debounced search**: 400ms debounce prevents unnecessary API calls

### Offline-First
- **Favorites**: Saved locally with Hive — fully accessible offline
- **API caching**: Last-fetched responses stored in Hive — shown on connectivity loss
- **Image caching**: `cached_network_image` handles disk-based image caching
- **Graceful degradation**: Orange banner + cached content when offline (never an empty screen)

### Proactive Engagement
- **Scheduled notifications**: 8:00 AM (Breakfast), 2:00 PM (Lunch), 7:00 PM (Dinner)
- **Permission handling**: Gracefully degrades if location or notification permissions are denied

### UI/UX Polish
- **Shimmer loaders** on every async operation (grid, search, detail)
- **Animated heart** on favorites with spring scale animation
- **Hero transitions** between meal cards and detail view
- **Global error UI**: Snackbars + empty states + retry buttons

---

## 🏗️ Architecture

```
lib/
├── main.dart                    # App entry, Hive init, notifications init
├── core/
│   ├── services/
│   │   ├── context_service.dart    # Time + GPS → meal category/cuisine
│   │   ├── notification_service.dart
│   │   └── connectivity_service.dart
│   └── theme/
│       └── app_theme.dart
├── data/
│   ├── models/
│   │   └── meal_model.dart         # Hive-persisted model + Hive adapter
│   ├── datasources/
│   │   ├── api_datasource.dart     # Dio → TheMealDB API
│   │   └── local_datasource.dart   # Hive favorites + cache boxes
│   └── repositories/
│       └── meal_repository.dart    # Offline-first: API → cache → Hive fallback
└── features/
    ├── home/
    │   ├── providers/home_providers.dart   # FutureProviders for meals & categories
    │   ├── views/home_screen.dart
    │   └── widgets/ (meal_card, meal_grid, category_chips, offline_banner)
    ├── search/
    │   ├── providers/search_providers.dart  # Debounced search via RxDart
    │   └── views/search_screen.dart
    ├── detail/
    │   ├── providers/detail_provider.dart
    │   └── views/detail_screen.dart
    ├── favorites/
    │   ├── providers/favorites_provider.dart  # NotifierProvider
    │   └── views/favorites_screen.dart
    └── splash/
        └── views/splash_screen.dart
```

### State Management — Riverpod

| Provider | Type | Purpose |
|----------|------|---------|
| `mealContextProvider` | `FutureProvider` | Time + GPS context |
| `homeMealsProvider` | `FutureProvider` | Context-aware meal list |
| `categoriesProvider` | `FutureProvider` | Category chip list |
| `selectedCategoryProvider` | `StateProvider` | Active category filter |
| `filteredMealsProvider` | `FutureProvider` | Filtered meal list |
| `searchQueryProvider` | `StateProvider` | Raw search input |
| `searchResultsProvider` | `FutureProvider` | Debounced search results |
| `favoritesProvider` | `NotifierProvider` | Favorites CRUD |
| `isFavoriteProvider` | `Provider.family` | Per-meal favorite status |
| `mealDetailProvider` | `FutureProvider.family` | Detail by meal ID |
| `isOnlineProvider` | `Provider` | Network status |

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.22+ (`flutter --version`)
- Android SDK or Xcode (for iOS)

### Run locally
```bash
git clone <your-repo-url>
cd recipe_app
flutter pub get
flutter run
```

### Run tests
```bash
flutter test
flutter test --coverage
```

### Build release APK manually
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## ⚙️ CI/CD Pipeline

The GitHub Actions workflow at `.github/workflows/main.yml` triggers on every push to `main`:

1. **`flutter analyze`** — lint and static analysis
2. **`dart format`** — formatting check
3. **`flutter test`** — all unit tests
4. **`flutter build apk --release`** — release APK
5. **`softprops/action-gh-release`** — auto-creates a GitHub Release tagged `build-N` and uploads the APK

### How to trigger
Simply push to the `main` branch:
```bash
git add .
git commit -m "feat: initial implementation"
git push origin main
```

Then go to **Releases** tab on GitHub to download the APK.

> **Note**: The `GITHUB_TOKEN` secret is automatically provided by GitHub Actions — no manual configuration needed.

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `dio` | HTTP client |
| `hive_flutter` | Local DB (favorites + cache) |
| `cached_network_image` | Image caching |
| `geolocator` + `geocoding` | Location → country → cuisine |
| `permission_handler` | Runtime permissions |
| `flutter_local_notifications` | Scheduled meal-time notifications |
| `connectivity_plus` | Network status stream |
| `shimmer` | Skeleton loaders |
| `rxdart` | Debounced search stream |
| `timezone` | Accurate local-time notifications |
