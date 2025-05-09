import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/place.dart';
import '../models/user.dart';
import 'database_service.dart';

class PlacesService with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Place> _places = [];
  bool _isLoading = false;
  String? _error;
  
  List<Place> get places => _places;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Charger tous les lieux pour un utilisateur
  Future<void> loadPlaces({String? userId, String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _places = await _databaseService.getPlaces(userId: userId, category: category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des lieux: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Ajouter un nouveau lieu
  Future<String?> addPlace({
    required String name,
    String? description,
    required double latitude,
    required double longitude,
    required User user,
    required String category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newPlace = Place(
        id: const Uuid().v4(),
        name: name,
        description: description,
        latitude: latitude,
        longitude: longitude,
        userId: user.id,
        userName: user.name,
        createdAt: DateTime.now(),
        isSynced: false,
        category: category,
      );
      
      // Sauvegarder dans la base de données locale
      final placeId = await _databaseService.savePlace(newPlace);
      
      // Ajouter à la liste en mémoire
      _places.add(newPlace);
      
      _isLoading = false;
      notifyListeners();
      
      return placeId;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout du lieu: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Mettre à jour un lieu existant
  Future<bool> updatePlace(Place place) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Mettre à jour dans la base de données locale
      await _databaseService.updatePlace(place);
      
      // Mettre à jour dans la liste en mémoire
      final index = _places.indexWhere((p) => p.id == place.id);
      if (index >= 0) {
        _places[index] = place;
      }
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du lieu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Supprimer un lieu
  Future<bool> deletePlace(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Supprimer de la base de données locale
      await _databaseService.deletePlace(id);
      
      // Supprimer de la liste en mémoire
      _places.removeWhere((place) => place.id == id);
      
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression du lieu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Filtrer les lieux par catégorie
  List<Place> filterByCategory(String category) {
    if (category == 'Tous') {
      return _places;
    }
    return _places.where((place) => place.category == category).toList();
  }
  
  // Obtenir les lieux à proximité d'une position
  List<Place> getNearbyPlaces(double latitude, double longitude, double radiusInKm) {
    return _places.where((place) {
      final distance = _calculateDistance(
        latitude, longitude, place.latitude, place.longitude);
      return distance <= radiusInKm;
    }).toList();
  }
  
  /// Calcule la distance entre deux points avec une précision élevée (marge d'erreur < 3%)
  /// Utilise la formule de Vincenty qui est plus précise que la formule de Haversine,
  /// particulièrement pour les longues distances et les positions proches des pôles.
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Vérifier si les points sont identiques
    if (lat1 == lat2 && lon1 == lon2) {
      return 0.0;
    }
    
    // Utiliser la formule de Vincenty pour une précision maximale
    // Cette formule prend en compte l'ellipticité de la Terre
    // Constantes pour le modèle WGS-84 (standard GPS)
    const double a = 6378137.0; // demi-grand axe en mètres
    const double b = 6356752.314245; // demi-petit axe en mètres
    const double f = 1/298.257223563; // aplatissement
    
    // Convertir en radians
    final phi1 = _toRadians(lat1);
    final phi2 = _toRadians(lat2);
    final lambda1 = _toRadians(lon1);
    final lambda2 = _toRadians(lon2);
    
    // Différence de longitude
    final L = lambda2 - lambda1;
    
    // Calcul de la tangente de l'angle de la ligne géodésique
    final tanU1 = (1 - f) * math.tan(phi1);
    final tanU2 = (1 - f) * math.tan(phi2);
    
    // Latitude réduite
    final U1 = math.atan(tanU1);
    final U2 = math.atan(tanU2);
    
    // Sinus et cosinus des latitudes réduites (précalculés pour l'optimisation)
    final sinU1 = math.sin(U1);
    final cosU1 = math.cos(U1);
    final sinU2 = math.sin(U2);
    final cosU2 = math.cos(U2);
    
    // Différence de longitude sur la sphère auxiliaire
    double lambda = L;
    double lambdaP;
    
    // Initialiser les variables pour l'itération
    double sinSigma, cosSigma, sigma, sinAlpha, cos2Alpha, cos2SigmaM;
    
    // Itération jusqu'à convergence (généralement moins de 10 itérations)
    int iterLimit = 100;
    do {
      final sinLambda = math.sin(lambda);
      final cosLambda = math.cos(lambda);
      
      sinSigma = math.sqrt(
        math.pow(cosU2 * sinLambda, 2) + 
        math.pow(cosU1 * sinU2 - sinU1 * cosU2 * cosLambda, 2)
      );
      
      if (sinSigma == 0) return 0; // Points coïncidents
      
      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
      sigma = math.atan2(sinSigma, cosSigma);
      sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
      cos2Alpha = 1 - sinAlpha * sinAlpha;
      
      // Éviter la division par zéro
      cos2SigmaM = cos2Alpha != 0 ? 
                  cosSigma - 2 * sinU1 * sinU2 / cos2Alpha : 
                  0;
      
      final C = f / 16 * cos2Alpha * (4 + f * (4 - 3 * cos2Alpha));
      lambdaP = lambda;
      lambda = L + (1 - C) * f * sinAlpha * 
              (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * 
                                      (-1 + 2 * cos2SigmaM * cos2SigmaM)));
    } while ((lambda - lambdaP).abs() > 1e-12 && --iterLimit > 0);
    
    if (iterLimit == 0) {
      // La formule n'a pas convergé, utiliser une méthode de secours
      return _calculateHaversineDistance(lat1, lon1, lat2, lon2);
    }
    
    // Calcul de la distance
    final uSq = cos2Alpha * (a * a - b * b) / (b * b);
    final A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    final B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    
    final deltaSigma = B * sinSigma * (cos2SigmaM + B / 4 * (cosSigma * 
                      (-1 + 2 * cos2SigmaM * cos2SigmaM) - B / 6 * cos2SigmaM * 
                      (-3 + 4 * sinSigma * sinSigma) * (-3 + 4 * cos2SigmaM * cos2SigmaM)));
    
    final distance = b * A * (sigma - deltaSigma);
    
    // Convertir en kilomètres et retourner
    return distance / 1000;
  }
  
  // Méthode de secours utilisant la formule de Haversine
  double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0; // Rayon moyen de la Terre en kilomètres
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final phi1 = _toRadians(lat1);
    final phi2 = _toRadians(lat2);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
             math.sin(dLon / 2) * math.sin(dLon / 2) * 
             math.cos(phi1) * math.cos(phi2);
    
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }
  
  // Conversion de degrés en radians avec une précision élevée
  double _toRadians(double degree) {
    return degree * (math.pi / 180.0);
  }
}
