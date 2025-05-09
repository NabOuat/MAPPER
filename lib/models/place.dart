class Place {
  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final String userId; // Correspond à user_id dans la BD
  final String userName; // Pour l'affichage, non stocké dans la BD
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final String category;

  Place({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.userName,
    required this.createdAt,
    DateTime? updatedAt,
    this.isSynced = false,
    this.category = 'Autre',
  }) : this.updatedAt = updatedAt ?? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      latitude: map['latitude'] is double ? map['latitude'] : double.parse(map['latitude'].toString()),
      longitude: map['longitude'] is double ? map['longitude'] : double.parse(map['longitude'].toString()),
      userId: map['user_id'] ?? map['userId'],
      userName: map['userName'] ?? '', // Peut être vide car non stocké dans la BD
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isSynced: map['is_synced'] == 1 || map['isSynced'] == 1,
      category: map['category'] ?? 'Autre',
    );
  }

  Place copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? userId,
    String? userName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? category,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      category: category ?? this.category,
    );
  }
}
