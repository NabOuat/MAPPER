import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/user.dart';
// Removed unused import
import 'recherche_amis_screen.dart';
import 'creation_groupe_screen.dart';
import 'details_groupe_screen.dart';

class AmisScreen extends StatefulWidget {
  const AmisScreen({super.key});

  @override
  State<AmisScreen> createState() => _AmisScreenState();
}

class _AmisScreenState extends State<AmisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  // Données fictives pour démonstration
  final List<User> _amis = [];
  final List<User> _demandesEnAttente = [];
  final List<Map<String, dynamic>> _groupes = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _chargerDonnees();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _chargerDonnees() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulation de chargement des données
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      // Amis fictifs
      _amis.addAll([
        User(id: "2", name: 'Ami 1', email: 'ami1@example.com', lastActive: DateTime.now(), score: 100),
        User(id: "3", name: 'Ami 2', email: 'ami2@example.com', lastActive: DateTime.now(), score: 150),
        User(id: "4", name: 'Ami 3', email: 'ami3@example.com', lastActive: DateTime.now(), score: 120),
        User(id: "5", name: 'Ami 4', email: 'ami4@example.com', lastActive: DateTime.now(), score: 200),
      ]);
      
      // Demandes en attente
      _demandesEnAttente.addAll([
        User(id: "6", name: 'Demande 1', email: 'demande1@example.com', lastActive: DateTime.now(), score: 80),
        User(id: "7", name: 'Demande 2', email: 'demande2@example.com', lastActive: DateTime.now(), score: 90),
      ]);
      
      // Groupes d'amis
      _groupes.addAll([
        {
          'id': 1,
          'nom': 'Amis proches',
          'membres': [
            {'id': 2, 'nom': 'Ami 1'},
            {'id': 3, 'nom': 'Ami 2'},
          ],
        },
        {
          'id': 2,
          'nom': 'Collègues',
          'membres': [
            {'id': 4, 'nom': 'Ami 3'},
            {'id': 5, 'nom': 'Ami 4'},
          ],
        },
      ]);
      
      _isLoading = false;
    });
  }
  
  void _ouvrirRechercheAmis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RechercheAmisScreen(),
      ),
    );
  }
  
  void _ouvrirCreationGroupe() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreationGroupeScreen(amis: _amis),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amis'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mes amis'),
            Tab(text: 'Demandes'),
            Tab(text: 'Groupes'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _ouvrirRechercheAmis,
            tooltip: 'Rechercher des amis',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAmisList(),
                _buildDemandesList(),
                _buildGroupesList(),
              ],
            ),
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton(
              onPressed: _ouvrirCreationGroupe,
              tooltip: 'Créer un groupe',
              child: const Icon(Icons.group_add),
            )
          : null,
    );
  }
  
  Widget _buildAmisList() {
    if (_amis.isEmpty) {
      return const Center(
        child: Text('Vous n\'avez pas encore d\'amis'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: _amis.length,
      itemBuilder: (context, index) {
        final ami = _amis[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(ami.name.substring(0, 1)),
            ),
            title: Text(ami.name),
            subtitle: Text(ami.email),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleAmiAction(value, ami),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'message',
                  child: Text('Envoyer un message'),
                ),
                const PopupMenuItem(
                  value: 'duel',
                  child: Text('Défier en duel'),
                ),
                const PopupMenuItem(
                  value: 'supprimer',
                  child: Text('Supprimer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDemandesList() {
    if (_demandesEnAttente.isEmpty) {
      return const Center(
        child: Text('Aucune demande en attente'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: _demandesEnAttente.length,
      itemBuilder: (context, index) {
        final demande = _demandesEnAttente[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(demande.name.substring(0, 1)),
            ),
            title: Text(demande.name),
            subtitle: Text(demande.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _accepterDemande(demande),
                  tooltip: 'Accepter',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _refuserDemande(demande),
                  tooltip: 'Refuser',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildGroupesList() {
    if (_groupes.isEmpty) {
      return const Center(
        child: Text('Vous n\'avez pas encore de groupes'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: _groupes.length,
      itemBuilder: (context, index) {
        final groupe = _groupes[index];
        final membres = groupe['membres'] as List<dynamic>;
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          child: InkWell(
            onTap: () => _ouvrirDetailsGroupe(groupe),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        groupe['nom'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${membres.length} membres',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Wrap(
                    spacing: AppDimensions.paddingS,
                    children: membres.map<Widget>((membre) {
                      return Chip(
                        avatar: CircleAvatar(
                          child: Text(membre['nom'].substring(0, 1)),
                        ),
                        label: Text(membre['nom']),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _handleAmiAction(String action, User ami) {
    switch (action) {
      case 'message':
        // Ouvrir la conversation avec cet ami
        break;
      case 'duel':
        // Créer un duel avec cet ami
        break;
      case 'supprimer':
        _supprimerAmi(ami);
        break;
    }
  }
  
  void _supprimerAmi(User ami) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer un ami'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${ami.name} de vos amis ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _amis.removeWhere((a) => a.id == ami.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${ami.name} a été supprimé de vos amis'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
  
  void _accepterDemande(User demande) {
    setState(() {
      _demandesEnAttente.removeWhere((d) => d.id == demande.id);
      _amis.add(demande);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vous êtes maintenant ami avec ${demande.name}'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }
  
  void _refuserDemande(User demande) {
    setState(() {
      _demandesEnAttente.removeWhere((d) => d.id == demande.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demande d\'ami de ${demande.name} refusée'),
        backgroundColor: AppColors.accentCyan,
      ),
    );
  }
  
  void _ouvrirDetailsGroupe(Map<String, dynamic> groupe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsGroupeScreen(
          groupe: groupe,
          amis: _amis,
        ),
      ),
    );
  }
}
