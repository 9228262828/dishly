import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class DishlyStore extends ChangeNotifier {
  static const _dataKey = 'dishly_restaurants_v1';
  static const _darkKey = 'dishly_dark_v1';

  final List<Restaurant> restaurants = [];
  bool darkMode = false;
  bool ready = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool(_darkKey) ?? false;
    final raw = prefs.getString(_dataKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        restaurants
          ..clear()
          ..addAll(decoded.whereType<Map>().map(
                (e) => Restaurant.fromJson(Map<String, dynamic>.from(e)),
              ));
      } catch (_) {
        restaurants.clear();
      }
    }

    ready = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _dataKey,
      jsonEncode(restaurants.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addRestaurant(Restaurant value) async {
    restaurants.add(value);
    await _save();
    notifyListeners();
  }

  Future<void> updateRestaurant(Restaurant value) async {
    final i = restaurants.indexWhere((e) => e.id == value.id);
    if (i == -1) return;
    restaurants[i] = value;
    await _save();
    notifyListeners();
  }

  Future<void> deleteRestaurant(String id) async {
    restaurants.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> addDish(Restaurant restaurant, Dish dish) async {
    restaurant.dishes.add(dish);
    restaurant.dishes.sort((a, b) => b.visitDate.compareTo(a.visitDate));
    await _save();
    notifyListeners();
  }

  Future<void> updateDish(Restaurant restaurant, Dish dish) async {
    final i = restaurant.dishes.indexWhere((e) => e.id == dish.id);
    if (i == -1) return;
    restaurant.dishes[i] = dish;
    await _save();
    notifyListeners();
  }

  Future<void> deleteDish(Restaurant restaurant, String id) async {
    restaurant.dishes.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> toggleFavorite(Dish dish) async {
    dish.favorite = !dish.favorite;
    await _save();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
    notifyListeners();
  }

  Future<void> resetAll() async {
    restaurants.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dataKey);
    notifyListeners();
  }

  List<Dish> get allDishes =>
      restaurants.expand((restaurant) => restaurant.dishes).toList();

  int get favoriteCount => allDishes.where((e) => e.favorite).length;

  double get averageRating {
    final rated = allDishes.where((e) => e.rating > 0).toList();
    if (rated.isEmpty) return 0;
    return rated.fold<double>(0, (sum, e) => sum + e.rating) / rated.length;
  }

  Dish? get featuredDish {
    final dishes = allDishes.toList();
    if (dishes.isEmpty) return null;
    dishes.sort((a, b) {
      final fav = (b.favorite ? 1 : 0).compareTo(a.favorite ? 1 : 0);
      return fav != 0 ? fav : b.rating.compareTo(a.rating);
    });
    return dishes.first;
  }

  Restaurant? restaurantForDish(String dishId) {
    for (final restaurant in restaurants) {
      if (restaurant.dishes.any((dish) => dish.id == dishId)) {
        return restaurant;
      }
    }
    return null;
  }
}
