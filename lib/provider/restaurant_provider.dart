import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunch_recommendation_app/model/restaurant.dart';
import 'package:lunch_recommendation_app/service/restaurant_service.dart';

final restaurantServiceProvider = Provider((ref) => RestaurantService());

final restaurantProvider =
    StateNotifierProvider<RestaurantNotifier, AsyncValue<List<Restaurant>>>(
        (ref) {
  return RestaurantNotifier(ref.watch(restaurantServiceProvider));
});

final categoriesProvider = FutureProvider.family<List<String>, int>((ref, level) async {
  final restaurantService = ref.watch(restaurantServiceProvider);
  final categoriesMap = await restaurantService.getCategories();
  if (level == 2) {
    return categoriesMap.keys.toList()..sort();
  }
  if (level == 3) {
    final allLevel3 = <String>{};
    categoriesMap.values.forEach((level3List) {
      allLevel3.addAll(List<String>.from(level3List));
    });
    return allLevel3.toList()..sort();
  }
  return [];
});

class RestaurantNotifier extends StateNotifier<AsyncValue<List<Restaurant>>> {
  final RestaurantService _restaurantService;

  RestaurantNotifier(this._restaurantService) : super(const AsyncValue.loading());

  Future<void> getRandomRestaurants() async {
    state = const AsyncValue.loading();
    try {
      final distances = ['100m', '250m', '400m', '600m', '800m', '1000m'];
      final List<Restaurant> recommended = [];

      for (var distance in distances) {
        final restaurants = await _restaurantService.getRestaurants(distance);
        if (restaurants.isNotEmpty) {
          final random = Random();
          recommended.add(restaurants[random.nextInt(restaurants.length)]);
        }
      }
      state = AsyncValue.data(recommended);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> getRestaurantsByCategory(String category, int level) async {
    state = const AsyncValue.loading();
    try {
      final distances = ['100m', '250m', '400m', '600m', '800m', '1000m'];
      final List<Restaurant> recommended = [];

      for (var distance in distances) {
        var restaurants = await _restaurantService.getRestaurants(distance);
        var filteredRestaurants = restaurants.where((r) {
          var catParts = r.category.split(' > ');
          if (catParts.length < 2) return false;

          if (level == 2) {
            return catParts[1] == category;
          }
          if (level == 3) {
            return (catParts.length > 2 && catParts[2] == category) ||
                   (catParts.length == 2 && catParts[1] == category);
          }
          return false;
        }).toList();

        if (filteredRestaurants.isNotEmpty) {
          final random = Random();
          recommended.add(
              filteredRestaurants[random.nextInt(filteredRestaurants.length)]);
        }
      }
      state = AsyncValue.data(recommended);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
