import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/meal_model.dart';
import '../../detail/views/detail_screen.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── Header ───────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF1C1917),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            toolbarHeight: 64,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            title: const Text(
              'My Recipes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFB5651D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${favorites.length} saved',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // ── Empty State ───────────────────────────────────
          if (favorites.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EBE3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.favorite_border_rounded,
                          size: 40, color: Color(0xFFB5651D)),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Nothing saved yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C1917),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the heart on any recipe to save it',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9A8F82),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
          // ── List ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverList.separated(
                itemCount: favorites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _FavoriteItem(meal: favorites[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _FavoriteItem extends ConsumerStatefulWidget {
  final MealModel meal;
  const _FavoriteItem({required this.meal});

  @override
  ConsumerState<_FavoriteItem> createState() => _FavoriteItemState();
}

class _FavoriteItemState extends ConsumerState<_FavoriteItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggleFav() {
    _ctrl.forward(from: 0);
    ref.read(favoritesProvider.notifier).toggle(widget.meal);
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailScreen(mealId: meal.id, meal: meal),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [

            // ── Thumbnail ──────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18)),
              child: Hero(
                tag: 'meal-${meal.id}',
                child: CachedNetworkImage(
                  imageUrl: meal.thumbnailUrl ?? '',
                  width: 100, height: 100,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 100, height: 100,
                    color: const Color(0xFFF0EBE3),
                    child: const Icon(Icons.broken_image_rounded,
                        color: Color(0xFFB5651D)),
                  ),
                ),
              ),
            ),

            // ── Info ───────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1C1917),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (meal.area != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EBE3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              meal.area!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF78716C),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (meal.category != null)
                          Text(
                            meal.category!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9A8F82),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Fav button ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ScaleTransition(
                scale: _scale,
                child: GestureDetector(
                  onTap: _toggleFav,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        color: Colors.redAccent, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}