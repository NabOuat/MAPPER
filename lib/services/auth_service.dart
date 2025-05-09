import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  
  // Initialiser l'état d'authentification au démarrage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      
      if (userJson != null) {
        _currentUser = User.fromMap(json.decode(userJson));
        _isAuthenticated = true;
      }
    } catch (e) {
      _error = 'Erreur lors de l\'initialisation: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Connexion avec un compte existant
  Future<bool> login(String contact, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Simulation d'une connexion à l'API (à remplacer par une vraie API)
      // Dans un environnement de production, cette requête serait vers un serveur réel
      await Future.delayed(const Duration(seconds: 1));
      
      // En mode hors ligne, on vérifie si l'utilisateur existe déjà localement
      // Dans un environnement réel, cette vérification se ferait côté serveur
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final List<dynamic> users = json.decode(usersJson);
      
      final userIndex = users.indexWhere((u) => 
        u['email'] == contact && u['password'] == password // Dans un vrai système, le mot de passe serait haché
      );
      
      if (userIndex >= 0) {
        final userData = users[userIndex];
        _currentUser = User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          score: userData['score'] ?? 0,
          lastActive: DateTime.now(),
          avatarUrl: userData['avatarUrl'],
        );
        
        // Sauvegarder l'utilisateur dans la base de données locale
        await _databaseService.saveUser(_currentUser!);
        
        // Sauvegarder l'utilisateur courant dans les préférences
        await prefs.setString('current_user', json.encode(_currentUser!.toMap()));
        
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Email ou mot de passe incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur lors de la connexion: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Déconnexion
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      
      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      _error = 'Erreur lors de la déconnexion: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Synchroniser les données locales avec le serveur
  Future<void> syncData() async {
    if (!_isAuthenticated || _currentUser == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Récupérer les lieux non synchronisés
      final unsyncedPlaces = await _databaseService.getUnsyncedPlaces();
      
      // Récupérer les achievements non synchronisés
      final unsyncedAchievements = await _databaseService.getUnsyncedAchievements();
      
      // Simulation d'envoi au serveur (à remplacer par une vraie API)
      await Future.delayed(const Duration(seconds: 1));
      
      // Marquer les lieux comme synchronisés
      for (final place in unsyncedPlaces) {
        await _databaseService.markPlaceAsSynced(place.id);
      }
      
      // Marquer les achievements comme synchronisés
      for (final achievement in unsyncedAchievements) {
        await _databaseService.markAchievementAsSynced(achievement['id_achievement']);
      }
      
      // Mettre à jour la date de dernière activité
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(lastActive: DateTime.now());
        _currentUser = updatedUser;
        
        // Sauvegarder l'utilisateur mis à jour
        await _databaseService.updateUser(updatedUser);
        
        // Mettre à jour les préférences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', json.encode(updatedUser.toMap()));
      }
    } catch (e) {
      _error = 'Erreur lors de la synchronisation: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Mettre à jour le profil utilisateur dans la base de données locale
  Future<void> updateUserProfile(User updatedUser) async {
    if (!_isAuthenticated || _currentUser == null) {
      throw Exception('Utilisateur non authentifié');
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Mettre à jour l'utilisateur dans la base de données
      await _databaseService.updateUser(updatedUser);
      
      // Mettre à jour l'utilisateur courant
      _currentUser = updatedUser;
      
      // Sauvegarder dans les préférences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', json.encode(_currentUser!.toMap()));
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Erreur lors de la mise à jour du profil: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }
  
  // Vérifier si l'utilisateur est connecté
  Future<bool> checkAuthentication() async {
    if (_isAuthenticated) return true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      
      if (userJson != null) {
        _currentUser = User.fromMap(json.decode(userJson));
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Erreur lors de la vérification d\'authentification: $e';
      notifyListeners();
    }
    
    return false;
  }
}
