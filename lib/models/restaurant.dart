// Model restaurant
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String pictureId;
  final String city;
  final double rating;
  final String? address;
  final Menus? menus;
  final List<CustomerReview>? customerReviews;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.pictureId,
    required this.city,
    required this.rating,
    this.address,
    this.menus,
    this.customerReviews,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        pictureId: json['pictureId'],
        city: json['city'],
        rating: (json['rating'] as num).toDouble(),
        address: json['address'],
        menus: json['menus'] != null ? Menus.fromJson(json['menus']) : null,
        customerReviews: json['customerReviews'] != null
            ? List<CustomerReview>.from(
                json['customerReviews'].map((x) => CustomerReview.fromJson(x)),
              )
            : null,
      );

  /// Digunakan saat update sebagian data (misalnya setelah add review)
  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? pictureId,
    String? city,
    double? rating,
    String? address,
    Menus? menus,
    List<CustomerReview>? customerReviews,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pictureId: pictureId ?? this.pictureId,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      address: address ?? this.address,
      menus: menus ?? this.menus,
      customerReviews: customerReviews ?? this.customerReviews,
    );
  }
}

// Menu
class Menus {
  final List<MenuItem> foods;
  final List<MenuItem> drinks;

  const Menus({
    required this.foods,
    required this.drinks,
  });

  factory Menus.fromJson(Map<String, dynamic> json) => Menus(
        foods: List<MenuItem>.from(
          json['foods'].map((x) => MenuItem.fromJson(x)),
        ),
        drinks: List<MenuItem>.from(
          json['drinks'].map((x) => MenuItem.fromJson(x)),
        ),
      );
}

class MenuItem {
  final String name;

  const MenuItem({required this.name});

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      MenuItem(name: json['name']);
}

// Customer review
class CustomerReview {
  final String name;
  final String review;
  final String date;

  const CustomerReview({
    required this.name,
    required this.review,
    required this.date,
  });

  factory CustomerReview.fromJson(Map<String, dynamic> json) => CustomerReview(
        name: json['name'],
        review: json['review'],
        date: json['date'],
      );
}

// List restaurant
class RestaurantListResponse {
  final bool error;
  final String message;
  final int count;
  final List<Restaurant> restaurants;

  const RestaurantListResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.restaurants,
  });

  factory RestaurantListResponse.fromJson(Map<String, dynamic> json) =>
      RestaurantListResponse(
        error: json['error'],
        message: json['message'],
        count: json['count'],
        restaurants: List<Restaurant>.from(
          json['restaurants'].map((x) => Restaurant.fromJson(x)),
        ),
      );
}

// Detail restaurant
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

// Search
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

// Review
class ReviewResponse {
  final bool error;
  final String message;
  final List<CustomerReview> customerReviews;

  const ReviewResponse({
    required this.error,
    required this.message,
    required this.customerReviews,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) => ReviewResponse(
        error: json['error'],
        message: json['message'],
        customerReviews: List<CustomerReview>.from(
          json['customerReviews'].map((x) => CustomerReview.fromJson(x)),
        ),
      );
}
