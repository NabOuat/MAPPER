import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/user.dart';

class RechercheAmisScreen extends StatefulWidget {
  const RechercheAmisScreen({Key? key}) : super(key: key);

  @override
  State<RechercheAmisScreen> createState() => _RechercheAmisScreenState();
}

class _RechercheAmisScreenState extends State<RechercheAmisScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<User> _resultats = [];
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _rechercherUtilisateurs(String query) async {
    if (query.isEmpty) {
      setState(() {
        _resultats = [];
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulation de recherche
    await Future.delayed(const Duration(seconds: 1));
    
    // Résultats fictifs
    setState(() {
      _resultats = [
        User(id: "10", name: 'Utilisateur 1', email: 'user1@example.com', lastActive: DateTime.now(), score: 120),
        User(id: "11", name: 'Utilisateur 2', email: 'user2@example.com', lastActive: DateTime.now(), score: 150),
        User(id: "12", name: 'Utilisateur 3', email: 'user3@example.com', lastActive: DateTime.now(), score: 180),
      ];
      _isLoading = false;
    });
  }
  
  Future<void> _envoyerDemandeAmi(User utilisateur) async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulation d'envoi de demande
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demande d\'ami envoyée à ${utilisateur.name}'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher des amis'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _rechercherUtilisateurs('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
              ),
              onChanged: _rechercherUtilisateurs,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _resultats.isEmpty
                    ? const Center(
                        child: Text('Aucun résultat trouvé'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        itemCount: _resultats.length,
                        itemBuilder: (context, index) {
                          final utilisateur = _resultats[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(utilisateur.name.substring(0, 1)),
                              ),
                              title: Text(utilisateur.name),
                              subtitle: Text(utilisateur.email),
                              trailing: ElevatedButton(
                                onPressed: () => _envoyerDemandeAmi(utilisateur),
                                child: const Text('Ajouter'),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
