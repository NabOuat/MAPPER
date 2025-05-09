import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../providers/messages_provider.dart';
import '../providers/users_provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les messages au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessagesProvider>(context, listen: false).loadMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Consumer2<MessagesProvider, UsersProvider>(
        builder: (context, messagesProvider, usersProvider, child) {
          if (messagesProvider.isLoading || usersProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (messagesProvider.error != null) {
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
                    'Erreur: ${messagesProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  ElevatedButton(
                    onPressed: () => messagesProvider.loadMessages(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final currentUser = usersProvider.currentUser;
          if (currentUser == null) {
            return const Center(
              child: Text('Utilisateur non disponible'),
            );
          }

          final conversations = messagesProvider.getConversationsList(currentUser.id);

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: AppColors.secondaryGrey,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  const Text(
                    'Aucune conversation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  const Text(
                    'Vos conversations apparaîtront ici',
                    style: TextStyle(
                      color: AppColors.secondaryGrey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final userId = conversation['userId'] as String;
              final userName = conversation['userName'] as String;
              final lastMessage = conversation['lastMessage'] as String;
              final timestamp = conversation['timestamp'] as DateTime;
              final unreadCount = conversation['unreadCount'] as int;

              return Card(
                margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppDimensions.paddingM),
                  leading: CircleAvatar(
                    backgroundColor: unreadCount > 0 
                        ? AppColors.accentCyan 
                        : AppColors.secondaryGrey,
                    child: Text(
                      userName.isNotEmpty 
                          ? userName[0].toUpperCase() 
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName.isNotEmpty ? userName : 'Utilisateur',
                          style: TextStyle(
                            fontWeight: unreadCount > 0 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: unreadCount > 0 
                              ? AppColors.accentCyan 
                              : AppColors.secondaryGrey,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: unreadCount > 0 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingXS),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.accentCyan,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    context.push(
                      '/chat/$userId?userName=${Uri.encodeComponent(userName)}',
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Hier';
    } else {
      return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}';
    }
  }
}
