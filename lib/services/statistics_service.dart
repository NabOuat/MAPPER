import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '../models/place.dart';

class StatisticsService {
  // Initialize logger
  static final Logger _logger = Logger('StatisticsService');
  static const String _totalDistanceKey = 'stats_total_distance';
  static const String _placesAddedKey = 'stats_places_added';
  static const String _placesVisitedKey = 'stats_places_visited';
  static const String _lastActiveDayKey = 'stats_last_active_day';
  static const String _activeDaysKey = 'stats_active_days';
  static const String _dailyPlacesAddedKey = 'stats_daily_places_added';
  static const String _categoriesAddedKey = 'stats_categories_added';
  
  /// Enregistre une nouvelle distance parcourue
  Future<void> addDistance(double distanceKm) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentDistance = prefs.getDouble(_totalDistanceKey) ?? 0.0;
      await prefs.setDouble(_totalDistanceKey, currentDistance + distanceKm);
      
      // Mettre à jour le jour actif
      await _updateActiveDay();
    } catch (e) {
      _logger.warning('Erreur lors de l\'ajout de distance: $e');
    }
  }
  
  /// Enregistre l'ajout d'un nouveau lieu
  Future<void> recordPlaceAdded(Place place) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Incrémenter le nombre total de lieux ajoutés
      final placesAdded = prefs.getInt(_placesAddedKey) ?? 0;
      await prefs.setInt(_placesAddedKey, placesAdded + 1);
      
      // Mettre à jour les statistiques par catégorie
      final categoriesMap = prefs.getStringList(_categoriesAddedKey) ?? [];
      final category = place.category;
      
      bool categoryFound = false;
      final updatedCategories = <String>[];
      
      for (final item in categoriesMap) {
        final parts = item.split(':');
        if (parts.length == 2) {
          final cat = parts[0];
          final count = int.parse(parts[1]);
          
          if (cat == category) {
            updatedCategories.add('$cat:${count + 1}');
            categoryFound = true;
          } else {
            updatedCategories.add(item);
          }
        }
      }
      
      if (!categoryFound) {
        updatedCategories.add('$category:1');
      }
      
      await prefs.setStringList(_categoriesAddedKey, updatedCategories);
      
      // Mettre à jour les statistiques quotidiennes
      final today = _getDateString(DateTime.now());
      final dailyStats = prefs.getStringList(_dailyPlacesAddedKey) ?? [];
      
      bool todayFound = false;
      final updatedDailyStats = <String>[];
      
      for (final item in dailyStats) {
        final parts = item.split(':');
        if (parts.length == 2) {
          final date = parts[0];
          final count = int.parse(parts[1]);
          
          if (date == today) {
            updatedDailyStats.add('$date:${count + 1}');
            todayFound = true;
          } else {
            updatedDailyStats.add(item);
          }
        }
      }
      
      if (!todayFound) {
        updatedDailyStats.add('$today:1');
      }
      
      // Limiter l'historique à 30 jours
      if (updatedDailyStats.length > 30) {
        updatedDailyStats.sort((a, b) {
          final dateA = a.split(':')[0];
          final dateB = b.split(':')[0];
          return dateB.compareTo(dateA); // Tri décroissant
        });
        updatedDailyStats.removeRange(30, updatedDailyStats.length);
      }
      
      await prefs.setStringList(_dailyPlacesAddedKey, updatedDailyStats);
      
      // Mettre à jour le jour actif
      await _updateActiveDay();
    } catch (e) {
      _logger.warning('Erreur lors de l\'enregistrement du lieu ajouté: $e');
    }
  }
  
  /// Enregistre la visite d'un lieu
  Future<void> recordPlaceVisited(Place place) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final placesVisited = prefs.getInt(_placesVisitedKey) ?? 0;
      await prefs.setInt(_placesVisitedKey, placesVisited + 1);
      
      // Mettre à jour le jour actif
      await _updateActiveDay();
    } catch (e) {
      _logger.warning('Erreur lors de l\'enregistrement du lieu visité: $e');
    }
  }
  
  /// Met à jour le jour actif
  Future<void> _updateActiveDay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getDateString(DateTime.now());
      final lastActiveDay = prefs.getString(_lastActiveDayKey) ?? '';
      
      if (lastActiveDay != today) {
        await prefs.setString(_lastActiveDayKey, today);
        
        // Mettre à jour le nombre de jours actifs
        final activeDays = prefs.getStringList(_activeDaysKey) ?? [];
        if (!activeDays.contains(today)) {
          activeDays.add(today);
          await prefs.setStringList(_activeDaysKey, activeDays);
        }
      }
    } catch (e) {
      _logger.warning('Erreur lors de la mise à jour du jour actif: $e');
    }
  }
  
  /// Obtient la distance totale parcourue
  Future<double> getTotalDistance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_totalDistanceKey) ?? 0.0;
    } catch (e) {
      _logger.warning('Erreur lors de la récupération de la distance totale: $e');
      return 0.0;
    }
  }
  
  /// Obtient le nombre total de lieux ajoutés
  Future<int> getTotalPlacesAdded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_placesAddedKey) ?? 0;
    } catch (e) {
      _logger.warning('Erreur lors de la récupération du nombre de lieux ajoutés: $e');
      return 0;
    }
  }
  
  /// Obtient le nombre total de lieux visités
  Future<int> getTotalPlacesVisited() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_placesVisitedKey) ?? 0;
    } catch (e) {
      _logger.warning('Erreur lors de la récupération du nombre de lieux visités: $e');
      return 0;
    }
  }
  
  /// Obtient le nombre de jours actifs
  Future<int> getActiveDaysCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeDays = prefs.getStringList(_activeDaysKey) ?? [];
      return activeDays.length;
    } catch (e) {
      _logger.warning('Erreur lors de la récupération du nombre de jours actifs: $e');
      return 0;
    }
  }
  
  /// Obtient les statistiques par catégorie
  Future<Map<String, int>> getCategoryStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesMap = prefs.getStringList(_categoriesAddedKey) ?? [];
      final result = <String, int>{};
      
      for (final item in categoriesMap) {
        final parts = item.split(':');
        if (parts.length == 2) {
          result[parts[0]] = int.parse(parts[1]);
        }
      }
      
      return result;
    } catch (e) {
      _logger.warning('Erreur lors de la récupération des stats par catégorie: $e');
      return {};
    }
  }
  
  /// Obtient les statistiques quotidiennes
  Future<Map<String, int>> getDailyStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dailyStats = prefs.getStringList(_dailyPlacesAddedKey) ?? [];
      final result = <String, int>{};
      
      for (final item in dailyStats) {
        final parts = item.split(':');
        if (parts.length == 2) {
          result[parts[0]] = int.parse(parts[1]);
        }
      }
      
      return result;
    } catch (e) {
      _logger.warning('Erreur lors de la récupération des stats quotidiennes: $e');
      return {};
    }
  }
  
  /// Obtient toutes les statistiques
  Future<Map<String, dynamic>> getAllStats() async {
    final totalDistance = await getTotalDistance();
    final placesAdded = await getTotalPlacesAdded();
    final placesVisited = await getTotalPlacesVisited();
    final activeDays = await getActiveDaysCount();
    final categoryStats = await getCategoryStats();
    final dailyStats = await getDailyStats();
    
    return {
      'totalDistance': totalDistance,
      'placesAdded': placesAdded,
      'placesVisited': placesVisited,
      'activeDays': activeDays,
      'categoryStats': categoryStats,
      'dailyStats': dailyStats,
    };
  }
  
  /// Convertit une date en chaîne de caractères (format YYYY-MM-DD)
  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
