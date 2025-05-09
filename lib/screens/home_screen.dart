import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/users_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_categories.dart';
import '../models/place.dart';
import '../providers/places_provider.dart';
import '../providers/theme_provider.dart';
import '../services/location_service.dart';
import '../widgets/place_marker.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final location = await _locationService.getCurrentLocation();
      
      setState(() {
        _currentLocation = location;
        _isLoadingLocation = false;
      });
      
      if (location != null) {
        _mapController.move(location, 13);
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de localisation: $e')),
        );
      }
    }
  }
  
  void _showPlaceDetails(Place place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppDimensions.paddingS),
              Row(
                children: [
                  const Icon(Icons.category, color: AppColors.accentCyan),
                  const SizedBox(width: AppDimensions.paddingS),
                  Text('Catégorie: ${place.category}'),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Row(
                children: [
                  const Icon(Icons.person, color: AppColors.accentCyan),
                  const SizedBox(width: AppDimensions.paddingS),
                  Text('Ajouté par: ${place.userName}'),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.accentCyan),
                  const SizedBox(width: AppDimensions.paddingS),
                  Text(
                    'Le ${_formatDate(place.createdAt)}',
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.accentCyan),
                  const SizedBox(width: AppDimensions.paddingS),
                  Text(
                    '${place.latitude.toStringAsFixed(6)}, ${place.longitude.toStringAsFixed(6)}',
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Ouvrir dans Google Maps ou autre app de navigation
                    Navigator.pop(context);
                  },
                  child: const Text('Ouvrir dans Maps'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  // Fonctionnalité fun en mode hors ligne : Mapper Stories
  void _showMapperStories(BuildContext context) {
    // Liste de filtres pour les stories (comme Instagram/Snapchat)
    final List<Map<String, dynamic>> filters = [
      {
        'name': 'Vintage',
        'color': Colors.brown[200],
        'icon': Icons.filter_vintage,
      },
      {
        'name': 'Nuit',
        'color': Colors.indigo[200],
        'icon': Icons.nightlight_round,
      },
      {
        'name': 'Voyage',
        'color': Colors.amber[200],
        'icon': Icons.flight,
      },
      {
        'name': 'Nature',
        'color': Colors.green[200],
        'icon': Icons.nature,
      },
      {
        'name': 'Urbain',
        'color': Colors.blueGrey[200],
        'icon': Icons.location_city,
      },
    ];
    
    // Index du filtre sélectionné
    int selectedFilterIndex = 0;
    String storyText = '';
    
    // Contrôleur pour le texte de la story
    final TextEditingController storyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.auto_stories, color: AppColors.accentCyan),
              const SizedBox(width: AppDimensions.paddingS),
              const Text(
                'Mapper Stories',
                style: TextStyle(color: AppColors.accentCyan),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.grey,
                iconSize: 20,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Prévisualisation de la story avec le filtre sélectionné
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: filters[selectedFilterIndex]['color'] ?? Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Icône du filtre en arrière-plan
                      Center(
                        child: Icon(
                          filters[selectedFilterIndex]['icon'] ?? Icons.image,
                          size: 80,
                          color: Colors.white.withAlpha(77),
                        ),
                      ),
                      // Texte de la story
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingM),
                          child: Text(
                            storyText.isEmpty ? 'Votre story apparaitra ici' : storyText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 5,
                                  color: Colors.black45,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                
                // Champ de texte pour la story
                TextField(
                  controller: storyController,
                  decoration: const InputDecoration(
                    hintText: 'Partagez votre expérience...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit),
                  ),
                  maxLines: 2,
                  onChanged: (value) {
                    setState(() {
                      storyText = value;
                    });
                  },
                ),
                const SizedBox(height: AppDimensions.paddingM),
                
                // Filtres horizontaux (comme Instagram/Snapchat)
                const Text(
                  'Choisissez un filtre',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppDimensions.paddingS),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFilterIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXS),
                          width: 70,
                          decoration: BoxDecoration(
                            color: filters[index]['color'] ?? Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: selectedFilterIndex == index
                                ? Border.all(color: AppColors.accentCyan, width: 2)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                filters[index]['icon'] ?? Icons.image,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                filters[index]['name'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: storyText.isEmpty
                  ? null
                  : () {
                      // Appeler pop sans arguments
                      Navigator.pop(context);
                      
                      // Afficher un message de confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Votre story a été créée et sera visible lorsque vous serez en ligne'),
                          backgroundColor: AppColors.successGreen,
                          duration: Duration(seconds: 3),
                        ),
                      );
                      
                      // Mettre à jour le score de l'utilisateur (comme pour avoir créé du contenu)
                      // Utiliser Provider.of sans contexte dans la fonction de rappel
                      final usersProvider = Provider.of<UsersProvider>(context, listen: false);
                      final currentUser = usersProvider.currentUser;
                      if (currentUser != null) {
                        // Mettre à jour l'utilisateur avec son score augmenté
                        // Note: updateCurrentUser attend des paramètres nommés, pas un objet User
                        usersProvider.updateCurrentUser(
                          name: currentUser.name,
                          email: currentUser.email,
                          avatarUrl: currentUser.avatarUrl
                        );
                        
                        // Afficher un message de confirmation du score augmenté
                        print('Score augmenté de 5 points pour ${currentUser.name}');
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentCyan,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text('Partager'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final placesProvider = context.watch<PlacesProvider>();
    final places = placesProvider.places;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ping Mapper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              placesProvider.loadPlaces();
              _getCurrentLocation();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Carte avec performances améliorées
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(48.8566, 2.3522), // Paris par défaut
              initialZoom: 13.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              // Améliorer les performances de zoom
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
                enableMultiFingerGestureRace: true,
              ),
              // Optimiser le rendu pour de meilleures performances
              keepAlive: true,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  // Marqueur de position actuelle
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accentCyan.withAlpha(179),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Marqueurs des lieux
              MarkerLayer(
                markers: Provider.of<PlacesProvider>(context)
                    .places
                    .map((place) => Marker(
                          point: LatLng(place.latitude, place.longitude),
                          width: 40,
                          height: 40,
                          child: PlaceMarker(
                            place: place,
                            onTap: () => _showPlaceDetails(place),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
          
          // Barre de recherche et filtres
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre de recherche
                  SearchBarWidget(
                    hintText: 'Rechercher un lieu...',
                    onSearch: (query) {
                      Provider.of<PlacesProvider>(context, listen: false)
                          .searchPlaces(query);
                    },
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingM),
                  
                  // Filtres par catégorie avec combobox
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS, vertical: AppDimensions.paddingXS),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(color: AppColors.accentCyan),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: _selectedCategory,
                        hint: const Row(
                          children: [
                            Icon(Icons.filter_list, color: AppColors.accentCyan, size: 18),
                            SizedBox(width: AppDimensions.paddingS),
                            Text('Filtrer par catégorie', style: TextStyle(color: AppColors.accentCyan)),
                          ],
                        ),
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.accentCyan),
                        elevation: 16,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                          if (value == null) {
                            Provider.of<PlacesProvider>(context, listen: false).resetFilters();
                          } else {
                            Provider.of<PlacesProvider>(context, listen: false).filterByCategory(value);
                          }
                        },
                        items: [
                          // Option "Tous"
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Row(
                              children: [
                                Icon(Icons.all_inclusive, color: AppColors.accentCyan),
                                SizedBox(width: AppDimensions.paddingS),
                                Text('Tous les lieux'),
                              ],
                            ),
                          ),
                          // Options de catégories
                          ...AppCategories.categories.map((category) => DropdownMenuItem<String?>(
                            value: category,
                            child: Row(
                              children: [
                                Text(AppCategories.getIconForCategory(category), style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: AppDimensions.paddingS),
                                Text(category),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Indicateur de chargement de la position
          if (_isLoadingLocation)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: AppDimensions.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.cardDarkBackground : AppColors.cardLightBackground,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accentCyan,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      const Text('Localisation en cours...'),
                    ],
                  ),
                ),
              ),
            ),
            
          // Compteur de lieux
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.cardDarkBackground : AppColors.cardLightBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.place, color: AppColors.accentCyan),
                  const SizedBox(width: AppDimensions.paddingXS),
                  Text(
                    '${places.length} lieux',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.lightTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton de stories (fonctionnalité fun en mode hors ligne)
          FloatingActionButton.small(
            heroTag: 'fun_button',
            onPressed: () => _showMapperStories(context),
            backgroundColor: Colors.amber,
            child: const Icon(Icons.auto_stories, color: Colors.white),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          // Bouton principal pour ajouter un lieu
          FloatingActionButton(
            heroTag: 'add_place_button',
            onPressed: () => context.push('/add-place'),
            backgroundColor: AppColors.accentCyan,
            child: const Icon(Icons.add_location, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
