import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/local_storage_service.dart';

class MessagesProvider extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MessagesProvider() {
    loadMessages();
  }

  Future<void> loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await _storageService.getMessages();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des messages: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Message?> sendMessage(String receiverId, String content) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMessage = await _storageService.addMessage(receiverId, content);
      _messages.add(newMessage);
      _isLoading = false;
      notifyListeners();
      return newMessage;
    } catch (e) {
      _error = 'Erreur lors de l\'envoi du message: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  List<Message> getConversation(String userId1, String userId2) {
    return _messages.where((message) => 
      (message.senderId == userId1 && message.receiverId == userId2) ||
      (message.senderId == userId2 && message.receiverId == userId1)
    ).toList()
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // Obtenir la liste des conversations uniques
  List<Map<String, dynamic>> getConversationsList(String currentUserId) {
    final Map<String, Map<String, dynamic>> conversationsMap = {};
    
    for (final message in _messages) {
      String otherUserId;
      bool isFromCurrentUser;
      
      if (message.senderId == currentUserId) {
        otherUserId = message.receiverId;
        isFromCurrentUser = true;
      } else if (message.receiverId == currentUserId) {
        otherUserId = message.senderId;
        isFromCurrentUser = false;
      } else {
        continue; // Message n'implique pas l'utilisateur courant
      }
      
      if (!conversationsMap.containsKey(otherUserId)) {
        conversationsMap[otherUserId] = {
          'userId': otherUserId,
          'userName': message.senderId == currentUserId ? '' : message.senderName,
          'lastMessage': message.content,
          'timestamp': message.timestamp,
          'unreadCount': isFromCurrentUser || message.isRead ? 0 : 1,
        };
      } else {
        final existing = conversationsMap[otherUserId]!;
        
        if (message.timestamp.isAfter(existing['timestamp'])) {
          existing['lastMessage'] = message.content;
          existing['timestamp'] = message.timestamp;
          
          if (!isFromCurrentUser && !message.isRead) {
            existing['unreadCount'] = (existing['unreadCount'] as int) + 1;
          }
        } else if (!isFromCurrentUser && !message.isRead) {
          existing['unreadCount'] = (existing['unreadCount'] as int) + 1;
        }
        
        // Ensure we have the user name
        if (existing['userName'] == '' && message.senderId != currentUserId) {
          existing['userName'] = message.senderName;
        }
      }
    }
    
    final List<Map<String, dynamic>> conversations = conversationsMap.values.toList();
    conversations.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    
    return conversations;
  }

  Future<void> markAsRead(String senderId) async {
    final currentUser = await _storageService.getCurrentUser();
    final List<Message> updatedMessages = [];
    
    for (final message in _messages) {
      if (message.senderId == senderId && 
          message.receiverId == currentUser.id && 
          !message.isRead) {
        final updatedMessage = message.copyWith(isRead: true);
        updatedMessages.add(updatedMessage);
      } else {
        updatedMessages.add(message);
      }
    }
    
    await _storageService.saveMessages(updatedMessages);
    _messages = updatedMessages;
    notifyListeners();
  }
  
  /// Ajouter ou supprimer une réaction à un message
  Future<void> toggleReaction(String messageId, String userId, String reaction, bool isAdding) async {
    final List<Message> updatedMessages = [];
    bool messageFound = false;
    
    for (final message in _messages) {
      if (message.id == messageId) {
        messageFound = true;
        
        // Copier les réactions existantes
        final Map<String, Map<String, bool>> updatedReactions = {};
        for (final entry in message.reactions.entries) {
          updatedReactions[entry.key] = Map<String, bool>.from(entry.value);
        }
        
        // Ajouter ou supprimer la réaction
        if (!updatedReactions.containsKey(reaction)) {
          updatedReactions[reaction] = {};
        }
        
        if (isAdding) {
          updatedReactions[reaction]![userId] = true;
        } else {
          updatedReactions[reaction]!.remove(userId);
          // Supprimer le type de réaction s'il n'y a plus de réactions
          if (updatedReactions[reaction]!.isEmpty) {
            updatedReactions.remove(reaction);
          }
        }
        
        // Créer un nouveau message avec les réactions mises à jour
        final updatedMessage = Message(
          id: message.id,
          senderId: message.senderId,
          receiverId: message.receiverId,
          senderName: message.senderName,
          content: message.content,
          timestamp: message.timestamp,
          isRead: message.isRead,
          isSynced: message.isSynced,
          reactions: updatedReactions,
        );
        
        updatedMessages.add(updatedMessage);
      } else {
        updatedMessages.add(message);
      }
    }
    
    if (messageFound) {
      await _storageService.saveMessages(updatedMessages);
      _messages = updatedMessages;
      notifyListeners();
    }
  }
}
