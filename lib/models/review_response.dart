import 'customer_review.dart';

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
