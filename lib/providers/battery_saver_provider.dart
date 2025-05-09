import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BatterySaverProvider extends ChangeNotifier {
  final Battery _battery = Battery();
  final String _batterySaverEnabledKey = 'battery_saver_enabled';
  final String _autoEnableBatterySaverKey = 'auto_enable_battery_saver';
  final String _batterySaverThresholdKey = 'battery_saver_threshold';
  final String _locationUpdateIntervalKey = 'location_update_interval';
  
  bool _batterySaverEnabled = false;
  bool _autoEnableBatterySaver = true;
  int _batterySaverThreshold = 20; // Pourcentage de batterie
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;
  int _locationUpdateInterval = 30; // Secondes
  
  Timer? _batteryCheckTimer;
  
  bool get batterySaverEnabled => _batterySaverEnabled;
  bool get autoEnableBatterySaver => _autoEnableBatterySaver;
  int get batterySaverThreshold => _batterySaverThreshold;
  int get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;
  int get locationUpdateInterval => _locationUpdateInterval;
  
  BatterySaverProvider() {
    _loadSettings();
    _startBatteryMonitoring();
  }
  
  @override
  void dispose() {
    _batteryCheckTimer?.cancel();
    super.dispose();
  }
  
  /// Charge les paramètres du mode économie de batterie
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _batterySaverEnabled = prefs.getBool(_batterySaverEnabledKey) ?? false;
      _autoEnableBatterySaver = prefs.getBool(_autoEnableBatterySaverKey) ?? true;
      _batterySaverThreshold = prefs.getInt(_batterySaverThresholdKey) ?? 20;
      _locationUpdateInterval = prefs.getInt(_locationUpdateIntervalKey) ?? 30;
      
      await _updateBatteryInfo();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des paramètres: $e');
    }
  }
  
  /// Démarre la surveillance de la batterie
  void _startBatteryMonitoring() {
    _batteryCheckTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      await _updateBatteryInfo();
      _checkBatterySaverConditions();
    });
  }
  
  /// Met à jour les informations de la batterie
  Future<void> _updateBatteryInfo() async {
    try {
      _batteryLevel = await _battery.batteryLevel;
      _batteryState = await _battery.batteryState;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des informations de batterie: $e');
    }
  }
  
  /// Vérifie si les conditions pour activer le mode économie de batterie sont remplies
  void _checkBatterySaverConditions() {
    if (_autoEnableBatterySaver && 
        !_batterySaverEnabled && 
        _batteryLevel <= _batterySaverThreshold) {
      _setBatterySaverEnabled(true);
    }
  }
  
  /// Active ou désactive le mode économie de batterie
  Future<void> setBatterySaverEnabled(bool enabled) async {
    await _setBatterySaverEnabled(enabled);
  }
  
  /// Implémentation interne pour activer/désactiver le mode économie de batterie
  Future<void> _setBatterySaverEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_batterySaverEnabledKey, enabled);
      
      _batterySaverEnabled = enabled;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la modification du mode économie de batterie: $e');
    }
  }
  
  /// Définit si le mode économie de batterie doit s'activer automatiquement
  Future<void> setAutoEnableBatterySaver(bool autoEnable) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoEnableBatterySaverKey, autoEnable);
      
      _autoEnableBatterySaver = autoEnable;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la modification du paramètre auto: $e');
    }
  }
  
  /// Définit le seuil de batterie pour l'activation automatique
  Future<void> setBatterySaverThreshold(int threshold) async {
    if (threshold < 5 || threshold > 50) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_batterySaverThresholdKey, threshold);
      
      _batterySaverThreshold = threshold;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la modification du seuil: $e');
    }
  }
  
  /// Définit l'intervalle de mise à jour de la position
  Future<void> setLocationUpdateInterval(int seconds) async {
    if (seconds < 5 || seconds > 300) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_locationUpdateIntervalKey, seconds);
      
      _locationUpdateInterval = seconds;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la modification de l\'intervalle: $e');
    }
  }
  
  /// Obtient l'intervalle de mise à jour de la position en fonction du mode batterie
  int getEffectiveLocationUpdateInterval() {
    if (_batterySaverEnabled) {
      // En mode économie de batterie, on utilise l'intervalle configuré
      return _locationUpdateInterval;
    } else {
      // En mode normal, on utilise un intervalle plus court
      return 5; // 5 secondes par défaut
    }
  }
}
