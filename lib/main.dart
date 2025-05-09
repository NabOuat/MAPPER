import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'constants/app_theme.dart' as theme_constants;
import 'providers/theme_provider.dart';
import 'providers/places_provider.dart';
import 'providers/users_provider.dart';
import 'providers/messages_provider.dart';
import 'routes.dart';
import 'services/local_storage_service.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'services/places_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser les données mockées
  final storageService = LocalStorageService();
  await storageService.initializeMockData();
  
  // Initialiser la base de données SQLite
  final databaseService = DatabaseService();
  await databaseService.database; // Cela créera la BD si elle n'existe pas
  
  // Initialiser le service d'authentification
  final authService = AuthService();
  await authService.initialize();
  
  // Définir l'orientation de l'application
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(MyApp(
    authService: authService,
    databaseService: databaseService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final DatabaseService databaseService;
  
  const MyApp({
    super.key,
    required this.authService,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider pour le thème
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Providers pour les services
        ChangeNotifierProvider.value(value: authService),
        Provider.value(value: databaseService),
        ChangeNotifierProvider(create: (_) => PlacesService()),
        
        // Providers pour les données
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => PlacesProvider()),
        ChangeNotifierProvider(create: (_) => MessagesProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Ping Mapper',
            theme: theme_constants.AppTheme.lightTheme,
            darkTheme: theme_constants.AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
