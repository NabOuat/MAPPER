import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../providers/users_provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classement'),
      ),
      body: Consumer<UsersProvider>(
        builder: (context, usersProvider, child) {
          if (usersProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (usersProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.errorRed,
                    size: 48,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Text(
                    'Erreur: ${usersProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  ElevatedButton(
                    onPressed: () => usersProvider.loadUsers(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final leaderboard = usersProvider.leaderboard;
          final currentUser = usersProvider.currentUser;
          final currentUserRank = usersProvider.getCurrentUserRank();

          if (leaderboard.isEmpty) {
            return const Center(
              child: Text('Aucun utilisateur trouvé'),
            );
          }

          return Column(
            children: [
              // En-tête avec le rang de l'utilisateur actuel
              if (currentUser != null)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  margin: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            currentUserRank.toString(),
                            style: const TextStyle(
                              color: AppColors.accentCyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Votre classement',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingXS),
                            Text(
                              currentUser.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.place,
                              color: AppColors.accentCyan,
                              size: 16,
                            ),
                            const SizedBox(width: AppDimensions.paddingXS),
                            Text(
                              '${currentUser.score}',
                              style: const TextStyle(
                                color: AppColors.accentCyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Liste des utilisateurs
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final user = leaderboard[index];
                    final isCurrentUser = currentUser != null && user.id == currentUser.id;
                    final rank = index + 1;

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                      elevation: isCurrentUser ? 4 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        side: isCurrentUser
                            ? const BorderSide(color: AppColors.accentCyan, width: 2)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getRankColor(rank),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              rank.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          'Dernière activité: ${_formatDate(user.lastActive)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentCyan.withAlpha(26),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.place,
                                color: AppColors.accentCyan,
                                size: 16,
                              ),
                              const SizedBox(width: AppDimensions.paddingXS),
                              Text(
                                '${user.score}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Or
      case 2:
        return const Color(0xFFC0C0C0); // Argent
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.secondaryGrey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Inconnue';
    }
    
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }
}
