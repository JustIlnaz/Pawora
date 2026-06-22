class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String? productName;
  final String? productImageUrl;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    this.productName,
    this.productImageUrl,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String?,
      productImageUrl: json['productImageUrl'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}
