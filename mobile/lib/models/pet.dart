class Pet {
  final String id;
  final String userId;
  final String name;
  final String species;
  final String? breed;
  final String? imageUrl;
  final String? birthDate;

  Pet({
    required this.id,
    required this.userId,
    required this.name,
    required this.species,
    this.breed,
    this.imageUrl,
    this.birthDate,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      imageUrl: json['imageUrl'] as String?,
      birthDate: json['birthDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'species': species,
      'breed': breed,
      'imageUrl': imageUrl,
      'birthDate': birthDate,
    };
  }
}
