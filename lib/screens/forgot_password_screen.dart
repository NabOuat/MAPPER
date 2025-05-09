import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../widgets/country_code_selector.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _useEmail = true;
  String _selectedCountryCode = '+33';

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleAuthMethod() {
    setState(() {
      _useEmail = !_useEmail;
    });
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulation d'une requête de réinitialisation
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      // Redirection vers la vérification OTP
      Navigator.pushNamed(
        context, 
        '/otp-verification',
        arguments: {
          'destination': _useEmail ? _emailController.text : '$_selectedCountryCode${_phoneController.text}',
          'isEmail': _useEmail,
          'isPasswordReset': true,
        },
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la réinitialisation: $e')),
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
        title: const Text('Mot de passe oublié'),
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
                  Icons.lock_reset,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: AppDimensions.paddingL),
                
                // Titre
                const Text(
                  'Réinitialiser votre mot de passe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingM),
                
                // Instructions
                const Text(
                  'Veuillez entrer votre email ou numéro de téléphone pour recevoir un code de vérification',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                
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
                const SizedBox(height: AppDimensions.paddingL),
                
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
                const SizedBox(height: AppDimensions.paddingXL),
                
                // Bouton de réinitialisation
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Envoyer le code',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                
                // Lien vers la connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Vous vous souvenez de votre mot de passe?'),
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
