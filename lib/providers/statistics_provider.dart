import 'package:flutter/material.dart';
import '../services/statistics_service.dart';
import '../models/place.dart';

class StatisticsProvider extends ChangeNotifier {
  final StatisticsService _statisticsService = StatisticsService();
  
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String? _error;
  
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  StatisticsProvider() {
    loadStatistics();
  }
  
  /// Charge toutes les statistiques
  Future<void> loadStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _stats = await _statisticsService.getAllStats();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des statistiques: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Enregistre l'ajout d'un nouveau lieu
  Future<void> recordPlaceAdded(Place place) async {
    try {
      await _statisticsService.recordPlaceAdded(place);
      await loadStatistics();
    } catch (e) {
      _error = 'Erreur lors de l\'enregistrement du lieu: $e';
      notifyListeners();
    }
  }
  
  /// Enregistre la visite d'un lieu
  Future<void> recordPlaceVisited(Place place) async {
    try {
      await _statisticsService.recordPlaceVisited(place);
      await loadStatistics();
    } catch (e) {
      _error = 'Erreur lors de l\'enregistrement de la visite: $e';
      notifyListeners();
    }
  }
  
  /// Ajoute une distance parcourue
  Future<void> addDistance(double distanceKm) async {
    try {
      await _statisticsService.addDistance(distanceKm);
      await loadStatistics();
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de distance: $e';
      notifyListeners();
    }
  }
  
  /// Obtient les données pour le graphique des catégories
  List<Map<String, dynamic>> getCategoryChartData() {
    final categoryStats = _stats['categoryStats'] as Map<String, dynamic>? ?? {};
    
    final List<Map<String, dynamic>> data = [];
    categoryStats.forEach((category, count) {
      data.add({
        'category': category,
        'count': count,
      });
    });
    
    // Trier par nombre décroissant
    data.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    
    return data;
  }
  
  /// Obtient les données pour le graphique d'activité quotidienne
  List<Map<String, dynamic>> getDailyActivityChartData() {
    final dailyStats = _stats['dailyStats'] as Map<String, dynamic>? ?? {};
    
    final List<Map<String, dynamic>> data = [];
    dailyStats.forEach((date, count) {
      // Convertir la date au format lisible
      final parts = date.split('-');
      if (parts.length == 3) {
        final formattedDate = '${parts[2]}/${parts[1]}';
        data.add({
          'date': formattedDate,
          'count': count,
          'fullDate': date,
        });
      }
    });
    
    // Trier par date croissante
    data.sort((a, b) => (a['fullDate'] as String).compareTo(b['fullDate'] as String));
    
    // Limiter à 7 derniers jours si plus de 7 entrées
    if (data.length > 7) {
      return data.sublist(data.length - 7);
    }
    
    return data;
  }
  
  /// Obtient un résumé des statistiques
  Map<String, dynamic> getStatsSummary() {
    return {
      'totalDistance': _stats['totalDistance'] ?? 0.0,
      'placesAdded': _stats['placesAdded'] ?? 0,
      'placesVisited': _stats['placesVisited'] ?? 0,
      'activeDays': _stats['activeDays'] ?? 0,
    };
  }
}
