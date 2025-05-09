import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Clés pour les préférences
  static const String _darkModeKey = 'darkMode';
  static const String _languageKey = 'language';
  static const String _themeIndexKey = 'themeIndex';
  static const String _primaryColorKey = 'primaryColor';
  static const String _accentColorKey = 'accentColor';
  static const String _batterySaverEnabledKey = 'batterySaverEnabled';
  static const String _batterySaverThresholdKey = 'batterySaverThreshold';
  static const String _locationUpdateIntervalKey = 'locationUpdateInterval';
  static const String _notificationsEnabledKey = 'notificationsEnabled';
  static const String _offlineMapsEnabledKey = 'offlineMapsEnabled';

  // Singleton pattern
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  // Theme preferences
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? true; // Default to dark mode
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<int> getThemeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_themeIndexKey) ?? 0; // Default to classic theme
  }

  Future<void> setThemeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeIndexKey, index);
  }

  Future<int> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_primaryColorKey) ?? 0xFF0D1B2A; // Default primary color
  }

  Future<void> setPrimaryColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, colorValue);
  }

  Future<int> getAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_accentColorKey) ?? 0xFF4ECDC4; // Default accent color
  }

  Future<void> setAccentColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, colorValue);
  }

  // Language preferences
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'fr'; // Default to French
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
  
  // Battery saver preferences
  Future<bool> isBatterySaverEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_batterySaverEnabledKey) ?? false;
  }
  
  Future<void> setBatterySaverEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_batterySaverEnabledKey, value);
  }
  
  Future<int> getBatterySaverThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_batterySaverThresholdKey) ?? 20; // Default 20%
  }
  
  Future<void> setBatterySaverThreshold(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_batterySaverThresholdKey, value);
  }
  
  Future<int> getLocationUpdateInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_locationUpdateIntervalKey) ?? 5; // Default 5 seconds
  }
  
  Future<void> setLocationUpdateInterval(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_locationUpdateIntervalKey, seconds);
  }
  
  // Notifications preferences
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }
  
  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
  }
  
  // Offline maps preferences
  Future<bool> areOfflineMapsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_offlineMapsEnabledKey) ?? false;
  }
  
  Future<void> setOfflineMapsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineMapsEnabledKey, value);
  }
}
