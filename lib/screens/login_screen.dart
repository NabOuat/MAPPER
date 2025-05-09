import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isNewUser = false; // Pour basculer entre connexion et inscription
  bool _obscurePassword = true; // Pour masquer/afficher le mot de passe
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _contactController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Connexion avec le service d'authentification
      final success = await authService.login(
        _contactController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (success && mounted) {
        // Redirection vers l'écran d'accueil
        context.go('/');
        
        // Synchroniser les données
        authService.syncData();
      } else if (mounted) {
        // Afficher le message d'erreur du service d'authentification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.error ?? 'Identifiants incorrects'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Basculer entre connexion et inscription
  void _toggleMode() {
    setState(() {
      _isNewUser = !_isNewUser;
    });
  }
  
  // Basculer l'affichage du mot de passe
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.darkBackground,
                AppColors.cardDarkBackground,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo et titre
                    const Icon(
                      Icons.location_on,
                      size: 80,
                      color: AppColors.accentCyan,
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    const Text(
                      'Mapper Lite',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      _isNewUser ? 'Créer un compte' : 'Connexion à votre compte',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),
                            
                    // Champs de formulaire
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre contact';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                            
                    // Bouton de connexion
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentCyan,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isNewUser ? 'S\'inscrire' : 'Se connecter',
                            style: const TextStyle(fontSize: 16),
                          ),
                    ),
                    
                    const SizedBox(height: AppDimensions.paddingM),
                    
                    // Lien pour basculer entre connexion et inscription
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(
                        _isNewUser 
                            ? 'Déjà un compte? Se connecter' 
                            : 'Pas encore de compte? S\'inscrire',
                        style: const TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    
                    // Note sur la base de données locale
                    const Padding(
                      padding: EdgeInsets.only(top: AppDimensions.paddingL),
                      child: Text(
                        'Les données seront stockées localement sur votre appareil et synchronisées lorsque vous serez en ligne.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    
                    // Lien pour continuer sans connexion
                    TextButton(
                      onPressed: () {
                        // Redirection vers l'écran d'accueil sans connexion
                        context.go('/');
                      },
                      child: const Text(
                        'Continuer sans connexion',
                        style: TextStyle(
                          color: AppColors.secondaryGrey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
