/// Liste des catégories de lieux disponibles dans l'application
class AppCategories {
  static const List<String> categories = [
    'Restaurant',
    'Hôtel',
    'Monument',
    'Parc',
    'Magasin',
    'Transport',
    'Loisir',
    'Sport',
    'Santé',
    'Éducation',
    'Service',
    'Autre'
  ];
  
  /// Obtenir l'icône correspondant à une catégorie
  static String getIconForCategory(String category) {
    switch (category) {
      case 'Restaurant':
        return '🍽️';
      case 'Hôtel':
        return '🏨';
      case 'Monument':
        return '🏛️';
      case 'Parc':
        return '🌳';
      case 'Magasin':
        return '🛒';
      case 'Transport':
        return '🚆';
      case 'Loisir':
        return '🎭';
      case 'Sport':
        return '⚽';
      case 'Santé':
        return '🏥';
      case 'Éducation':
        return '🎓';
      case 'Service':
        return '🔧';
      default:
        return '📍';
    }
  }
}
