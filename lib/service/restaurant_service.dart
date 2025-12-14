import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:lunch_recommendation_app/model/restaurant.dart';

class RestaurantService {
  Future<List<Restaurant>> getRestaurants(String distance) async {
    final String response =
        await rootBundle.loadString('assets/data/restaurants_$distance.json');
    final data = await json.decode(response) as List;
    return data.map((e) => Restaurant.fromJson(e)).toList();
  }

  Future<List<Restaurant>> getAllRestaurants() async {
    final String response =
        await rootBundle.loadString('assets/data/restaurants.json');
    final data = await json.decode(response) as List;
    return data.map((e) => Restaurant.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getCategories() async {
    final String response =
        await rootBundle.loadString('assets/data/categories.json');
    final data = await json.decode(response) as Map<String, dynamic>;
    return data;
  }
}
