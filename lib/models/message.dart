class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isSynced;
  final Map<String, Map<String, bool>> reactions; // Map<ReactionType, Map<UserId, HasReacted>>

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.isSynced = true,
    Map<String, Map<String, bool>>? reactions,
  }) : reactions = reactions ?? {};

  Map<String, dynamic> toMap() {
    // Convertir les réactions en format JSON-compatible
    final reactionsMap = <String, dynamic>{};
    for (final entry in reactions.entries) {
      final reactionType = entry.key;
      final userReactions = entry.value;
      reactionsMap[reactionType] = userReactions;
    }
    
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'isSynced': isSynced,
      'reactions': reactionsMap,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    // Convertir les réactions du format JSON
    final reactionsJson = map['reactions'];
    final reactionsMap = <String, Map<String, bool>>{};
    
    if (reactionsJson != null && reactionsJson is Map) {
      reactionsJson.forEach((key, value) {
        if (value is Map) {
          final userReactions = <String, bool>{};
          value.forEach((userId, hasReacted) {
            if (hasReacted is bool) {
              userReactions[userId] = hasReacted;
            }
          });
          reactionsMap[key] = userReactions;
        }
      });
    }
    
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
      isSynced: map['isSynced'] ?? false,
      reactions: reactionsMap,
    );
  }
  
  /// Créer une copie du message avec des valeurs modifiées
  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    bool? isSynced,
    Map<String, Map<String, bool>>? reactions,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isSynced: isSynced ?? this.isSynced,
      reactions: reactions ?? this.reactions,
    );
  }
}
