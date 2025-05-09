import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/offline_map_service.dart';

class OfflineMapsProvider extends ChangeNotifier {
  final OfflineMapService _offlineMapService = OfflineMapService();
  
  List<Map<String, dynamic>> _downloadedRegions = [];
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _error;
  
  List<Map<String, dynamic>> get downloadedRegions => _downloadedRegions;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  String? get error => _error;
  
  OfflineMapsProvider() {
    loadDownloadedRegions();
  }
  
  /// Charge la liste des régions téléchargées
  Future<void> loadDownloadedRegions() async {
    try {
      _downloadedRegions = await _offlineMapService.getDownloadedRegions();
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des régions: $e';
      notifyListeners();
    }
  }
  
  /// Télécharge une région pour une utilisation hors-ligne
  Future<bool> downloadRegion(LatLng center, double radiusKm, {int minZoom = 13, int maxZoom = 16}) async {
    if (_isDownloading) return false;
    
    _isDownloading = true;
    _downloadProgress = 0.0;
    _error = null;
    notifyListeners();
    
    try {
      // Simuler la progression du téléchargement
      _startProgressSimulation();
      
      final success = await _offlineMapService.downloadRegion(center, radiusKm, minZoom, maxZoom);
      
      if (success) {
        await loadDownloadedRegions();
      } else {
        _error = 'Échec du téléchargement de la région';
      }
      
      _isDownloading = false;
      _downloadProgress = 1.0;
      notifyListeners();
      
      return success;
    } catch (e) {
      _isDownloading = false;
      _error = 'Erreur lors du téléchargement: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Supprime une région téléchargée
  Future<bool> deleteRegion(LatLng center, double radiusKm) async {
    try {
      final success = await _offlineMapService.deleteRegion(center, radiusKm);
      
      if (success) {
        await loadDownloadedRegions();
      } else {
        _error = 'Échec de la suppression de la région';
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Vérifie si une tuile est disponible hors-ligne
  Future<bool> isTileAvailable(int z, int x, int y) async {
    return await _offlineMapService.isTileAvailable(z, x, y);
  }
  
  /// Obtient le chemin vers une tuile hors-ligne
  Future<String?> getOfflineTilePath(int z, int x, int y) async {
    return await _offlineMapService.getOfflineTilePath(z, x, y);
  }
  
  /// Simule la progression du téléchargement
  void _startProgressSimulation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isDownloading && _downloadProgress < 0.95) {
        _downloadProgress += 0.05;
        notifyListeners();
        _startProgressSimulation();
      }
    });
  }
}
