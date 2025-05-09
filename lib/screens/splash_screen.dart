import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _currentImageIndex = 0;
  final List<String> _splashImages = [
    'assets/images/splashscreen/map.gif',
    'assets/images/splashscreen/gagner.gif',
  ];

  @override
  void initState() {
    super.initState();
    
    // Configuration de l'animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    // Démarrer l'animation
    _controller.forward();
    
    // Changer d'image toutes les 3 secondes
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _splashImages.length;
          _controller.reset();
          _controller.forward();
        });
      }
    });
    
    // Naviguer vers l'écran de connexion après 6 secondes
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo et nom de l'application
            const Text(
              'Ping Mapper',
              style: TextStyle(
                color: AppColors.accentCyan,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            
            // GIF animé
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentCyan.withAlpha(77),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  child: Image.asset(
                    _splashImages[_currentImageIndex],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingXL),
            
            // Texte de chargement
            const Text(
              'Collectez, visualisez, partagez',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: AppDimensions.paddingL),
            
            // Indicateur de chargement
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
