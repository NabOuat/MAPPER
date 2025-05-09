import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/duel.dart';
import '../models/user.dart';

class DuelsScreen extends StatefulWidget {
  const DuelsScreen({Key? key}) : super(key: key);

  @override
  State<DuelsScreen> createState() => _DuelsScreenState();
}

class _DuelsScreenState extends State<DuelsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  // Données fictives pour démonstration
  final List<Duel> _duelsActifs = [];
  final List<Duel> _duelsTermines = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chargerDuels();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _chargerDuels() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulation de chargement des données
    await Future.delayed(const Duration(seconds: 1));
    
    // Données fictives pour démonstration
    final maintenant = DateTime.now();
    
    setState(() {
      _duelsActifs.addAll([
        Duel(
          id: 1,
          idUtilisateur1: 1,
          idUtilisateur2: 2,
          type: 'solo',
          statut: 'en_cours',
          dateCreation: maintenant.subtract(const Duration(days: 2)),
          scoreUtilisateur1: 120,
          scoreUtilisateur2: 80,
          participantsEquipe1: [{'id': 1, 'nom': 'Joueur 1'}],
          participantsEquipe2: [{'id': 2, 'nom': 'Joueur 2'}],
        ),
        Duel(
          id: 2,
          idUtilisateur1: 1,
          idUtilisateur2: 3,
          type: 'equipe',
          statut: 'en_attente',
          dateCreation: maintenant.subtract(const Duration(days: 1)),
          participantsEquipe1: [
            {'id': 1, 'nom': 'Joueur 1'},
            {'id': 4, 'nom': 'Joueur 4'},
          ],
          participantsEquipe2: [
            {'id': 3, 'nom': 'Joueur 3'},
            {'id': 5, 'nom': 'Joueur 5'},
          ],
        ),
      ]);
      
      _duelsTermines.addAll([
        Duel(
          id: 3,
          idUtilisateur1: 1,
          idUtilisateur2: 4,
          type: 'solo',
          statut: 'termine',
          dateCreation: maintenant.subtract(const Duration(days: 10)),
          dateFin: maintenant.subtract(const Duration(days: 8)),
          scoreUtilisateur1: 150,
          scoreUtilisateur2: 120,
          participantsEquipe1: [{'id': 1, 'nom': 'Joueur 1'}],
          participantsEquipe2: [{'id': 4, 'nom': 'Joueur 4'}],
        ),
        Duel(
          id: 4,
          idUtilisateur1: 1,
          idUtilisateur2: 5,
          type: 'equipe',
          statut: 'termine',
          dateCreation: maintenant.subtract(const Duration(days: 15)),
          dateFin: maintenant.subtract(const Duration(days: 12)),
          scoreUtilisateur1: 200,
          scoreUtilisateur2: 250,
          participantsEquipe1: [
            {'id': 1, 'nom': 'Joueur 1'},
            {'id': 2, 'nom': 'Joueur 2'},
          ],
          participantsEquipe2: [
            {'id': 5, 'nom': 'Joueur 5'},
            {'id': 6, 'nom': 'Joueur 6'},
          ],
        ),
      ]);
      
      _isLoading = false;
    });
  }
  
  void _ouvrirCreationDuel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreationDuelScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duels'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Actifs'),
            Tab(text: 'Terminés'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _ouvrirCreationDuel,
            tooltip: 'Créer un duel',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDuelsList(_duelsActifs),
                _buildDuelsList(_duelsTermines),
              ],
            ),
    );
  }
  
  Widget _buildDuelsList(List<Duel> duels) {
    if (duels.isEmpty) {
      return const Center(
        child: Text('Aucun duel à afficher'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: duels.length,
      itemBuilder: (context, index) {
        final duel = duels[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          child: InkWell(
            onTap: () => _ouvrirDetailsDuel(duel),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duel ${duel.type == 'solo' ? 'Solo' : 'Équipe'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _buildStatusChip(duel.statut),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  const Divider(),
                  const SizedBox(height: AppDimensions.paddingS),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Équipe 1'),
                            const SizedBox(height: AppDimensions.paddingS),
                            ...duel.participantsEquipe1.map((p) => Text(p['nom'])),
                            const SizedBox(height: AppDimensions.paddingS),
                            Text(
                              '${duel.scoreUtilisateur1} pts',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentCyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'VS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Équipe 2'),
                            const SizedBox(height: AppDimensions.paddingS),
                            ...duel.participantsEquipe2.map((p) => Text(p['nom'])),
                            const SizedBox(height: AppDimensions.paddingS),
                            Text(
                              '${duel.scoreUtilisateur2} pts',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentCyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  const Divider(),
                  const SizedBox(height: AppDimensions.paddingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Créé le ${_formatDate(duel.dateCreation)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      if (duel.dateFin != null)
                        Text(
                          'Terminé le ${_formatDate(duel.dateFin!)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'en_attente':
        color = Colors.orange;
        label = 'En attente';
        break;
      case 'en_cours':
        color = Colors.green;
        label = 'En cours';
        break;
      case 'termine':
        color = Colors.blue;
        label = 'Terminé';
        break;
      default:
        color = Colors.grey;
        label = 'Inconnu';
    }
    
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  
  void _ouvrirDetailsDuel(Duel duel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsDuelScreen(duel: duel),
      ),
    );
  }
}

class CreationDuelScreen extends StatefulWidget {
  const CreationDuelScreen({Key? key}) : super(key: key);

  @override
  State<CreationDuelScreen> createState() => _CreationDuelScreenState();
}

class _CreationDuelScreenState extends State<CreationDuelScreen> {
  String _typeDuel = 'solo';
  final List<User> _amis = []; // Liste des amis à charger
  final List<User> _participants = []; // Participants sélectionnés
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _chargerAmis();
  }
  
  Future<void> _chargerAmis() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulation de chargement des données
    await Future.delayed(const Duration(seconds: 1));
    
    // Données fictives pour démonstration
    setState(() {
      _amis.addAll([
        User(id: "2", name: 'Ami 1', email: 'ami1@example.com'),
        User(id: "3", name: 'Ami 2', email: 'ami2@example.com'),
        User(id: "4", name: 'Ami 3', email: 'ami3@example.com'),
        User(id: "5", name: 'Ami 4', email: 'ami4@example.com'),
      ]);
      _isLoading = false;
    });
  }
  
  void _toggleParticipant(User ami) {
    setState(() {
      if (_participants.any((p) => p.id == ami.id)) {
        _participants.removeWhere((p) => p.id == ami.id);
      } else {
        if (_typeDuel == 'solo' && _participants.isEmpty) {
          _participants.add(ami);
        } else if (_typeDuel == 'equipe') {
          _participants.add(ami);
        }
      }
    });
  }
  
  Future<void> _creerDuel() async {
    if (_participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un participant'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulation de création de duel
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Duel créé avec succès'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un duel'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Type de duel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Solo'),
                          value: 'solo',
                          groupValue: _typeDuel,
                          onChanged: (value) {
                            setState(() {
                              _typeDuel = value!;
                              if (_participants.length > 1) {
                                _participants.clear();
                              }
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Équipe'),
                          value: 'equipe',
                          groupValue: _typeDuel,
                          onChanged: (value) {
                            setState(() {
                              _typeDuel = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  const Text(
                    'Sélectionner les participants',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  if (_typeDuel == 'solo')
                    const Text(
                      'Sélectionnez un ami pour le duel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  if (_typeDuel == 'equipe')
                    const Text(
                      'Sélectionnez plusieurs amis pour former les équipes',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: AppDimensions.paddingM),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _amis.length,
                    itemBuilder: (context, index) {
                      final ami = _amis[index];
                      final isSelected = _participants.any((p) => p.id == ami.id);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
                        child: CheckboxListTile(
                          title: Text(ami.name),
                          subtitle: Text(ami.email),
                          value: isSelected,
                          onChanged: (_) => _toggleParticipant(ami),
                          secondary: CircleAvatar(
                            child: Text(ami.name.substring(0, 1)),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _creerDuel,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                        child: Text('Créer le duel'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class DetailsDuelScreen extends StatelessWidget {
  final Duel duel;
  
  const DetailsDuelScreen({Key? key, required this.duel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Duel #${duel.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Duel ${duel.type == 'solo' ? 'Solo' : 'Équipe'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        _buildStatusChip(duel.statut),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    const Divider(),
                    const SizedBox(height: AppDimensions.paddingM),
                    const Text(
                      'Scores',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    Row(
                      children: [
                        Expanded(
                          child: _buildScoreCard(
                            'Équipe 1',
                            duel.scoreUtilisateur1,
                            duel.participantsEquipe1,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        const Text(
                          'VS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingM),
                        Expanded(
                          child: _buildScoreCard(
                            'Équipe 2',
                            duel.scoreUtilisateur2,
                            duel.participantsEquipe2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    const Divider(),
                    const SizedBox(height: AppDimensions.paddingM),
                    const Text(
                      'Informations',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    _buildInfoRow('Créé le', _formatDate(duel.dateCreation)),
                    if (duel.dateFin != null)
                      _buildInfoRow('Terminé le', _formatDate(duel.dateFin!)),
                    if (duel.lienDuel != null)
                      _buildInfoRow('Lien du duel', duel.lienDuel!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            if (duel.statut == 'en_cours')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                    child: Text('Jouer maintenant'),
                  ),
                ),
              ),
            if (duel.statut == 'en_attente')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                    child: Text('Accepter le duel'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScoreCard(String title, int score, List<Map<String, dynamic>> participants) {
    return Card(
      color: AppColors.accentCyan.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              '$score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.accentCyan,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            const Divider(),
            const SizedBox(height: AppDimensions.paddingS),
            const Text('Participants'),
            const SizedBox(height: AppDimensions.paddingS),
            ...participants.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
              child: Text(p['nom']),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'en_attente':
        color = Colors.orange;
        label = 'En attente';
        break;
      case 'en_cours':
        color = Colors.green;
        label = 'En cours';
        break;
      case 'termine':
        color = Colors.blue;
        label = 'Terminé';
        break;
      default:
        color = Colors.grey;
        label = 'Inconnu';
    }
    
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
