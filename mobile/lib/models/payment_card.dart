import 'dart:convert';

class PaymentCard {
  final String id;
  final String number;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;
  final bool isDefault;

  PaymentCard({
    required this.id,
    required this.number,
    required this.expiryDate,
    required this.cvv,
    required this.cardHolderName,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'expiryDate': expiryDate,
    'cvv': cvv,
    'cardHolderName': cardHolderName,
    'isDefault': isDefault,
  };

  factory PaymentCard.fromJson(Map<String, dynamic> json) => PaymentCard(
    id: json['id'],
    number: json['number'],
    expiryDate: json['expiryDate'],
    cvv: json['cvv'],
    cardHolderName: json['cardHolderName'],
    isDefault: json['isDefault'] ?? false,
  );
}
