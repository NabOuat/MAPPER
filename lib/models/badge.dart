class Badge {
  final int? id;
  final String nomBadge;
  final String? description;
  final String? imageUrl;

  Badge({
    this.id,
    required this.nomBadge,
    this.description,
    this.imageUrl,
  });

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id_badge'],
      nomBadge: map['nom_badge'],
      description: map['description'],
      imageUrl: map['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_badge': id,
      'nom_badge': nomBadge,
      'description': description,
      'image_url': imageUrl,
    };
  }

  Badge copyWith({
    int? id,
    String? nomBadge,
    String? description,
    String? imageUrl,
  }) {
    return Badge(
      id: id ?? this.id,
      nomBadge: nomBadge ?? this.nomBadge,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
