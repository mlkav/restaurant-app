import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/restaurant.dart';
import '../models/api_response.dart';

class RestaurantProvider extends ChangeNotifier {
  final String _baseUrl = dotenv.env['BASE_URL']!;

  ApiResponse<List<Restaurant>> _restaurants = Loading();
  ApiResponse<Restaurant> _restaurantDetail = Loading();
  ApiResponse<List<Restaurant>> _searchResults = Loading();
  ApiResponse<void> _addReviewState = Success(null);

  String _searchQuery = '';

  ApiResponse<List<Restaurant>> get restaurants => _restaurants;
  ApiResponse<Restaurant> get restaurantDetail => _restaurantDetail;
  ApiResponse<List<Restaurant>> get searchResults => _searchResults;
  ApiResponse<void> get addReviewState => _addReviewState;
  String get searchQuery => _searchQuery;

  RestaurantProvider() {
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    _restaurants = Loading();
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_baseUrl/list'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = RestaurantListResponse.fromJson(data);
        _restaurants = Success(result.restaurants);
      } else {
        _restaurants = Error('Failed (${response.statusCode})');
      }
    } catch (e) {
      _restaurants = Error('Network error: $e');
    }

    notifyListeners();
  }

  Future<void> fetchRestaurantDetail(String id) async {
    _restaurantDetail = Loading();
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_baseUrl/detail/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = RestaurantDetailResponse.fromJson(data);
        _restaurantDetail = Success(result.restaurant);
      } else {
        _restaurantDetail = Error('Failed (${response.statusCode})');
      }
    } catch (e) {
      _restaurantDetail = Error('Network error: $e');
    }

    notifyListeners();
  }

  Future<void> searchRestaurants(String query) async {
    _searchQuery = query;
    _searchResults = Loading();
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_baseUrl/search?q=$query'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = SearchResponse.fromJson(data);
        _searchResults = Success(result.restaurants);
      } else {
        _searchResults = Error('Search failed');
      }
    } catch (e) {
      _searchResults = Error('Network error: $e');
    }

    notifyListeners();
  }

  Future<void> addReview({
    required String id,
    required String name,
    required String review,
  }) async {
    _addReviewState = Loading();
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/review'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'name': name,
          'review': review,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['error'] == true) {
          _addReviewState = Error(data['message']);
        } else {
          final reviewResponse = ReviewResponse.fromJson(data);

          if (_restaurantDetail is Success<Restaurant>) {
            final current = (_restaurantDetail as Success<Restaurant>).data;

            _restaurantDetail = Success(
              current.copyWith(
                customerReviews: reviewResponse.customerReviews,
              ),
            );
          }

          _addReviewState = Success(null);
        }
      } else {
        _addReviewState = Error('Server error');
      }
    } catch (e) {
      _addReviewState = Error('Network error: $e');
    }

    notifyListeners();
  }

  void resetAddReviewState() {
    _addReviewState = Success(null);
    notifyListeners();
  }

  void clearSearch() {}
}
