class User {
  final String id;
  final String name;
  final String email;
  final int score;
  final DateTime? lastActive;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.score = 0,
    this.lastActive,
    this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'score': score,
      'lastActive': lastActive?.toIso8601String(),
      'avatarUrl': avatarUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      score: map['score'],
      lastActive: map['lastActive'] != null ? DateTime.parse(map['lastActive']) : null,
      avatarUrl: map['avatarUrl'],
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? score,
    DateTime? lastActive,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      score: score ?? this.score,
      lastActive: lastActive ?? this.lastActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
