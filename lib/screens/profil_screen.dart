import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/badge.dart' as app_badge;
import '../models/ligue.dart';
import '../models/user.dart';
import '../providers/users_provider.dart';
import '../screens/statistics_screen.dart';

class ProfilScreen extends StatefulWidget {
  final String? userId; // Si null, affiche le profil de l'utilisateur courant
  
  const ProfilScreen({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  User? _utilisateur;
  Ligue? _ligue;
  List<app_badge.Badge> _trophees = [];
  Map<String, dynamic> _statistiques = {};
  List<Map<String, dynamic>> _historiqueDuels = [];
  
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
    
    // Récupérer l'utilisateur
    if (widget.userId != null) {
      // Charger les données de l'utilisateur spécifié
      await _chargerUtilisateurSpecifique(widget.userId!);
    } else {
      // Charger les données de l'utilisateur courant
      final userProvider = Provider.of<UsersProvider>(context, listen: false);
      _utilisateur = userProvider.currentUser;
    }
    
    // Simulation de chargement des données
    await Future.delayed(const Duration(seconds: 1));
    
    // Données fictives pour démonstration
    setState(() {
      // Ligue fictive
      _ligue = Ligue(
        id: 3,
        nomLigue: 'Or',
        niveau: 3,
        image: 'gold.png',
        description: 'Ligue des joueurs expérimentés',
      );
      
      // Trophées fictifs
      _trophees = [
        app_badge.Badge(id: 1, nomBadge: 'Explorateur', description: 'Visiter 10 lieux différents'),
        app_badge.Badge(id: 2, nomBadge: 'Cartographe', description: 'Ajouter 5 nouveaux lieux'),
        app_badge.Badge(id: 3, nomBadge: 'Champion', description: 'Gagner 3 duels consécutifs'),
        app_badge.Badge(id: 4, nomBadge: 'Social', description: 'Ajouter 5 amis'),
      ];
      
      // Statistiques fictives
      _statistiques = {
        'niveau': 15,
        'experience': 2500,
        'experienceNiveauSuivant': 3000,
        'score': 750,
        'duelsGagnes': 12,
        'duelsPerdus': 5,
        'lieuxVisites': 42,
        'lieuxAjoutes': 8,
        'distanceParcourue': 125.7,
        'tempsJeu': 48.5,
      };
      
      // Historique des duels fictif
      _historiqueDuels = [
        {
          'id': 1,
          'adversaire': 'Joueur 1',
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'resultat': 'victoire',
          'score': '120-80',
        },
        {
          'id': 2,
          'adversaire': 'Joueur 2',
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'resultat': 'defaite',
          'score': '90-110',
        },
        {
          'id': 3,
          'adversaire': 'Joueur 3',
          'date': DateTime.now().subtract(const Duration(days: 10)),
          'resultat': 'victoire',
          'score': '150-120',
        },
      ];
      
      _isLoading = false;
    });
  }
  
  Future<void> _chargerUtilisateurSpecifique(String userId) async {
    // Simulation de chargement des données d'un utilisateur spécifique
    await Future.delayed(const Duration(seconds: 1));
    
    _utilisateur = User(
      id: userId,
      name: 'Utilisateur $userId',
      email: 'user$userId@example.com',
    );
  }
  
  void _voirStatistiquesDetaillees() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StatisticsScreen(),
      ),
    );
  }
  
  void _defierUtilisateur() {
    if (_utilisateur == null || widget.userId == null) return;
    
    // Navigation vers l'écran de création de duel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Défier ${_utilisateur!.name}'),
        backgroundColor: AppColors.accentCyan,
      ),
    );
  }
  
  void _envoyerMessage() {
    if (_utilisateur == null || widget.userId == null) return;
    
    // Navigation vers l'écran de conversation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Envoyer un message à ${_utilisateur!.name}'),
        backgroundColor: AppColors.accentCyan,
      ),
    );
  }
  
  void _ajouterAmi() {
    if (_utilisateur == null || widget.userId == null) return;
    
    // Envoyer une demande d'ami
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demande d\'ami envoyée à ${_utilisateur!.name}'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId != null ? 'Profil' : 'Mon profil'),
        actions: [
          if (widget.userId != null)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _ajouterAmi,
              tooltip: 'Ajouter en ami',
            ),
          if (widget.userId != null)
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: _envoyerMessage,
              tooltip: 'Envoyer un message',
            ),
          if (widget.userId != null)
            IconButton(
              icon: const Icon(Icons.sports_kabaddi),
              onPressed: _defierUtilisateur,
              tooltip: 'Défier',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profil'),
            Tab(text: 'Trophées'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: _isLoading || _utilisateur == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfilTab(),
                _buildTropheesTab(),
                _buildHistoriqueTab(),
              ],
            ),
    );
  }
  
  Widget _buildProfilTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfilHeader(),
          const SizedBox(height: AppDimensions.paddingL),
          _buildStatistiquesSection(),
          const SizedBox(height: AppDimensions.paddingL),
          _buildLigueSection(),
        ],
      ),
    );
  }
  
  Widget _buildProfilHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                _utilisateur!.name.substring(0, 1),
                style: const TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _utilisateur!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Text(
                    _utilisateur!.email,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Niveau ${_statistiques['niveau']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${_statistiques['score']} pts',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatistiquesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statistiques',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                TextButton(
                  onPressed: _voirStatistiquesDetaillees,
                  child: const Text('Voir plus'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            LinearProgressIndicator(
              value: _statistiques['experience'] / _statistiques['experienceNiveauSuivant'],
              backgroundColor: Colors.grey.shade300,
              color: AppColors.accentCyan,
            ),
            const SizedBox(height: 4),
            Text(
              'Expérience: ${_statistiques['experience']}/${_statistiques['experienceNiveauSuivant']}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.emoji_events,
                    label: 'Duels gagnés',
                    value: _statistiques['duelsGagnes'].toString(),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.cancel,
                    label: 'Duels perdus',
                    value: _statistiques['duelsPerdus'].toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.place,
                    label: 'Lieux visités',
                    value: _statistiques['lieuxVisites'].toString(),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.add_location,
                    label: 'Lieux ajoutés',
                    value: _statistiques['lieuxAjoutes'].toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.route,
                    label: 'Distance (km)',
                    value: _statistiques['distanceParcourue'].toString(),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.timer,
                    label: 'Temps de jeu (h)',
                    value: _statistiques['tempsJeu'].toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentCyan),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLigueSection() {
    if (_ligue == null) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ligue actuelle',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _ligue!.niveau.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _ligue!.nomLigue,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (_ligue!.description != null)
                        Text(
                          _ligue!.description!,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigation vers l'écran de classement
                },
                child: const Text('Voir le classement'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTropheesTab() {
    if (_trophees.isEmpty) {
      return const Center(
        child: Text('Aucun trophée débloqué'),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppDimensions.paddingM,
        mainAxisSpacing: AppDimensions.paddingM,
      ),
      itemCount: _trophees.length,
      itemBuilder: (context, index) {
        final trophee = _trophees[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: AppColors.accentCyan,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  trophee.nomBadge,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingS),
                if (trophee.description != null)
                  Text(
                    trophee.description!,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildHistoriqueTab() {
    if (_historiqueDuels.isEmpty) {
      return const Center(
        child: Text('Aucun duel dans l\'historique'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: _historiqueDuels.length,
      itemBuilder: (context, index) {
        final duel = _historiqueDuels[index];
        final isVictoire = duel['resultat'] == 'victoire';
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isVictoire ? Colors.green : Colors.red,
              child: Icon(
                isVictoire ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            title: Text(
              'Duel contre ${duel['adversaire']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Score: ${duel['score']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Date: ${_formatDate(duel['date'])}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: OutlinedButton(
              onPressed: () {
                // Voir les détails du duel
              },
              child: const Text('Détails'),
            ),
          ),
        );
      },
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
