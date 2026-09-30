import 'restaurant.dart';

class RestaurantDetailResponse {
  final bool error;
  final String message;
  final Restaurant restaurant;

  const RestaurantDetailResponse({
    required this.error,
    required this.message,
    required this.restaurant,
  });

  factory RestaurantDetailResponse.fromJson(Map<String, dynamic> json) =>
      RestaurantDetailResponse(
        error: json['error'],
        message: json['message'],
        restaurant: Restaurant.fromJson(json['restaurant']),
      );
}
