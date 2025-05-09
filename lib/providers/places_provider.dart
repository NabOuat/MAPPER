import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/place.dart';
import '../services/local_storage_service.dart';
import '../services/location_service.dart';

class PlacesProvider extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  final LocationService _locationService = LocationService();
  
  List<Place> _places = [];
  List<Place> _filteredPlaces = [];
  String _searchQuery = '';
  String _filterCategory = '';
  bool _isLoading = false;
  String? _error;

  List<Place> get places => _filteredPlaces.isEmpty && _searchQuery.isEmpty && _filterCategory.isEmpty
      ? _places
      : _filteredPlaces;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get filterCategory => _filterCategory;

  PlacesProvider() {
    loadPlaces();
  }

  Future<void> loadPlaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _places = await _storageService.getPlaces();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des lieux: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Place?> addPlace(String name, {String category = 'Autre'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final location = await _locationService.getCurrentLocation();
      
      if (location == null) {
        _error = 'Impossible d\'obtenir votre position actuelle';
        _isLoading = false;
        notifyListeners();
        return null;
      }
      
      final newPlace = await _storageService.addPlace(
        name, 
        location.latitude, 
        location.longitude,
        category: category
      );
      
      _places.add(newPlace);
      _isLoading = false;
      notifyListeners();
      
      return newPlace;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout du lieu: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  List<Place> getPlacesByUser(String userId) {
    return _places.where((place) => place.userId == userId).toList();
  }

  List<Place> getPlacesNearby(LatLng currentLocation, double radiusKm) {
    return _places.where((place) {
      final placeLocation = LatLng(place.latitude, place.longitude);
      final distance = _locationService.calculateDistance(
        currentLocation, 
        placeLocation
      );
      return distance <= radiusKm;
    }).toList();
  }
  
  /// Recherche de lieux par nom
  void searchPlaces(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
  }
  
  /// Filtrage des lieux par catégorie
  void filterByCategory(String category) {
    _filterCategory = category;
    _applyFilters();
  }
  
  /// Réinitialiser les filtres
  void resetFilters() {
    _searchQuery = '';
    _filterCategory = '';
    _filteredPlaces = [];
    notifyListeners();
  }
  
  /// Appliquer les filtres (recherche et catégorie)
  void _applyFilters() {
    if (_searchQuery.isEmpty && _filterCategory.isEmpty) {
      _filteredPlaces = [];
    } else {
      _filteredPlaces = _places.where((place) {
        bool matchesSearch = _searchQuery.isEmpty || 
            place.name.toLowerCase().contains(_searchQuery) ||
            place.userName.toLowerCase().contains(_searchQuery);
            
        bool matchesCategory = _filterCategory.isEmpty || 
            place.category == _filterCategory;
            
        return matchesSearch && matchesCategory;
      }).toList();
    }
    
    notifyListeners();
  }
}
