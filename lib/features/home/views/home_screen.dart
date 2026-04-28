import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/connectivity_service.dart';
import '../../../core/services/notification_service.dart';
import '../../favorites/views/favorites_screen.dart';
import '../../search/views/search_screen.dart';
import '../providers/home_providers.dart';
import '../widgets/category_chips.dart';
import '../widgets/meal_grid.dart';
import '../widgets/offline_banner.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(mealContextProvider);
    final isOnline = ref.watch(isOnlineProvider);

    // Force dark status bar icons on light bg
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── HEADER ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ClassicHeader(contextAsync: contextAsync, ref: ref),
          ),

          // ── OFFLINE ────────────────────────────────────────
          if (!isOnline)
            const SliverToBoxAdapter(child: OfflineBanner()),

          // ── DIVIDER + SECTION ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFFE8E4DE), thickness: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Browse by Category',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.8,
                          color: Color(0xFF9A8F82),
                        ),
                      ),
                      contextAsync.maybeWhen(
                        data: (ctx) => _MealTimeBadge(category: ctx.category),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // ── CATEGORY CHIPS ─────────────────────────────────
          const SliverToBoxAdapter(child: CategoryChips()),

          // ── FOR YOU LABEL ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: Row(
                children: [
                  Container(width: 3, height: 18, color: const Color(0xFFB5651D)),
                  const SizedBox(width: 10),
                  const Text(
                    'Curated for You',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Color(0xFF1C1917),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── GRID ───────────────────────────────────────────
          const MealGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Classic Header ──────────────────────────────────────────────
class _ClassicHeader extends StatelessWidget {
  final AsyncValue contextAsync;
  final WidgetRef ref;

  const _ClassicHeader({required this.contextAsync, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAF9F6),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top nav row ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo / brand mark
                Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1917),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.restaurant_menu_rounded,
                          size: 17, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'SAVEUR',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: Color(0xFF1C1917),
                      ),
                    ),
                  ],
                ),
                // Action buttons
                Row(
                  children: [
                    _NavIcon(
                      icon: Icons.search_rounded,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SearchScreen())),
                    ),
                    const SizedBox(width: 4),
                    _NavIcon(
                      icon: Icons.favorite_border_rounded,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const FavoritesScreen())),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Greeting + hero text ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: contextAsync.when(
              data: (ctx) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EBE3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getMealEmoji(ctx.category),
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ctx.greeting,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF78716C),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Hero headline
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: -1.2,
                        color: Color(0xFF1C1917),
                      ),
                      children: [
                        const TextSpan(text: "What's for\n"),
                        TextSpan(
                          text: _getMealLabel(ctx.category),
                          style: const TextStyle(
                            color: Color(0xFFB5651D),
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const TextSpan(text: ' today?'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Location line
                  if (ctx.suggestedArea != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: Color(0xFF9A8F82)),
                        const SizedBox(width: 4),
                        Text(
                          '${ctx.suggestedArea} cuisine recommended near you',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9A8F82),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 30, width: 140,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0EBE3),
                          borderRadius: BorderRadius.circular(20))),
                  const SizedBox(height: 14),
                  Container(height: 38, width: 260, color: const Color(0xFFE8E4DE)),
                  const SizedBox(height: 8),
                  Container(height: 38, width: 200, color: const Color(0xFFE8E4DE)),
                ],
              ),
              error: (_, __) => const Text(
                "Discover\nRecipes",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -1.2,
                  color: Color(0xFF1C1917),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String _getMealEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast': return '🌅';
      case 'chicken': case 'beef': case 'lamb': return '☀️';
      case 'dessert': return '🌙';
      default: return '🍽️';
    }
  }

  String _getMealLabel(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast': return 'breakfast';
      case 'chicken': case 'beef': case 'lamb': case 'pork': return 'lunch';
      case 'dessert': return 'dessert';
      default: return 'dinner';
    }
  }
}

// ── Meal Time Badge ─────────────────────────────────────────────
class _MealTimeBadge extends StatelessWidget {
  final String category;
  const _MealTimeBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1917),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Nav Icon Button ─────────────────────────────────────────────
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF0EBE3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1C1917)),
      ),
    );
  }
}