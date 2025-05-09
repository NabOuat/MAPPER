import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_place_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/amis_screen.dart';
// Removed unused imports
import 'screens/duels_screen.dart';
import 'screens/classement_screen.dart';
// Nouveaux écrans d'authentification
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/reset_password_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

// Configuration des routes de l'application
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // Écran de démarrage
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    
    // Écran de connexion
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    
    // Écran d'inscription
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    
    // Écran de mot de passe oublié
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    
    // Écran de vérification OTP
    GoRoute(
      path: '/otp-verification',
      name: 'otp-verification',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return OtpVerificationScreen(
          destination: args['destination'] as String,
          isEmail: args['isEmail'] as bool,
          isPasswordReset: args['isPasswordReset'] as bool? ?? false,
        );
      },
    ),
    
    // Écran de réinitialisation de mot de passe
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    // Route shell avec la barre de navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        // Accueil avec carte
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
          routes: [
            // Ajouter un lieu
            GoRoute(
              path: 'add-place',
              name: 'add-place',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const AddPlaceScreen(),
            ),
          ],
        ),
        // Classement
        GoRoute(
          path: '/leaderboard',
          name: 'leaderboard',
          builder: (context, state) => const LeaderboardScreen(),
        ),
        // Liste des conversations
        GoRoute(
          path: '/chat',
          name: 'chat-list',
          builder: (context, state) => const ChatListScreen(),
          routes: [
            // Conversation individuelle
            GoRoute(
              path: ':userId',
              name: 'chat',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final userId = state.pathParameters['userId']!;
                final userName = state.uri.queryParameters['userName'] ?? 'Utilisateur';
                return ChatScreen(userId: userId, userName: userName);
              },
            ),
          ],
        ),
        // Profil utilisateur
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        // Paramètres
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        // Amis
        GoRoute(
          path: '/amis',
          name: 'amis',
          builder: (context, state) => const AmisScreen(),
        ),
        // Duels
        GoRoute(
          path: '/duels',
          name: 'duels',
          builder: (context, state) => const DuelsScreen(),
        ),
        // Classement
        GoRoute(
          path: '/classement',
          name: 'classement',
          builder: (context, state) => const ClassementScreen(),
        ),
      ],
    ),
  ],
);

// Widget pour la barre de navigation
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Amis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_kabaddi),
            label: 'Duels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Classement',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/amis')) {
      return 1;
    } else if (location.startsWith('/duels')) {
      return 2;
    } else if (location.startsWith('/classement')) {
      return 3;
    } else if (location.startsWith('/profile')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/amis');
        break;
      case 2:
        GoRouter.of(context).go('/duels');
        break;
      case 3:
        GoRouter.of(context).go('/classement');
        break;
      case 4:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
