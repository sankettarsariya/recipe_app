import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/home_providers.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 48,
      child: categoriesAsync.when(
        data: (categories) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return ChoiceChip(
                label: const Text('For you'),
                selected: selected == null,
                onSelected: (_) =>
                    ref.read(selectedCategoryProvider.notifier).state = null,
              );
            }
            final cat = categories[index - 1];
            return ChoiceChip(
              label: Text(cat.name),
              selected: selected == cat.name,
              onSelected: (_) =>
                  ref.read(selectedCategoryProvider.notifier).state = cat.name,
            );
          },
        ),
        loading: () => _shimmerChips(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _shimmerChips() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, __) => Container(
        width: 72,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
