import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_dimensions.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String destination;
  final bool isEmail;
  final bool isPasswordReset;

  const OtpVerificationScreen({
    super.key,
    required this.destination,
    required this.isEmail,
    this.isPasswordReset = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
  
  bool _isLoading = false;
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 60;
      _canResend = false;
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      setState(() {
        _resendSeconds--;
      });
      
      if (_resendSeconds > 0) {
        _startResendTimer();
      } else {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _getOtpCode {
    return _controllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOtp() async {
    final otpCode = _getOtpCode;
    
    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le code complet à 6 chiffres')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulation de vérification OTP
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      if (widget.isPasswordReset) {
        // Redirection vers la réinitialisation du mot de passe
        Navigator.pushReplacementNamed(context, '/reset-password');
      } else {
        // Redirection vers l'accueil après inscription réussie
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la vérification: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulation d'envoi d'OTP
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code de vérification renvoyé avec succès')),
      );
      
      _startResendTimer();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi du code: $e')),
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
        title: const Text('Vérification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo ou image
              const SizedBox(height: AppDimensions.paddingL),
              Icon(
                Icons.verified_user,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              
              // Titre
              const Text(
                'Vérification du code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              
              // Instructions
              Text(
                'Nous avons envoyé un code de vérification à ${widget.destination}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              
              // Champs OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 45,
                    height: 50,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              
              // Bouton de vérification
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Vérifier',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              
              // Option de renvoi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Vous n\'avez pas reçu le code?'),
                  TextButton(
                    onPressed: _canResend ? _resendOtp : null,
                    child: _canResend
                        ? const Text('Renvoyer')
                        : Text('Renvoyer dans $_resendSeconds s'),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingL),
            ],
          ),
        ),
      ),
    );
  }
}
