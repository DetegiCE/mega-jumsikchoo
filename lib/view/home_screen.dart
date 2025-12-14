import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunch_recommendation_app/provider/restaurant_provider.dart';
import 'package:lunch_recommendation_app/view/category_selection_screen.dart';
import 'package:lunch_recommendation_app/view/restaurant_list_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('점심 식당 추천'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                ref.read(restaurantProvider.notifier).getRandomRestaurants();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const RestaurantListView(title: '랜덤 추천'),
                  ),
                );
              },
              child: const Text('랜덤 추천'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategorySelectionScreen(
                      level: 2,
                      title: '카테고리별 추천',
                    ),
                  ),
                );
              },
              child: const Text('카테고리별 추천'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategorySelectionScreen(
                      level: 3,
                      title: '세부 카테고리별 추천',
                    ),
                  ),
                );
              },
              child: const Text('세부 카테고리별 추천'),
            ),
          ],
        ),
      ),
    );
  }
}
