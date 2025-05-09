import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_categories.dart';
import '../providers/places_provider.dart';
import '../services/location_service.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({Key? key}) : super(key: key);

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final TextEditingController _nameController = TextEditingController();
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _selectedCategory = AppCategories.categories.last; // 'Autre' par défaut

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      final location = await _locationService.getCurrentLocation();
      
      setState(() {
        _currentLocation = location;
        _isLoadingLocation = false;
      });
      
      if (location != null) {
        _mapController.move(location, 15);
      } else {
        setState(() {
          _errorMessage = 'Impossible d\'obtenir votre position actuelle';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _errorMessage = 'Erreur de localisation: $e';
      });
    }
  }

  Future<void> _submitPlace() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer un nom pour ce lieu';
      });
      return;
    }

    if (_currentLocation == null) {
      setState(() {
        _errorMessage = 'Position non disponible. Veuillez réessayer.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
      final place = await placesProvider.addPlace(
        _nameController.text.trim(),
        category: _selectedCategory,
      );
      
      if (place != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lieu ajouté avec succès !'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        context.pop();
      } else {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Erreur lors de l\'ajout du lieu';
        });
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Erreur: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un lieu'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte avec position actuelle
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(color: AppColors.borderDark),
                ),
                clipBehavior: Clip.antiAlias,
                child: _isLoadingLocation
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: AppDimensions.paddingM),
                            Text('Récupération de votre position...'),
                          ],
                        ),
                      )
                    : _currentLocation == null
                        ? const Center(
                            child: Text('Position non disponible'),
                          )
                        : FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _currentLocation!,
                              initialZoom: 15,
                              minZoom: 3,
                              maxZoom: 18,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.pingmapper.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _currentLocation!,
                                    width: 40,
                                    height: 40,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.accentCyan.withAlpha(179),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.my_location,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
              ),
              
              const SizedBox(height: AppDimensions.paddingL),
              
              // Coordonnées
              if (_currentLocation != null)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.accentCyan),
                      const SizedBox(width: AppDimensions.paddingS),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Coordonnées',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppDimensions.paddingXS),
                            Text(
                              'Latitude: ${_currentLocation!.latitude.toStringAsFixed(6)}',
                            ),
                            Text(
                              'Longitude: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _getCurrentLocation,
                        tooltip: 'Actualiser la position',
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: AppDimensions.paddingL),
              
              // Champ de saisie du nom du lieu
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du lieu',
                  hintText: 'Ex: Tour Eiffel, Café du coin, etc.',
                  prefixIcon: Icon(Icons.edit_location),
                ),
                maxLength: 50,
                textCapitalization: TextCapitalization.sentences,
              ),
              
              const SizedBox(height: AppDimensions.paddingM),
              
              // Sélection de la catégorie
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: AppDimensions.paddingS, bottom: AppDimensions.paddingS),
                    child: Text(
                      'Catégorie du lieu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentCyan,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.accentCyan),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategory,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.accentCyan),
                        elevation: 16,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                        items: AppCategories.categories.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Text(AppCategories.getIconForCategory(value), style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: AppDimensions.paddingM),
                                Text(
                                  value,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Message d'erreur
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.paddingS),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.errorRed),
                  ),
                ),
              
              const SizedBox(height: AppDimensions.paddingL),
              
              // Bouton d'envoi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _isLoadingLocation ? null : _submitPlace,
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: AppDimensions.paddingM),
                            Text('Enregistrement...'),
                          ],
                        )
                      : const Text('Enregistrer ce lieu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
