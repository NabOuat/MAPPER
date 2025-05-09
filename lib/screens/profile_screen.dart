import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../providers/places_provider.dart';
import '../providers/users_provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  void _showEditProfileDialog(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    
    if (currentUser == null) return;
    
    _nameController.text = currentUser.name;
    _emailController.text = currentUser.email;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Éditer le profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Mise à jour du profil dans la base de données locale
                final authService = Provider.of<AuthService>(context, listen: false);
                final updatedUser = authService.currentUser!.copyWith(
                  name: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                );
                
                await authService.updateUserProfile(updatedUser);
                
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil mis à jour avec succès'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
  
  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Foire Aux Questions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Comment ajouter un lieu ?', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: AppDimensions.paddingS),
              Text('Appuyez sur le bouton + en bas à droite de l\'écran carte pour ajouter un nouveau lieu.'),
              SizedBox(height: AppDimensions.paddingM),
              
              Text('Comment filtrer les lieux par catégorie ?', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: AppDimensions.paddingS),
              Text('Utilisez les filtres en haut de l\'écran carte pour afficher uniquement certaines catégories de lieux.'),
              SizedBox(height: AppDimensions.paddingM),
              
              Text('Comment envoyer un message ?', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: AppDimensions.paddingS),
              Text('Accédez à l\'onglet Amis, puis appuyez sur un utilisateur pour démarrer une conversation.'),
              SizedBox(height: AppDimensions.paddingM),
              
              Text('L\'application fonctionne-t-elle hors ligne ?', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: AppDimensions.paddingS),
              Text('Oui, l\'application stocke les données localement et se synchronise lorsque vous êtes en ligne.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos de Ping Mapper'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.accentCyan,
              child: Icon(Icons.map, size: 40, color: Colors.white),
            ),
            SizedBox(height: AppDimensions.paddingM),
            Text(
              'Ping Mapper v1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.paddingS),
            Text(
              'Application de cartographie collaborative pour partager et découvrir des lieux intéressants.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDimensions.paddingM),
            Text('Développé avec ❤️ par l\'équipe Ping Mapper'),
            SizedBox(height: AppDimensions.paddingS),
            Text('© 2025 Ping Mapper. Tous droits réservés.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
  
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Déconnexion et redirection vers l'écran de connexion
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusL)),
                ),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(AppDimensions.paddingL),
                      child: Text(
                        'Paramètres',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.edit, color: AppColors.accentCyan),
                      title: const Text('Éditer le profil'),
                      onTap: () {
                        Navigator.pop(context);
                        _showEditProfileDialog(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share, color: AppColors.accentCyan),
                      title: const Text('Partager mon profil'),
                      onTap: () {
                        Navigator.pop(context);
                        // Logique de partage de profil
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lien de profil copié dans le presse-papier')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.help_outline, color: AppColors.accentCyan),
                      title: const Text('FAQ'),
                      onTap: () {
                        Navigator.pop(context);
                        _showFAQDialog(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: AppColors.accentCyan),
                      title: const Text('À propos'),
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.errorRed),
                      title: const Text('Déconnexion'),
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutConfirmation(context);
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<UsersProvider, PlacesProvider>(
        builder: (context, usersProvider, placesProvider, child) {
          if (usersProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final currentUser = usersProvider.currentUser;
          if (currentUser == null) {
            return const Center(
              child: Text('Utilisateur non disponible'),
            );
          }

          final userPlaces = placesProvider.getPlacesByUser(currentUser.id);
          final rank = usersProvider.getCurrentUserRank();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête du profil
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.accentCyan,
                        child: Text(
                          currentUser.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        currentUser.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        currentUser.email,
                        style: const TextStyle(
                          color: AppColors.secondaryGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingXL),

                // Statistiques
                Row(
                  children: [
                    _StatCard(
                      icon: Icons.place,
                      value: currentUser.score.toString(),
                      label: 'Lieux ajoutés',
                      color: AppColors.accentCyan,
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    _StatCard(
                      icon: Icons.leaderboard,
                      value: rank > 0 ? '#$rank' : '-',
                      label: 'Classement',
                      color: const Color(0xFFFFD700),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Derniers lieux ajoutés
                const Text(
                  'Vos derniers lieux ajoutés',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                
                if (userPlaces.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 48,
                            color: AppColors.secondaryGrey,
                          ),
                          SizedBox(height: AppDimensions.paddingM),
                          Text(
                            'Vous n\'avez pas encore ajouté de lieu',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.secondaryGrey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userPlaces.length > 5 ? 5 : userPlaces.length,
                    itemBuilder: (context, index) {
                      final place = userPlaces[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.accentCyan,
                            child: Icon(
                              Icons.place,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(place.name),
                          subtitle: Text(
                            _formatDate(place.createdAt),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            '${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryGrey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: AppDimensions.paddingL),

                // Boutons d'action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_location),
                    label: const Text('Ajouter un nouveau lieu'),
                    onPressed: () => context.push('/add-place'),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.sync),
                    label: const Text('Synchroniser les données'),
                    onPressed: () {
                      // Simuler une synchronisation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Synchronisation réussie'),
                          backgroundColor: AppColors.successGreen,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXS),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.secondaryGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
