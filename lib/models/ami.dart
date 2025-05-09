class Ami {
  final int idUtilisateur1;
  final int idUtilisateur2;
  final String statut;
  final DateTime dateAjout;

  Ami({
    required this.idUtilisateur1,
    required this.idUtilisateur2,
    required this.statut,
    required this.dateAjout,
  });

  factory Ami.fromMap(Map<String, dynamic> map) {
    return Ami(
      idUtilisateur1: map['id_utilisateur_1'],
      idUtilisateur2: map['id_utilisateur_2'],
      statut: map['statut'],
      dateAjout: DateTime.parse(map['date_ajout']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_utilisateur_1': idUtilisateur1,
      'id_utilisateur_2': idUtilisateur2,
      'statut': statut,
      'date_ajout': dateAjout.toIso8601String(),
    };
  }

  Ami copyWith({
    int? idUtilisateur1,
    int? idUtilisateur2,
    String? statut,
    DateTime? dateAjout,
  }) {
    return Ami(
      idUtilisateur1: idUtilisateur1 ?? this.idUtilisateur1,
      idUtilisateur2: idUtilisateur2 ?? this.idUtilisateur2,
      statut: statut ?? this.statut,
      dateAjout: dateAjout ?? this.dateAjout,
    );
  }
}
