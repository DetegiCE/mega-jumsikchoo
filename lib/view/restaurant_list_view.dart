import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunch_recommendation_app/provider/restaurant_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantListView extends ConsumerWidget {
  final String title;

  const RestaurantListView({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantState = ref.watch(restaurantProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: restaurantState.when(
        data: (restaurants) {
          if (restaurants.isEmpty) {
            return const Center(
              child: Text('추천할 식당이 없습니다.'),
            );
          }
          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(restaurant.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(restaurant.category),
                      Text(restaurant.roadAddress),
                      if (restaurant.phone.isNotEmpty) Text(restaurant.phone),
                    ],
                  ),
                  onTap: () async {
                    final url = Uri.parse(restaurant.url);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('지도를 열 수 없습니다: ${restaurant.url}'),
                        ),
                      );
                    }
                  },
                ),
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
