class Ligue {
  final int? id;
  final String nomLigue;
  final int niveau;
  final String? image;
  final String? description;

  Ligue({
    this.id,
    required this.nomLigue,
    required this.niveau,
    this.image,
    this.description,
  });

  factory Ligue.fromMap(Map<String, dynamic> map) {
    return Ligue(
      id: map['id_ligue'],
      nomLigue: map['nom_ligue'],
      niveau: map['niveau'],
      image: map['image'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_ligue': id,
      'nom_ligue': nomLigue,
      'niveau': niveau,
      'image': image,
      'description': description,
    };
  }

  Ligue copyWith({
    int? id,
    String? nomLigue,
    int? niveau,
    String? image,
    String? description,
  }) {
    return Ligue(
      id: id ?? this.id,
      nomLigue: nomLigue ?? this.nomLigue,
      niveau: niveau ?? this.niveau,
      image: image ?? this.image,
      description: description ?? this.description,
    );
  }
}
