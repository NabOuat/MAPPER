import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

enum AppTheme {
  classic,
  ocean,
  forest,
  sunset,
  night,
  custom,
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  AppTheme _currentTheme = AppTheme.classic;
  Color _primaryColor = const Color(0xFF0D1B2A);
  Color _accentColor = const Color(0xFF4ECDC4);
  final PreferencesService _preferencesService = PreferencesService();

  bool get isDarkMode => _isDarkMode;
  AppTheme get currentTheme => _currentTheme;
  Color get primaryColor => _primaryColor;
  Color get accentColor => _accentColor;

  ThemeProvider() {
    _loadThemePreferences();
  }

  Future<void> _loadThemePreferences() async {
    _isDarkMode = await _preferencesService.isDarkMode();
    final themeIndex = await _preferencesService.getThemeIndex();
    _currentTheme = AppTheme.values[themeIndex];
    
    if (_currentTheme == AppTheme.custom) {
      _primaryColor = Color(await _preferencesService.getPrimaryColor());
      _accentColor = Color(await _preferencesService.getAccentColor());
    } else {
      final colors = _getThemeColors(_currentTheme);
      _primaryColor = colors.primaryColor;
      _accentColor = colors.accentColor;
    }
    
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _preferencesService.setDarkMode(_isDarkMode);
    notifyListeners();
  }
  
  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    await _preferencesService.setThemeIndex(theme.index);
    
    if (theme != AppTheme.custom) {
      final colors = _getThemeColors(theme);
      _primaryColor = colors.primaryColor;
      _accentColor = colors.accentColor;
    }
    
    notifyListeners();
  }
  
  Future<void> setCustomColors(Color primary, Color accent) async {
    _primaryColor = primary;
    _accentColor = accent;
    _currentTheme = AppTheme.custom;
    
    await _preferencesService.setThemeIndex(AppTheme.custom.index);
    await _preferencesService.setPrimaryColor(primary.toARGB32());
    await _preferencesService.setAccentColor(accent.toARGB32());
    
    notifyListeners();
  }
  
  /// Obtient les couleurs pour un thème prédéfini
  _ThemeColors _getThemeColors(AppTheme theme) {
    switch (theme) {
      case AppTheme.classic:
        return _ThemeColors(
          primaryColor: const Color(0xFF0D1B2A),
          accentColor: const Color(0xFF4ECDC4),
        );
      case AppTheme.ocean:
        return _ThemeColors(
          primaryColor: const Color(0xFF1A535C),
          accentColor: const Color(0xFF4ECDC4),
        );
      case AppTheme.forest:
        return _ThemeColors(
          primaryColor: const Color(0xFF2D3A3A),
          accentColor: const Color(0xFF7FB069),
        );
      case AppTheme.sunset:
        return _ThemeColors(
          primaryColor: const Color(0xFF2B2D42),
          accentColor: const Color(0xFFEF476F),
        );
      case AppTheme.night:
        return _ThemeColors(
          primaryColor: const Color(0xFF0F0E17),
          accentColor: const Color(0xFFFF8906),
        );
      case AppTheme.custom:
        return _ThemeColors(
          primaryColor: _primaryColor,
          accentColor: _accentColor,
        );
    }
  }
  
  /// Obtient le thème complet pour l'application
  ThemeData getThemeData() {
    final brightness = _isDarkMode ? Brightness.dark : Brightness.light;
    final baseTheme = _isDarkMode
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accentColor,
        primary: _primaryColor,
        secondary: _accentColor,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
  
  /// Obtient le nom du thème actuel
  String getCurrentThemeName() {
    switch (_currentTheme) {
      case AppTheme.classic:
        return 'Classique';
      case AppTheme.ocean:
        return 'Océan';
      case AppTheme.forest:
        return 'Forêt';
      case AppTheme.sunset:
        return 'Coucher de soleil';
      case AppTheme.night:
        return 'Nuit';
      case AppTheme.custom:
        return 'Personnalisé';
    }
  }
}

/// Classe pour stocker les couleurs d'un thème
class _ThemeColors {
  final Color primaryColor;
  final Color accentColor;
  
  _ThemeColors({
    required this.primaryColor,
    required this.accentColor,
  });
}
