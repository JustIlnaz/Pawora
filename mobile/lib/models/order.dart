import 'order_item.dart';

class Order {
  final String id;
  final String userId;
  final String? shopId;
  final String status;
  final double totalAmount;
  final String? address;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    this.shopId,
    required this.status,
    required this.totalAmount,
    this.address,
    required this.createdAt,
    required this.items,
  });

  static String _parseStatus(dynamic status) {
    if (status is int) {
      switch (status) {
        case 0: return 'New';
        case 1: return 'InProgress';
        case 2: return 'Delivered';
        case 3: return 'Cancelled';
      }
    }
    return status?.toString() ?? 'New';
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      shopId: json['shopId'] as String?,
      status: _parseStatus(json['status']),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      address: json['address'] as String?,
      createdAt: json['createdAt'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'shopId': shopId,
      'status': status,
      'totalAmount': totalAmount,
      'address': address,
      'createdAt': createdAt,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
