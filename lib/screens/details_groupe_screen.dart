import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/user.dart';

class DetailsGroupeScreen extends StatefulWidget {
  final Map<String, dynamic> groupe;
  final List<User> amis;
  
  const DetailsGroupeScreen({
    Key? key,
    required this.groupe,
    required this.amis,
  }) : super(key: key);

  @override
  State<DetailsGroupeScreen> createState() => _DetailsGroupeScreenState();
}

class _DetailsGroupeScreenState extends State<DetailsGroupeScreen> {
  final TextEditingController _nomGroupeController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  late List<dynamic> _membres;
  
  @override
  void initState() {
    super.initState();
    _nomGroupeController.text = widget.groupe['nom'];
    _membres = List.from(widget.groupe['membres']);
  }
  
  @override
  void dispose() {
    _nomGroupeController.dispose();
    super.dispose();
  }
  
  Future<void> _sauvegarderModifications() async {
    if (_nomGroupeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom du groupe ne peut pas être vide'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulation de sauvegarde
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      _isEditing = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modifications enregistrées'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }
  
  Future<void> _supprimerGroupe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le groupe'),
        content: Text('Êtes-vous sûr de vouloir supprimer le groupe "${widget.groupe['nom']}" ?'),
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
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulation de suppression
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Groupe "${widget.groupe['nom']}" supprimé'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }
  
  Future<void> _ajouterMembre() async {
    final amisDisponibles = widget.amis.where((ami) {
      return !_membres.any((membre) => membre['id'] == ami.id);
    }).toList();
    
    if (amisDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tous vos amis sont déjà dans ce groupe'),
          backgroundColor: AppColors.accentCyan,
        ),
      );
      return;
    }
    
    final selectedAmi = await showDialog<User>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un membre'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: amisDisponibles.length,
            itemBuilder: (context, index) {
              final ami = amisDisponibles[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(ami.name.substring(0, 1)),
                ),
                title: Text(ami.name),
                subtitle: Text(ami.email),
                onTap: () => Navigator.pop(context, ami),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
    
    if (selectedAmi == null) return;
    
    setState(() {
      _membres.add({
        'id': selectedAmi.id,
        'nom': selectedAmi.name,
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedAmi.name} ajouté au groupe'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }
  
  void _supprimerMembre(Map<String, dynamic> membre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer un membre'),
        content: Text('Êtes-vous sûr de vouloir retirer ${membre['nom']} du groupe ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _membres.removeWhere((m) => m['id'] == membre['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${membre['nom']} retiré du groupe'),
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
  
  void _creerDuelGroupe() {
    // Navigation vers l'écran de création de duel avec le groupe
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de duel de groupe à venir'),
        backgroundColor: AppColors.accentCyan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le groupe' : widget.groupe['nom']),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Modifier',
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _sauvegarderModifications,
              tooltip: 'Enregistrer',
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _supprimerGroupe,
            tooltip: 'Supprimer',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditing)
                    TextField(
                      controller: _nomGroupeController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du groupe',
                        border: OutlineInputBorder(),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informations',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingM),
                            Row(
                              children: [
                                const Icon(Icons.group, color: AppColors.accentCyan),
                                const SizedBox(width: AppDimensions.paddingM),
                                Text(
                                  widget.groupe['nom'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.paddingS),
                            Row(
                              children: [
                                const Icon(Icons.people, color: AppColors.accentCyan),
                                const SizedBox(width: AppDimensions.paddingM),
                                Text(
                                  '${_membres.length} membres',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppDimensions.paddingL),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Membres',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (_isEditing)
                        ElevatedButton.icon(
                          onPressed: _ajouterMembre,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Ajouter'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _membres.length,
                    itemBuilder: (context, index) {
                      final membre = _membres[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(membre['nom'].substring(0, 1)),
                          ),
                          title: Text(membre['nom']),
                          trailing: _isEditing
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle, color: AppColors.errorRed),
                                  onPressed: () => _supprimerMembre(membre),
                                  tooltip: 'Retirer',
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  if (!_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _creerDuelGroupe,
                        icon: const Icon(Icons.sports_kabaddi),
                        label: const Text('Créer un duel de groupe'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
