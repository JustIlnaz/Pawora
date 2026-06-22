class Product {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? shopName;
  final String? categoryName;
  final double price;
  final double? discountPrice;
  final String? shopId;
  final String? categoryId;
  final int stock;
  final double rating;
  final int reviewCount;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.shopName,
    this.categoryName,
    required this.price,
    this.discountPrice,
    this.shopId,
    this.categoryId,
    required this.stock,
    required this.rating,
    required this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      shopName: json['shopName'] as String?,
      categoryName: json['categoryName'] as String?,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null ? (json['discountPrice'] as num).toDouble() : null,
      shopId: json['shopId'] as String?,
      categoryId: json['categoryId'] as String?,
      stock: json['stock'] as int,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'shopName': shopName,
      'categoryName': categoryName,
      'price': price,
      'discountPrice': discountPrice,
      'shopId': shopId,
      'categoryId': categoryId,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}
