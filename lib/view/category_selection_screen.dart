import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunch_recommendation_app/provider/restaurant_provider.dart';
import 'package:lunch_recommendation_app/view/restaurant_list_view.dart';

class CategorySelectionScreen extends ConsumerWidget {
  final int level;
  final String title;

  const CategorySelectionScreen(
      {super.key, required this.level, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ref.watch(categoriesProvider(level)).when(
            data: (categories) {
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category),
                    onTap: () {
                      ref
                          .read(restaurantProvider.notifier)
                          .getRestaurantsByCategory(category, level);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RestaurantListView(title: category),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('에러 발생: $error')),
          ),
    );
  }
}
