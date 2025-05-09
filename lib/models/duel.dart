import 'dart:convert';

class Duel {
  final int? id;
  final int idUtilisateur1;
  final int idUtilisateur2;
  final String type;
  final String statut;
  final DateTime dateCreation;
  final DateTime? dateFin;
  final String? lienDuel;
  final int scoreUtilisateur1;
  final int scoreUtilisateur2;
  final List<Map<String, dynamic>> participantsEquipe1;
  final List<Map<String, dynamic>> participantsEquipe2;

  Duel({
    this.id,
    required this.idUtilisateur1,
    required this.idUtilisateur2,
    required this.type,
    required this.statut,
    required this.dateCreation,
    this.dateFin,
    this.lienDuel,
    this.scoreUtilisateur1 = 0,
    this.scoreUtilisateur2 = 0,
    required this.participantsEquipe1,
    required this.participantsEquipe2,
  });

  factory Duel.fromMap(Map<String, dynamic> map) {
    return Duel(
      id: map['id'],
      idUtilisateur1: map['id_utilisateur_1'],
      idUtilisateur2: map['id_utilisateur_2'],
      type: map['type'],
      statut: map['statut'],
      dateCreation: DateTime.parse(map['date_creation']),
      dateFin: map['date_fin'] != null ? DateTime.parse(map['date_fin']) : null,
      lienDuel: map['lien_duel'],
      scoreUtilisateur1: map['score_utilisateur_1'] ?? 0,
      scoreUtilisateur2: map['score_utilisateur_2'] ?? 0,
      participantsEquipe1: List<Map<String, dynamic>>.from(
        jsonDecode(map['participants_equipe_1'] ?? '[]'),
      ),
      participantsEquipe2: List<Map<String, dynamic>>.from(
        jsonDecode(map['participants_equipe_2'] ?? '[]'),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_utilisateur_1': idUtilisateur1,
      'id_utilisateur_2': idUtilisateur2,
      'type': type,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_fin': dateFin?.toIso8601String(),
      'lien_duel': lienDuel,
      'score_utilisateur_1': scoreUtilisateur1,
      'score_utilisateur_2': scoreUtilisateur2,
      'participants_equipe_1': jsonEncode(participantsEquipe1),
      'participants_equipe_2': jsonEncode(participantsEquipe2),
    };
  }

  Duel copyWith({
    int? id,
    int? idUtilisateur1,
    int? idUtilisateur2,
    String? type,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateFin,
    String? lienDuel,
    int? scoreUtilisateur1,
    int? scoreUtilisateur2,
    List<Map<String, dynamic>>? participantsEquipe1,
    List<Map<String, dynamic>>? participantsEquipe2,
  }) {
    return Duel(
      id: id ?? this.id,
      idUtilisateur1: idUtilisateur1 ?? this.idUtilisateur1,
      idUtilisateur2: idUtilisateur2 ?? this.idUtilisateur2,
      type: type ?? this.type,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateFin: dateFin ?? this.dateFin,
      lienDuel: lienDuel ?? this.lienDuel,
      scoreUtilisateur1: scoreUtilisateur1 ?? this.scoreUtilisateur1,
      scoreUtilisateur2: scoreUtilisateur2 ?? this.scoreUtilisateur2,
      participantsEquipe1: participantsEquipe1 ?? this.participantsEquipe1,
      participantsEquipe2: participantsEquipe2 ?? this.participantsEquipe2,
    );
  }
}
