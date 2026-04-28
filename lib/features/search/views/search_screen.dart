import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../detail/views/detail_screen.dart';
import '../../home/widgets/meal_card.dart';
import '../providers/search_providers.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Column(
        children: [

          // ── Search Header ─────────────────────────────────
          Container(
            color: const Color(0xFF1C1917),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16, right: 16, bottom: 16,
            ),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),

                // Search field
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      autofocus: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: const Color(0xFFB5651D),
                      decoration: InputDecoration(
                        hintText: 'Search recipes...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: Colors.white.withOpacity(0.5), size: 20),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: query.isNotEmpty
                            ? GestureDetector(
                          onTap: () => ref
                              .read(searchQueryProvider.notifier)
                              .state = '',
                          child: Icon(Icons.close_rounded,
                              color: Colors.white.withOpacity(0.5),
                              size: 18),
                        )
                            : null,
                      ),
                      onChanged: (val) =>
                      ref.read(searchQueryProvider.notifier).state = val,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────
          Expanded(
            child: query.isEmpty
                ? _EmptySearch()
                : resultsAsync.when(
              data: (meals) => meals.isEmpty
                  ? _NoResults(query: query)
                  : _ResultsGrid(meals: meals),
              loading: () => _ShimmerGrid(),
              error: (_, __) => _ErrorState(
                  onRetry: () => ref.invalidate(searchResultsProvider)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty search state ──────────────────────────────────────────
class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBE3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.search_rounded,
                size: 40, color: Color(0xFFB5651D)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Find your recipe',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C1917),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Type a dish name, ingredient or cuisine',
            style: TextStyle(fontSize: 13, color: Color(0xFF9A8F82)),
          ),
          const SizedBox(height: 32),
          // Suggestion chips
          Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: ['Chicken', 'Pasta', 'Indian', 'Dessert', 'Beef', 'Salad']
                .map((s) => _SuggestionChip(label: s))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends ConsumerWidget {
  final String label;
  const _SuggestionChip({required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () =>
      ref.read(searchQueryProvider.notifier).state = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8E4DE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF44403C),
          ),
        ),
      ),
    );
  }
}

// ── No results ──────────────────────────────────────────────────
class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBE3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.no_food_rounded,
                size: 40, color: Color(0xFFB5651D)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No recipes found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C1917),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No results for "$query"',
            style: const TextStyle(fontSize: 13, color: Color(0xFF9A8F82)),
          ),
        ],
      ),
    );
  }
}

// ── Results grid ────────────────────────────────────────────────
class _ResultsGrid extends StatelessWidget {
  final List meals;
  const _ResultsGrid({required this.meals});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Container(width: 3, height: 16, color: const Color(0xFFB5651D)),
              const SizedBox(width: 10),
              Text(
                '${meals.length} recipes found',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1917),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            itemCount: meals.length,
            itemBuilder: (context, index) => MealCard(
              meal: meals[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(
                      mealId: meals[index].id, meal: meals[index]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shimmer grid ────────────────────────────────────────────────
class _ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

// ── Error state ─────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.wifi_off_rounded,
                size: 40, color: Colors.red.shade300),
          ),
          const SizedBox(height: 20),
          const Text('Search failed',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1917))),
          const SizedBox(height: 8),
          const Text('Check your connection',
              style: TextStyle(fontSize: 13, color: Color(0xFF9A8F82))),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1917),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Try again',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}