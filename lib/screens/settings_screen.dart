import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Removed unused import
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../providers/theme_provider.dart';
import '../providers/users_provider.dart';
import '../services/local_storage_service.dart';
import '../services/preferences_service.dart';
// Removed unused import

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isUpdating = false;
  
  // Contrôleurs pour les paramètres de batterie
  final TextEditingController _batteryThresholdController = TextEditingController();
  final TextEditingController _locationIntervalController = TextEditingController();
  
  // Removed unused fields

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBatterySettings();
    _loadThemeColors();
  }
  
  Future<void> _loadBatterySettings() async {
    try {
      final preferencesService = Provider.of<PreferencesService>(context, listen: false);
      final threshold = await preferencesService.getBatterySaverThreshold();
      final interval = await preferencesService.getLocationUpdateInterval();
      
      setState(() {
        _batteryThresholdController.text = threshold.toString();
        _locationIntervalController.text = interval.toString();
      });
    } catch (e) {
      // Valeurs par défaut en cas d'erreur
      _batteryThresholdController.text = '20';
      _locationIntervalController.text = '5';
    }
  }
  
  void _loadThemeColors() {
    // Theme colors are now handled directly by the ThemeProvider
    // No need to store local copies
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _batteryThresholdController.dispose();
    _locationIntervalController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = Provider.of<UsersProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await Provider.of<UsersProvider>(context, listen: false).updateCurrentUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les données'),
        content: const Text(
          'Êtes-vous sûr de vouloir réinitialiser toutes les données ? '
          'Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Réinitialiser les données
      final storageService = LocalStorageService();
      await storageService.initializeMockData();

      // Recharger les données
      if (mounted) {
        Provider.of<UsersProvider>(context, listen: false).loadUsers();
        _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données réinitialisées avec succès'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thème
            const Text(
              'Apparence',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Card(
              child: SwitchListTile(
                title: const Text('Mode sombre'),
                subtitle: const Text('Activer le thème sombre'),
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.accentCyan,
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingXL),

            // Profil
            const Text(
              'Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdating ? null : _updateProfile,
                        child: _isUpdating
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
                                  Text('Mise à jour...'),
                                ],
                              )
                            : const Text('Mettre à jour le profil'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingXL),

            // Données
            const Text(
              'Données',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.sync, color: AppColors.accentCyan),
                    title: const Text('Synchroniser les données'),
                    subtitle: const Text('Mettre à jour les données avec le serveur'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Synchronisation réussie'),
                          backgroundColor: AppColors.successGreen,
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.storage, color: AppColors.accentCyan),
                    title: const Text('Données en cache'),
                    subtitle: const Text('Effacer les données en cache'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cache effacé avec succès'),
                          backgroundColor: AppColors.successGreen,
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.refresh, color: AppColors.errorRed),
                    title: const Text('Réinitialiser les données'),
                    subtitle: const Text('Effacer toutes les données et revenir à l\'état initial'),
                    onTap: _resetData,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingXL),

            // À propos
            const Text(
              'À propos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info, color: AppColors.accentCyan),
                    title: const Text('Version'),
                    subtitle: const Text('1.0.0'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.description, color: AppColors.accentCyan),
                    title: const Text('Conditions d\'utilisation'),
                    onTap: () {
                      // Afficher les conditions d'utilisation
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip, color: AppColors.accentCyan),
                    title: const Text('Politique de confidentialité'),
                    onTap: () {
                      // Afficher la politique de confidentialité
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
