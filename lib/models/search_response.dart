import 'restaurant.dart';

class SearchResponse {
  final bool error;
  final int founded;
  final List<Restaurant> restaurants;

  const SearchResponse({
    required this.error,
    required this.founded,
    required this.restaurants,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) => SearchResponse(
    error: json['error'],
    founded: json['founded'],
    restaurants: List<Restaurant>.from(
      json['restaurants'].map((x) => Restaurant.fromJson(x)),
    ),
  );
}
