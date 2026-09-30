import 'package:flutter/material.dart';
import '../database/favorite_database.dart';
import '../models/restaurant.dart';
import '../models/api_response.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteDatabase _database;
  ApiResponse<List<Restaurant>> _favorites = Loading<List<Restaurant>>();
  bool _disposed = false;

  FavoriteProvider({FavoriteDatabase? database})
    : _database = database ?? FavoriteDatabase() {
    loadFavorites();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  ApiResponse<List<Restaurant>> get favorites => _favorites;

  Future<void> loadFavorites() async {
    if (_disposed) return;
    _favorites = Loading<List<Restaurant>>();
    notifyListeners();

    try {
      final favoriteList = await _database.getFavorites();
      if (_disposed) return;
      _favorites = Success<List<Restaurant>>(favoriteList);
    } catch (e) {
      if (_disposed) return;
      _favorites = Error<List<Restaurant>>('Failed to load favorites: $e');
    }

    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> addFavorite(Restaurant restaurant) async {
    try {
      await _database.addFavorite(restaurant);
      await loadFavorites();
    } catch (e) {
      // Error adding favorite
    }
  }

  Future<void> removeFavorite(String id) async {
    try {
      await _database.removeFavorite(id);
      await loadFavorites();
    } catch (e) {
      // Error removing favorite
    }
  }

  Future<bool> isFavorite(String id) async {
    try {
      return await _database.isFavorite(id);
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleFavorite(Restaurant restaurant) async {
    final favorite = await isFavorite(restaurant.id);
    if (favorite) {
      await removeFavorite(restaurant.id);
    } else {
      await addFavorite(restaurant);
    }
  }
}
