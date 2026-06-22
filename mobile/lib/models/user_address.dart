class UserAddress {
  final String id;
  final String addressText;
  final bool isDefault;

  UserAddress({
    required this.id,
    required this.addressText,
    required this.isDefault,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] as String,
      addressText: json['addressText'] as String,
      isDefault: json['isDefault'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'addressText': addressText,
      'isDefault': isDefault,
    };
  }
}
