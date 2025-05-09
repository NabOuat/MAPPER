import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/user.dart';

class CreationGroupeScreen extends StatefulWidget {
  final List<User> amis;
  
  const CreationGroupeScreen({
    Key? key,
    required this.amis,
  }) : super(key: key);

  @override
  State<CreationGroupeScreen> createState() => _CreationGroupeScreenState();
}

class _CreationGroupeScreenState extends State<CreationGroupeScreen> {
  final TextEditingController _nomGroupeController = TextEditingController();
  final List<User> _membresSelectionnes = [];
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nomGroupeController.dispose();
    super.dispose();
  }
  
  void _toggleMembre(User ami) {
    setState(() {
      if (_membresSelectionnes.any((m) => m.id == ami.id)) {
        _membresSelectionnes.removeWhere((m) => m.id == ami.id);
      } else {
        _membresSelectionnes.add(ami);
      }
    });
  }
  
  Future<void> _creerGroupe() async {
    if (_nomGroupeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un nom pour le groupe'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    
    if (_membresSelectionnes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un membre'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulation de création de groupe
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Groupe "${_nomGroupeController.text}" créé avec succès'),
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
        title: const Text('Créer un groupe'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nomGroupeController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du groupe',
                      hintText: 'Entrez un nom pour votre groupe',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  const Text(
                    'Sélectionner les membres',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.amis.length,
                    itemBuilder: (context, index) {
                      final ami = widget.amis[index];
                      final isSelected = _membresSelectionnes.any((m) => m.id == ami.id);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
                        child: CheckboxListTile(
                          title: Text(ami.name),
                          subtitle: Text(ami.email),
                          value: isSelected,
                          onChanged: (_) => _toggleMembre(ami),
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
                      onPressed: _creerGroupe,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                        child: Text('Créer le groupe'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
