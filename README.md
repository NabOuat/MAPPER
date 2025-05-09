# Ping Mapper

Application mobile professionnelle de collecte, visualisation et gestion collaborative de points géolocalisés.

## Fonctionnalités

- **Ajout de lieux** : Enregistrement rapide de points d'intérêt avec nom et position GPS automatique
- **Carte interactive** : Visualisation des points ajoutés sur une carte légère basée sur OpenStreetMap
- **Classement** : Système de score et classement des utilisateurs selon leur activité
- **Messagerie** : Chat intégré pour la communication entre utilisateurs
- **Mode hors-ligne** : Stockage local des données avec synchronisation ultérieure
- **Interface adaptative** : Support du mode sombre et clair

## Caractéristiques techniques

- **Optimisation** : Consommation internet et batterie maîtrisées
- **Taille réduite** : APK cible ≤ 50 Mo
- **Mise en cache** : Cartes et ressources stockées localement
- **Mode offline-first** : Fonctionnement sans connexion internet

## Pages principales

1. **Accueil / Dashboard** : Carte avec les points d'intérêt et bouton d'ajout
2. **Ajout d'un lieu** : Formulaire avec géolocalisation automatique
3. **Classement** : Liste des meilleurs contributeurs
4. **Chat** : Messagerie entre utilisateurs
5. **Profil / Paramètres** : Gestion du profil et préférences (mode sombre, etc.)

## Palette de couleurs

- **Fond (Dark Mode)** : #0D1B2A
- **Accent cyan** : #4ECDC4
- **Texte principal** : #FFFFFF en dark, #1A2C56 en light
- **Éléments secondaires** : #8D99AE

## Installation

```bash
# Cloner le dépôt
git clone https://github.com/votre-utilisateur/ping-mapper.git

# Accéder au répertoire
cd ping-mapper

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

## Structure du projet

```
lib/
├── constants/       # Constantes (couleurs, dimensions, thèmes)
├── models/          # Modèles de données
├── providers/       # Gestion de l'état avec Provider
├── screens/         # Écrans de l'application
├── services/        # Services (stockage local, géolocalisation)
├── widgets/         # Widgets réutilisables
├── routes.dart      # Configuration des routes
└── main.dart        # Point d'entrée de l'application
```

## Développement

Cette application est développée avec Flutter et utilise les packages suivants :

- **flutter_map** : Affichage de cartes légères
- **provider** : Gestion de l'état
- **sqflite** : Stockage local
- **geolocator** : Géolocalisation
- **go_router** : Navigation

## Licence

Ce projet est sous licence MIT.
