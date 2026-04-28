import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/meal_model.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../providers/detail_provider.dart';

class DetailScreen extends ConsumerWidget {
  final String mealId;
  final MealModel meal;

  const DetailScreen({super.key, required this.mealId, required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(mealDetailProvider(mealId));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Image AppBar ─────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color(0xFF1C1917),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            actions: [
              _FavButton(meal: meal),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'meal-$mealId',
                    child: CachedNetworkImage(
                      imageUrl: meal.thumbnailUrl ?? '',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(color: Colors.white),
                      ),
                    ),
                  ),
                  // Bottom gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            const Color(0xFF1C1917),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Area + category tags bottom left
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Row(
                      children: [
                        if (meal.area != null) _HeroTag(meal.area!),
                        if (meal.area != null && meal.category != null)
                          const SizedBox(width: 6),
                        if (meal.category != null) _HeroTag(meal.category!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────
          detailAsync.when(
            data: (detail) {
              final m = detail ?? meal;
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title block ────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 10),
                      child: Text(
                        m.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          height: 1.2,
                        ),
                      ),
                    ),

                    // ── White content card ─────────────────
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAF9F6),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 12),
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E4DE),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Ingredients ──────────────────
                          _SectionLabel(
                              'INGREDIENTS', '${m.ingredients.length} items'),
                          const SizedBox(height: 14),

                          ...List.generate(m.ingredients.length, (i) {
                            final isLast = i == m.ingredients.length - 1;
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: !isLast
                                    ? const Border(
                                        bottom: BorderSide(
                                            color: Color(0xFFEFEBE4), width: 1))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFB5651D),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      m.ingredients[i],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1C1917),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0EBE3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      m.measures[i],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF78716C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 32),

                          // ── Instructions ─────────────────
                          if (m.instructions != null) ...[
                            _SectionLabel('INSTRUCTIONS', null),
                            const SizedBox(height: 14),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                m.instructions!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.8,
                                  color: Color(0xFF44403C),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],

                          // ── YouTube button ────────────────
                          if (m.youtubeUrl != null && m.youtubeUrl!.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: GestureDetector(
                                onTap: () =>
                                    launchUrl(Uri.parse(m.youtubeUrl!)),
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C1917),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.play_circle_filled_rounded,
                                          color: Color(0xFFB5651D), size: 22),
                                      SizedBox(width: 10),
                                      Text(
                                        'Watch on YouTube',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },

            // ── Loading ──────────────────────────────────────
            loading: () => SliverToBoxAdapter(
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 32, width: 240, color: Colors.white),
                      const SizedBox(height: 24),
                      Container(height: 14, width: 100, color: Colors.white),
                      const SizedBox(height: 16),
                      ...List.generate(
                          6,
                          (_) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                        width: 8,
                                        height: 8,
                                        color: Colors.white),
                                    const SizedBox(width: 14),
                                    Expanded(
                                        child: Container(
                                            height: 14, color: Colors.white)),
                                    const SizedBox(width: 12),
                                    Container(
                                        width: 50,
                                        height: 26,
                                        color: Colors.white),
                                  ],
                                ),
                              )),
                    ],
                  ),
                ),
              ),
            ),

            // ── Error ────────────────────────────────────────
            error: (_, __) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          color: Colors.orange, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Offline — showing cached data',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF78716C)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ───────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionLabel(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(width: 3, height: 16, color: const Color(0xFFB5651D)),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Color(0xFF1C1917),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 8),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9A8F82),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Hero image tag ──────────────────────────────────────────────
class _HeroTag extends StatelessWidget {
  final String label;
  const _HeroTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Animated Favorite Button ────────────────────────────────────
class _FavButton extends ConsumerStatefulWidget {
  final MealModel meal;
  const _FavButton({required this.meal});

  @override
  ConsumerState<_FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends ConsumerState<_FavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    _ctrl.forward(from: 0);
    ref.read(favoritesProvider.notifier).toggle(widget.meal);
  }

  @override
  Widget build(BuildContext context) {
    final isFav = ref.watch(isFavoriteProvider(widget.meal.id));
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          width: 38,
          height: 38,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: isFav
                ? Colors.redAccent.withOpacity(0.9)
                : Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
