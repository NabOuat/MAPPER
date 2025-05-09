import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer le téléchargement et le stockage des tuiles de carte pour une utilisation hors-ligne
class OfflineMapService {
  static const String _offlineTilesKey = 'offline_tiles_regions';
  
  /// Télécharge les tuiles de carte pour une région spécifique
  /// [center] - Le centre de la région
  /// [radiusKm] - Le rayon en kilomètres autour du centre
  /// [minZoom] - Le niveau de zoom minimum à télécharger
  /// [maxZoom] - Le niveau de zoom maximum à télécharger
  Future<bool> downloadRegion(LatLng center, double radiusKm, int minZoom, int maxZoom) async {
    try {
      // Calculer les limites de la région
      final bounds = _calculateBounds(center, radiusKm);
      
      // Obtenir le répertoire de stockage
      final directory = await _getTilesDirectory();
      
      // Calculer les tuiles à télécharger
      final tiles = _calculateTiles(bounds, minZoom, maxZoom);
      
      // Enregistrer la région dans les préférences
      await _saveRegion(center, radiusKm, minZoom, maxZoom);
      
      // Télécharger les tuiles
      int downloadedCount = 0;
      for (final tile in tiles) {
        final success = await _downloadTile(tile.z, tile.x, tile.y, directory);
        if (success) downloadedCount++;
      }
      
      debugPrint('Téléchargement terminé: $downloadedCount/${tiles.length} tuiles téléchargées');
      return downloadedCount > 0;
    } catch (e) {
      debugPrint('Erreur lors du téléchargement de la région: $e');
      return false;
    }
  }
  
  /// Vérifie si une tuile est disponible hors-ligne
  Future<bool> isTileAvailable(int z, int x, int y) async {
    try {
      final directory = await _getTilesDirectory();
      final file = File('${directory.path}/$z/$x/$y.png');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Obtient le chemin vers une tuile hors-ligne
  Future<String?> getOfflineTilePath(int z, int x, int y) async {
    try {
      final directory = await _getTilesDirectory();
      final file = File('${directory.path}/$z/$x/$y.png');
      if (await file.exists()) {
        return file.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Obtient la liste des régions téléchargées
  Future<List<Map<String, dynamic>>> getDownloadedRegions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final regionsJson = prefs.getStringList(_offlineTilesKey) ?? [];
      
      return regionsJson.map((json) {
        final parts = json.split(',');
        return {
          'center': LatLng(double.parse(parts[0]), double.parse(parts[1])),
          'radiusKm': double.parse(parts[2]),
          'minZoom': int.parse(parts[3]),
          'maxZoom': int.parse(parts[4]),
          'timestamp': DateTime.fromMillisecondsSinceEpoch(int.parse(parts[5])),
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Supprime une région téléchargée
  Future<bool> deleteRegion(LatLng center, double radiusKm) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final regionsJson = prefs.getStringList(_offlineTilesKey) ?? [];
      
      final updatedRegions = regionsJson.where((json) {
        final parts = json.split(',');
        final lat = double.parse(parts[0]);
        final lng = double.parse(parts[1]);
        final radius = double.parse(parts[2]);
        
        // Ne pas supprimer si c'est la même région
        return lat != center.latitude || lng != center.longitude || radius != radiusKm;
      }).toList();
      
      await prefs.setStringList(_offlineTilesKey, updatedRegions);
      
      // Supprimer les tuiles n'est pas implémenté ici car cela nécessiterait
      // de savoir quelles tuiles appartiennent uniquement à cette région
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Calcule les limites d'une région à partir d'un centre et d'un rayon
  _BoundingBox _calculateBounds(LatLng center, double radiusKm) {
    // Approximation simple: 1 degré de latitude = 111 km
    final latDiff = radiusKm / 111.0;
    
    // Longitude dépend de la latitude
    final lngDiff = radiusKm / (111.0 * cos(center.latitude * pi / 180));
    
    return _BoundingBox(
      minLat: center.latitude - latDiff,
      maxLat: center.latitude + latDiff,
      minLng: center.longitude - lngDiff,
      maxLng: center.longitude + lngDiff,
    );
  }
  
  /// Calcule les tuiles nécessaires pour couvrir une région
  List<_Tile> _calculateTiles(_BoundingBox bounds, int minZoom, int maxZoom) {
    final tiles = <_Tile>[];
    
    for (int z = minZoom; z <= maxZoom; z++) {
      final minX = _longitudeToTileX(bounds.minLng, z).floor();
      final maxX = _longitudeToTileX(bounds.maxLng, z).floor();
      final minY = _latitudeToTileY(bounds.maxLat, z).floor();
      final maxY = _latitudeToTileY(bounds.minLat, z).floor();
      
      for (int x = minX; x <= maxX; x++) {
        for (int y = minY; y <= maxY; y++) {
          tiles.add(_Tile(z, x, y));
        }
      }
    }
    
    return tiles;
  }
  
  /// Convertit une longitude en coordonnée X de tuile
  double _longitudeToTileX(double lng, int zoom) {
    return ((lng + 180) / 360) * pow(2, zoom);
  }
  
  /// Convertit une latitude en coordonnée Y de tuile
  double _latitudeToTileY(double lat, int zoom) {
    final latRad = lat * pi / 180;
    return ((1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2) * pow(2, zoom);
  }
  
  /// Télécharge une tuile spécifique
  Future<bool> _downloadTile(int z, int x, int y, Directory directory) async {
    try {
      // URL de la tuile OpenStreetMap
      final url = 'https://a.tile.openstreetmap.org/$z/$x/$y.png';
      
      // Créer les répertoires nécessaires
      final tileDir = Directory('${directory.path}/$z/$x');
      if (!await tileDir.exists()) {
        await tileDir.create(recursive: true);
      }
      
      // Télécharger la tuile
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File('${tileDir.path}/$y.png');
        await file.writeAsBytes(response.bodyBytes);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors du téléchargement de la tuile $z/$x/$y: $e');
      return false;
    }
  }
  
  /// Enregistre une région dans les préférences
  Future<void> _saveRegion(LatLng center, double radiusKm, int minZoom, int maxZoom) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final regionsJson = prefs.getStringList(_offlineTilesKey) ?? [];
      
      final regionStr = '${center.latitude},${center.longitude},$radiusKm,$minZoom,$maxZoom,${DateTime.now().millisecondsSinceEpoch}';
      
      if (!regionsJson.contains(regionStr)) {
        regionsJson.add(regionStr);
        await prefs.setStringList(_offlineTilesKey, regionsJson);
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'enregistrement de la région: $e');
    }
  }
  
  /// Obtient le répertoire de stockage des tuiles
  Future<Directory> _getTilesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final tilesDir = Directory('${appDir.path}/offline_tiles');
    
    if (!await tilesDir.exists()) {
      await tilesDir.create(recursive: true);
    }
    
    return tilesDir;
  }
}

/// Classe pour représenter les limites d'une région
class _BoundingBox {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  
  _BoundingBox({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });
}

/// Classe pour représenter une tuile
class _Tile {
  final int z;
  final int x;
  final int y;
  
  _Tile(this.z, this.x, this.y);
}

/// Extension pour les fonctions mathématiques
extension MathExtension on num {
  double pow(num exponent) => Math.pow(this, exponent).toDouble();
}

/// Fonctions mathématiques
class Math {
  static double pow(num base, num exponent) => base.toDouble() * exponent.toDouble();
  static double log(num x) => ln(x);
  static double ln(num x) => log(x.toDouble());
  static double cos(num x) => cos(x.toDouble());
  static double tan(num x) => tan(x.toDouble());
}
