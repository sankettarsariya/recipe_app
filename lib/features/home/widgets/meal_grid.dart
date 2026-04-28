import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../features/detail/views/detail_screen.dart';
import '../providers/home_providers.dart';
import 'meal_card.dart';

class MealGrid extends ConsumerWidget {
  const MealGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(filteredMealsProvider);

    return mealsAsync.when(
      data: (meals) {
        if (meals.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.no_food_rounded,
                        size: 36, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  Text('No recipes found',
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Try a different category',
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                ],
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          sliver: SliverGrid.builder(
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
                          mealId: meals[index].id, meal: meals[index]))),
            ),
          ),
        );
      },
      loading: () => SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.78,
          ),
          itemCount: 8,
          itemBuilder: (_, __) => const _ShimmerCard(),
        ),
      ),
      error: (_, __) => SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.wifi_off_rounded,
                    size: 36, color: Colors.red.shade300),
              ),
              const SizedBox(height: 16),
              const Text('Could not load recipes',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 6),
              Text('Check your internet connection',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => ref.invalidate(filteredMealsProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        height: 12,
                        width: double.infinity,
                        color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 10, width: 80, color: Colors.white),
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
