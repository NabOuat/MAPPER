import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/local_storage_service.dart';

class UsersProvider extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  
  List<User> _users = [];
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Obtenir les utilisateurs triés par score (pour le classement)
  List<User> get leaderboard {
    final sortedUsers = List<User>.from(_users);
    sortedUsers.sort((a, b) => b.score.compareTo(a.score));
    return sortedUsers;
  }

  UsersProvider() {
    loadUsers();
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _storageService.getUsers();
      _currentUser = await _storageService.getCurrentUser();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des utilisateurs: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCurrentUser({String? name, String? email, String? avatarUrl}) async {
    if (_currentUser == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
        lastActive: DateTime.now(),
      );
      
      await _storageService.saveCurrentUser(updatedUser);
      _currentUser = updatedUser;
      
      // Update user in the users list
      final index = _users.indexWhere((user) => user.id == _currentUser!.id);
      if (index >= 0) {
        _users[index] = _currentUser!;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du profil: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  int getCurrentUserRank() {
    if (_currentUser == null) return 0;
    
    final sortedUsers = leaderboard;
    final index = sortedUsers.indexWhere((user) => user.id == _currentUser!.id);
    
    return index >= 0 ? index + 1 : 0;
  }
}
