import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/meal_model.dart';
import '../../favorites/providers/favorites_provider.dart';

class MealCard extends ConsumerWidget {
  final MealModel meal;
  final VoidCallback onTap;

  const MealCard({super.key, required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'meal-${meal.id}',
                    child: CachedNetworkImage(
                      imageUrl: meal.thumbnailUrl ?? '',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade100,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.broken_image_rounded,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Area tag
                  if (meal.area != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(meal.area!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _FavoriteButton(meal: meal),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (meal.category != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.local_dining_rounded,
                              size: 10, color: Colors.grey.shade400),
                          const SizedBox(width: 3),
                          Text(meal.category!,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends ConsumerStatefulWidget {
  final MealModel meal;
  const _FavoriteButton({required this.meal});

  @override
  ConsumerState<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    // Fix: use standard 0..1 controller + Tween to scale 1.0 → 1.3 → 1.0
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

  void _toggle() {
    _ctrl.forward(from: 0); // always restart from 0
    ref.read(favoritesProvider.notifier).toggle(widget.meal);
  }

  @override
  Widget build(BuildContext context) {
    final isFav = ref.watch(isFavoriteProvider(widget.meal.id));
    return GestureDetector(
      onTap: _toggle,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isFav ? Colors.red.shade50 : Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)
            ],
          ),
          child: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: isFav ? Colors.redAccent : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
