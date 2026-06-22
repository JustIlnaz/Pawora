class Review {
  final String id;
  final String userId;
  final String? userName;
  final String? userAvatarUrl;
  final String productId;
  final int rating;
  final String? comment;
  final String createdAt;
  final String? adminReply;
  final String? adminReplyCreatedAt;

  Review({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatarUrl,
    required this.productId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.adminReply,
    this.adminReplyCreatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      productId: json['productId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] as String,
      adminReply: json['adminReply'] as String?,
      adminReplyCreatedAt: json['adminReplyCreatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'productId': productId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'adminReply': adminReply,
      'adminReplyCreatedAt': adminReplyCreatedAt,
    };
  }
}
