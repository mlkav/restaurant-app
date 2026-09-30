import 'customer_review.dart';
import 'menu.dart';

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String pictureId;
  final String city;
  final double rating;
  final String? address;
  final Menu? menus;
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
    menus: json['menus'] != null ? Menu.fromJson(json['menus']) : null,
    customerReviews: json['customerReviews'] != null
        ? List<CustomerReview>.from(
            json['customerReviews'].map((x) => CustomerReview.fromJson(x)),
          )
        : null,
  );

  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? pictureId,
    String? city,
    double? rating,
    String? address,
    Menu? menus,
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
