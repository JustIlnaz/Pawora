import 'api_client.dart';
import '../models/review.dart';

class ReviewService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Review>> getProductReviews(String productId) async {
    final response = await _apiClient.dio.get('/products/$productId/reviews');
    return (response.data['data'] as List).map((json) => Review.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Review> createReview(String productId, int rating, String? comment) async {
    final response = await _apiClient.dio.post('/products/$productId/reviews', data: {
      'rating': rating,
      'comment': comment,
    });
    return Review.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<Review> replyToReview(String productId, String reviewId, String reply) async {
    final response = await _apiClient.dio.post('/products/$productId/reviews/$reviewId/reply', data: {
      'reply': reply,
    });
    return Review.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
