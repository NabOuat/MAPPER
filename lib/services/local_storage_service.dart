import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/place.dart';
import '../models/user.dart';
import '../models/message.dart';

class LocalStorageService {
  static const String _placesKey = 'places';
  static const String _usersKey = 'users';
  static const String _messagesKey = 'messages';
  static const String _currentUserKey = 'currentUser';
  
  final Uuid _uuid = const Uuid();

  // Singleton pattern
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Places methods
  Future<List<Place>> getPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final placesJson = prefs.getStringList(_placesKey) ?? [];
    return placesJson
        .map((json) => Place.fromMap(jsonDecode(json)))
        .toList();
  }

  Future<void> savePlaces(List<Place> places) async {
    final prefs = await SharedPreferences.getInstance();
    final placesJson = places
        .map((place) => jsonEncode(place.toMap()))
        .toList();
    await prefs.setStringList(_placesKey, placesJson);
  }

  Future<Place> addPlace(String name, double latitude, double longitude, {String category = 'Autre'}) async {
    final places = await getPlaces();
    final currentUser = await getCurrentUser();
    
    final newPlace = Place(
      id: _uuid.v4(),
      name: name,
      latitude: latitude,
      longitude: longitude,
      userId: currentUser.id, // User.id is now String
      userName: currentUser.name,
      createdAt: DateTime.now(),
      isSynced: false,
      category: category,
    );
    
    places.add(newPlace);
    await savePlaces(places);
    
    // Update user score
    final updatedUser = currentUser.copyWith(score: currentUser.score + 1);
    await saveCurrentUser(updatedUser);
    
    return newPlace;
  }

  // Users methods
  Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    return usersJson
        .map((json) => User.fromMap(jsonDecode(json)))
        .toList();
  }

  Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users
        .map((user) => jsonEncode(user.toMap()))
        .toList();
    await prefs.setStringList(_usersKey, usersJson);
  }

  // Current user methods
  Future<User> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson != null) {
      return User.fromMap(jsonDecode(userJson));
    }
    
    // Create a mock user if none exists
    final mockUser = User(
      id: "1", // ID fixe pour l'utilisateur mock (converted to String)
      name: 'Utilisateur',
      email: 'user@example.com',
      score: 0,
      lastActive: DateTime.now(),
    );
    
    await saveCurrentUser(mockUser);
    return mockUser;
  }

  Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toMap()));
    
    // Also update the user in the users list
    final users = await getUsers();
    final existingUserIndex = users.indexWhere((u) => u.id == user.id);
    
    if (existingUserIndex >= 0) {
      users[existingUserIndex] = user;
    } else {
      users.add(user);
    }
    
    await saveUsers(users);
  }

  // Messages methods
  Future<List<Message>> getMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getStringList(_messagesKey) ?? [];
    return messagesJson
        .map((json) => Message.fromMap(jsonDecode(json)))
        .toList();
  }

  Future<void> saveMessages(List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = messages
        .map((message) => jsonEncode(message.toMap()))
        .toList();
    await prefs.setStringList(_messagesKey, messagesJson);
  }

  Future<Message> addMessage(String receiverId, String content) async {
    final messages = await getMessages();
    final currentUser = await getCurrentUser();
    
    final newMessage = Message(
      id: _uuid.v4(),
      senderId: currentUser.id, // User.id is now String
      senderName: currentUser.name,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      isSynced: false,
    );
    
    messages.add(newMessage);
    await saveMessages(messages);
    
    return newMessage;
  }

  // Initialize with mock data
  Future<void> initializeMockData() async {
    final currentUser = await getCurrentUser();
    
    // Create mock users if none exist
    final users = await getUsers();
    List<User> mockUsers = [];
    
    // Ensure we have mock users
    if (users.length < 3) {
      mockUsers = [
        User(
          id: _uuid.v4(), // UUID is already a String
          name: 'Alice',
          email: 'alice@example.com',
          score: 15,
          lastActive: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        User(
          id: _uuid.v4(), // UUID is already a String
          name: 'Bob',
          email: 'bob@example.com',
          score: 10,
          lastActive: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        User(
          id: _uuid.v4(), // UUID is already a String
          name: 'Charlie',
          email: 'charlie@example.com',
          score: 8,
          lastActive: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      
      await saveUsers([...users, ...mockUsers]);
    }
    
    // Create mock places if none exist
    final places = await getPlaces();
    if (places.isEmpty) {
      final mockUsers = await getUsers();
      
      // Vérifier qu'il y a suffisamment d'utilisateurs
      if (mockUsers.length >= 3) {
        final mockPlaces = [
          Place(
            id: _uuid.v4(),
            name: 'Tour Eiffel',
            latitude: 48.8584,
            longitude: 2.2945,
            userId: mockUsers[0].id,
            userName: mockUsers[0].name,
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            isSynced: true,
            category: 'Monument',
          ),
          Place(
            id: _uuid.v4(),
            name: 'Statue de la Liberté',
            latitude: 40.6892,
            longitude: -74.0445,
            userId: mockUsers[1].id,
            userName: mockUsers[1].name,
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            isSynced: true,
            category: 'Monument',
          ),
          Place(
            id: _uuid.v4(),
            name: 'Colisée',
            latitude: 41.8902,
            longitude: 12.4922,
            userId: mockUsers[2].id,
            userName: mockUsers[2].name,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            isSynced: true,
            category: 'Monument',
          ),
          Place(
            id: _uuid.v4(),
            name: 'Pyramides de Gizeh',
            latitude: 29.9792,
            longitude: 31.1342,
            userId: currentUser.id,
            userName: currentUser.name,
            createdAt: DateTime.now().subtract(const Duration(hours: 12)),
            isSynced: true,
            category: 'Monument',
          ),
        ];
        
        await savePlaces([...places, ...mockPlaces]);
      }
    }
    
    // Create mock messages if none exist
    final messages = await getMessages();
    if (messages.isEmpty) {
      final mockUsers = await getUsers();
      
      // Vérifier qu'il y a suffisamment d'utilisateurs
      if (mockUsers.length >= 2) {
        final mockMessages = [
          Message(
            id: _uuid.v4(),
            senderId: mockUsers[0].id,
            senderName: mockUsers[0].name,
            receiverId: currentUser.id,
            content: 'Bonjour ! Comment allez-vous ?',
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
            isRead: true,
            isSynced: true,
          ),
          Message(
            id: _uuid.v4(),
            senderId: currentUser.id,
            senderName: currentUser.name,
            receiverId: mockUsers[0].id,
            content: 'Très bien, merci ! Et vous ?',
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
            isRead: true,
            isSynced: true,
          ),
          Message(
            id: _uuid.v4(),
            senderId: mockUsers[0].id,
            senderName: mockUsers[0].name,
            receiverId: currentUser.id,
            content: 'Parfait ! Avez-vous trouvé de nouveaux lieux intéressants ?',
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
            isRead: true,
            isSynced: true,
          ),
        ];
        
        // Ajouter un message supplémentaire si nous avons au moins 2 utilisateurs mock
        if (mockUsers.length >= 2) {
          mockMessages.add(
            Message(
              id: _uuid.v4(),
              senderId: mockUsers[1].id,
              senderName: mockUsers[1].name,
              receiverId: currentUser.id,
              content: 'Salut ! J\'ai ajouté un nouveau lieu hier.',
              timestamp: DateTime.now().subtract(const Duration(hours: 5)),
              isRead: false,
              isSynced: true,
            ),
          );
        }
        
        await saveMessages([...messages, ...mockMessages]);
      }
    }
  }
}
