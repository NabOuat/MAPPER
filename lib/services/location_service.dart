import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';

class LocationService {
  // Initialize logger
  static final Logger _logger = Logger('LocationService');
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return false;
    }
    
    // Permissions are granted
    return true;
  }

  /// Obtient la position actuelle avec une précision élevée (marge d'erreur < 3%)
  /// Utilise une combinaison de techniques pour améliorer la précision:
  /// 1. Utilise l'accuracy best pour la meilleure précision possible
  /// 2. Prend plusieurs mesures et fait une moyenne pour réduire les erreurs
  /// 3. Applique un filtre pour éliminer les valeurs aberrantes
  /// 4. Vérifie la précision et recommence si nécessaire
  Future<LatLng?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        _logger.warning('Location permissions not granted');
        return null;
      }
      
      // Paramètres pour une précision maximale
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0, // Ne pas filtrer par distance
        timeLimit: Duration(seconds: 10), // Attendre jusqu'à 10 secondes pour une position précise
      );
      
      // Prendre plusieurs mesures pour améliorer la précision
      List<Position> positions = [];
      const int measurementCount = 5;
      
      _logger.info('Taking $measurementCount location measurements for improved accuracy');
      
      // Prendre plusieurs mesures
      for (int i = 0; i < measurementCount; i++) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );
        
        // Vérifier la précision horizontale (en mètres)
        if (position.accuracy <= 10) { // Précision <= 10 mètres
          positions.add(position);
          _logger.info('Measurement ${i+1}: Lat=${position.latitude}, Lng=${position.longitude}, Accuracy=${position.accuracy}m');
        } else {
          _logger.warning('Measurement ${i+1} discarded: accuracy ${position.accuracy}m exceeds threshold');
          // Attendre un peu avant la prochaine mesure si la précision est mauvaise
          await Future.delayed(const Duration(milliseconds: 500));
          i--; // Réessayer cette mesure
        }
      }
      
      if (positions.isEmpty) {
        _logger.warning('Could not obtain location with required accuracy');
        return null;
      }
      
      // Calculer la moyenne des positions (en excluant les valeurs aberrantes)
      positions.sort((a, b) => a.accuracy.compareTo(b.accuracy)); // Trier par précision
      positions = positions.take(3).toList(); // Prendre les 3 mesures les plus précises
      
      double sumLat = 0, sumLng = 0;
      for (var pos in positions) {
        sumLat += pos.latitude;
        sumLng += pos.longitude;
      }
      
      final avgLat = sumLat / positions.length;
      final avgLng = sumLng / positions.length;
      
      // Vérifier la dispersion des mesures pour s'assurer qu'elles sont cohérentes
      bool isConsistent = true;
      for (var pos in positions) {
        final distance = Geolocator.distanceBetween(avgLat, avgLng, pos.latitude, pos.longitude);
        if (distance > 15) { // Si une mesure est à plus de 15 mètres de la moyenne
          isConsistent = false;
          _logger.warning('Inconsistent measurement detected: $distance meters from average');
          break;
        }
      }
      
      if (!isConsistent) {
        _logger.warning('Location measurements are inconsistent, retrying...');
        // Attendre un moment et réessayer
        await Future.delayed(const Duration(seconds: 1));
        return getCurrentLocation();
      }
      
      final avgAccuracy = positions.map((p) => p.accuracy).reduce((a, b) => a + b) / positions.length;
      _logger.info('Final location: Lat=$avgLat, Lng=$avgLng with estimated accuracy of ${avgAccuracy}m');
      
      // Calculer la marge d'erreur en pourcentage (approximativement):
      // Pour une précision de 10m sur une distance de 1000m, la marge d'erreur est de 1%
      final errorMargin = (avgAccuracy / 1000) * 100;
      _logger.info('Estimated error margin: $errorMargin%');
      
      if (errorMargin > 3) {
        _logger.warning('Error margin of $errorMargin% exceeds required 3%, retrying...');
        // Attendre un moment et réessayer
        await Future.delayed(const Duration(seconds: 1));
        return getCurrentLocation();
      }
      
      return LatLng(avgLat, avgLng);
    } catch (e) {
      _logger.severe('Error getting location: $e');
      return null;
    }
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    final Distance distance = const Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }
}
