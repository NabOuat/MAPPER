import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../widgets/country_code_selector.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _useEmail = true;
  String _selectedCountryCode = '+33';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAuthMethod() {
    setState(() {
      _useEmail = !_useEmail;
    });
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulation d'une requête d'inscription
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      // Redirection vers la vérification OTP
      Navigator.pushNamed(
        context, 
        '/otp-verification',
        arguments: {
          'destination': _useEmail ? _emailController.text : '$_selectedCountryCode${_phoneController.text}',
          'isEmail': _useEmail,
        },
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'inscription: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo ou image
                const SizedBox(height: AppDimensions.paddingL),
                Icon(
                  Icons.location_on,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: AppDimensions.paddingL),
                
                // Titre
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                
                // Champ Nom
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingM),
                
                // Sélecteur Email/Téléphone
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _useEmail ? null : _toggleAuthMethod,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _useEmail ? Theme.of(context).primaryColor : Colors.grey.shade300,
                          foregroundColor: _useEmail ? Colors.white : Colors.black87,
                        ),
                        child: const Text('Email'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _useEmail ? _toggleAuthMethod : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _useEmail ? Colors.grey.shade300 : Theme.of(context).primaryColor,
                          foregroundColor: _useEmail ? Colors.black87 : Colors.white,
                        ),
                        child: const Text('Téléphone'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingM),
                
                // Champ Email ou Téléphone
                if (_useEmail)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(4),
                          ),
                        ),
                        child: CountryCodeSelector(
                          onChanged: (CountryCode countryCode) {
                            setState(() {
                              _selectedCountryCode = countryCode.dialCode;
                            });
                          },
                          initialSelection: 'FR',
                          favorites: const ['FR', 'US', 'CA'],
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Numéro de téléphone',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(4),
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre numéro';
                            }
                            if (!RegExp(r'^[0-9]{9,10}$').hasMatch(value)) {
                              return 'Numéro invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: AppDimensions.paddingM),
                
                // Champ Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingM),
                
                // Champ Confirmation mot de passe
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                
                // Bouton d'inscription
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'S\'inscrire',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                
                // Lien vers la connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Vous avez déjà un compte?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
