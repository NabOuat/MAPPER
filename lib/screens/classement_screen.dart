import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/ligue.dart';
// Removed unused import

class ClassementScreen extends StatefulWidget {
  const ClassementScreen({super.key});

  @override
  State<ClassementScreen> createState() => _ClassementScreenState();
}

class _ClassementScreenState extends State<ClassementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  // Données fictives pour démonstration
  final List<Ligue> _ligues = [];
  final Map<int, List<Map<String, dynamic>>> _classements = {};
  
  @override
  void initState() {
    super.initState();
    _chargerLigues();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _chargerLigues() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulation de chargement des données
    await Future.delayed(const Duration(seconds: 1));
    
    // Données fictives pour démonstration
    final liguesFictives = [
      Ligue(id: 1, nomLigue: 'Bronze', niveau: 1, image: 'bronze.png'),
      Ligue(id: 2, nomLigue: 'Argent', niveau: 2, image: 'silver.png'),
      Ligue(id: 3, nomLigue: 'Or', niveau: 3, image: 'gold.png'),
      Ligue(id: 4, nomLigue: 'Platine', niveau: 4, image: 'platinum.png'),
      Ligue(id: 5, nomLigue: 'Diamant', niveau: 5, image: 'diamond.png'),
    ];
    
    setState(() {
      _ligues.addAll(liguesFictives);
      _tabController = TabController(length: _ligues.length, vsync: this);
      _tabController.addListener(_handleTabChange);
      
      // Charger le classement de la première ligue
      _chargerClassement(_ligues[0].id!);
    });
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    
    final ligueId = _ligues[_tabController.index].id!;
    if (!_classements.containsKey(ligueId)) {
      _chargerClassement(ligueId);
    }
  }
  
  Future<void> _chargerClassement(int ligueId) async {
    if (_classements.containsKey(ligueId)) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulation de chargement des données
    await Future.delayed(const Duration(seconds: 1));
    
    // Données fictives pour démonstration
    final classementFictif = List.generate(
      20,
      (index) => {
        'position': index + 1,
        'utilisateur': {
          'id': 100 + index,
          'nom': 'Joueur ${index + 1}',
          'avatar': 'avatar.png',
        },
        'score': 1000 - (index * 25),
        'niveau': 10 - (index ~/ 4),
        'victoires': 50 - (index * 2),
        'defaites': 10 + index,
      },
    );
    
    setState(() {
      _classements[ligueId] = classementFictif;
      _isLoading = false;
    });
  }
  
  void _voirProfilJoueur(Map<String, dynamic> joueur) {
    // Navigation vers le profil du joueur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voir le profil de ${joueur['nom']}'),
        backgroundColor: AppColors.accentCyan,
      ),
    );
  }
  
  void _defierJoueur(Map<String, dynamic> joueur) {
    // Navigation vers l'écran de création de duel
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Défier ${joueur['nom']}'),
        backgroundColor: AppColors.accentCyan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _ligues.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _ligues.map((ligue) => Tab(text: ligue.nomLigue)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _ligues.map((ligue) {
          final ligueId = ligue.id!;
          final hasClassement = _classements.containsKey(ligueId);
          
          if (!hasClassement || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final classement = _classements[ligueId]!;
          
          return Column(
            children: [
              _buildLigueHeader(ligue),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  itemCount: classement.length,
                  itemBuilder: (context, index) {
                    final joueur = classement[index];
                    return _buildClassementItem(joueur);
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildLigueHeader(Ligue ligue) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      color: Theme.of(context).primaryColor.withAlpha(26),
      child: Row(
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
                ligue.niveau.toString(),
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
                  ligue.nomLigue,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (ligue.description != null)
                  Text(
                    ligue.description!,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildClassementItem(Map<String, dynamic> joueur) {
    final position = joueur['position'] as int;
    final utilisateur = joueur['utilisateur'] as Map<String, dynamic>;
    final score = joueur['score'] as int;
    final niveau = joueur['niveau'] as int;
    final victoires = joueur['victoires'] as int;
    final defaites = joueur['defaites'] as int;
    
    Color positionColor;
    if (position == 1) {
      positionColor = Colors.amber;
    } else if (position == 2) {
      positionColor = Colors.grey.shade400;
    } else if (position == 3) {
      positionColor = Colors.brown.shade300;
    } else {
      positionColor = Colors.grey;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: InkWell(
        onTap: () => _voirProfilJoueur(utilisateur),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: positionColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    position.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              CircleAvatar(
                child: Text(utilisateur['nom'].substring(0, 1)),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      utilisateur['nom'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Niveau $niveau',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$score pts',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.accentCyan,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$victoires V / $defaites D',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppDimensions.paddingM),
              IconButton(
                icon: const Icon(Icons.sports_kabaddi),
                onPressed: () => _defierJoueur(utilisateur),
                tooltip: 'Défier',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
