import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/restaurant.dart';
import '../models/api_response.dart';

class RestaurantProvider extends ChangeNotifier {
  final http.Client client;
  bool _disposed = false;

  String get _baseUrl =>
      dotenv.get('BASE_URL', fallback: 'https://restaurant-api.dicoding.dev');

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

  RestaurantProvider({http.Client? client, bool autoFetch = true})
    : client = client ?? http.Client() {
    if (autoFetch) {
      fetchRestaurants();
    }
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

  Future<void> fetchRestaurants() async {
    if (_disposed) return;
    _restaurants = Loading();
    notifyListeners();

    try {
      final response = await client.get(Uri.parse('$_baseUrl/list'));
      if (_disposed) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = RestaurantListResponse.fromJson(data);
        if (result.restaurants.isEmpty) {
          _restaurants = Error('Restoran tidak ditemukan');
        } else {
          _restaurants = Success(result.restaurants);
        }
      } else {
        _restaurants = Error('Failed (${response.statusCode})');
      }
    } catch (e) {
      if (_disposed) return;
      _restaurants = Error(_getFriendlyErrorMessage(e));
    }

    notifyListeners();
  }

  Future<void> fetchRestaurantDetail(String id) async {
    if (_disposed) return;
    _restaurantDetail = Loading();
    notifyListeners();

    try {
      final response = await client.get(Uri.parse('$_baseUrl/detail/$id'));
      if (_disposed) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = RestaurantDetailResponse.fromJson(data);
        _restaurantDetail = Success(result.restaurant);
      } else {
        _restaurantDetail = Error('Failed (${response.statusCode})');
      }
    } catch (e) {
      if (_disposed) return;
      _restaurantDetail = Error(_getFriendlyErrorMessage(e));
    }

    notifyListeners();
  }

  Future<void> searchRestaurants(String query) async {
    if (_disposed) return;
    _searchQuery = query;
    _searchResults = Loading();
    notifyListeners();

    try {
      final response = await client.get(Uri.parse('$_baseUrl/search?q=$query'));
      if (_disposed) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = SearchResponse.fromJson(data);
        _searchResults = Success(result.restaurants);
      } else {
        _searchResults = Error('Search failed');
      }
    } catch (e) {
      if (_disposed) return;
      _searchResults = Error(_getFriendlyErrorMessage(e));
    }

    notifyListeners();
  }

  Future<void> addReview({
    required String id,
    required String name,
    required String review,
  }) async {
    if (_disposed) return;
    _addReviewState = Loading();
    notifyListeners();

    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/review'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id, 'name': name, 'review': review}),
      );

      if (_disposed) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['error'] == true) {
          _addReviewState = Error(data['message']);
        } else {
          final reviewResponse = ReviewResponse.fromJson(data);

          if (_restaurantDetail is Success<Restaurant>) {
            final current = (_restaurantDetail as Success<Restaurant>).data;

            _restaurantDetail = Success(
              current.copyWith(customerReviews: reviewResponse.customerReviews),
            );
          }

          _addReviewState = Success(null);
        }
      } else {
        _addReviewState = Error('Server error');
      }
    } catch (e) {
      if (_disposed) return;
      _addReviewState = Error(_getFriendlyErrorMessage(e));
    }

    notifyListeners();
  }

  String _getFriendlyErrorMessage(Object e) {
    final message = e.toString();
    if (message.contains('SocketException') ||
        message.contains('Failed host lookup') ||
        message.contains('ClientException') ||
        message.contains('No address associated with hostname')) {
      return 'Network error: Unable to connect to server. Please check your internet connection.';
    } else if (message.contains('TimeoutException') ||
        message.contains('timeout')) {
      return 'Network error: Connection timed out. Please try again.';
    } else {
      return 'Network error: $e';
    }
  }

  void resetAddReviewState() {
    _addReviewState = Success(null);
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = Success([]);
    notifyListeners();
  }
}
