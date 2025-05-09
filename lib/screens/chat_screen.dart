import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/message.dart';
import '../providers/messages_provider.dart';
import '../providers/users_provider.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Marquer les messages comme lus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessagesProvider>(context, listen: false)
          .markAsRead(widget.userId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  Widget _mediaButton(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label non disponible en mode hors ligne')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS, vertical: AppDimensions.paddingXS),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await Provider.of<MessagesProvider>(context, listen: false)
          .sendMessage(widget.userId, text);
      
      _messageController.clear();
      
      // Faire défiler vers le bas après l'envoi
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accentCyan,
              child: Text(
                widget.userName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.userName, style: const TextStyle(fontSize: 16)),
                const Text('En ligne', style: TextStyle(fontSize: 12, color: AppColors.successGreen)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appel vidéo non disponible en mode hors ligne')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appel audio non disponible en mode hors ligne')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Consumer2<MessagesProvider, UsersProvider>(
              builder: (context, messagesProvider, usersProvider, child) {
                if (messagesProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final currentUser = usersProvider.currentUser;
                if (currentUser == null) {
                  return const Center(
                    child: Text('Utilisateur non disponible'),
                  );
                }

                final messages = messagesProvider.getConversation(
                  currentUser.id,
                  widget.userId,
                );

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Aucun message'),
                  );
                }

                // Faire défiler vers le bas après le chargement
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isFromCurrentUser = message.senderId == currentUser.id;

                    return _MessageBubble(
                      message: message,
                      isFromCurrentUser: isFromCurrentUser,
                      onReactionToggle: (reaction, isAdding) {
                        messagesProvider.toggleReaction(
                          message.id,
                          currentUser.id,
                          reaction,
                          isAdding,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Zone de saisie moderne
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: AppDimensions.paddingS),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Options de médias (images, emojis, etc.)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _mediaButton(Icons.image, 'Photo', Colors.green),
                    _mediaButton(Icons.gif, 'GIF', Colors.purple),
                    _mediaButton(Icons.emoji_emotions, 'Emoji', Colors.amber),
                    _mediaButton(Icons.mic, 'Audio', Colors.red),
                    _mediaButton(Icons.location_on, 'Lieu', AppColors.accentCyan),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingS),
                // Champ de saisie et bouton d'envoi
                Row(
                  children: [
                    // Bouton d'ajout de média
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan.withAlpha(51),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: AppColors.accentCyan),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fonctionnalité disponible uniquement en ligne')),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(width: AppDimensions.paddingS),
                    
                    // Champ de texte
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? AppColors.cardDarkBackground 
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                          border: Border.all(color: AppColors.accentCyan.withAlpha(77)),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Votre message...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingS,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.emoji_emotions_outlined, color: AppColors.secondaryGrey),
                              onPressed: () {
                                // Afficher le sélecteur d'emoji
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Sélecteur d\'emoji non disponible en mode hors ligne')),
                                );
                              },
                            ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 5,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: AppDimensions.paddingS),
                    
                    // Bouton d'envoi
                    Container(
                      decoration: BoxDecoration(
                        color: _messageController.text.trim().isEmpty ? Colors.grey : AppColors.accentCyan,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                        color: Colors.white,
                        onPressed: _isSending || _messageController.text.trim().isEmpty ? null : _sendMessage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatefulWidget {
  final Message message;
  final bool isFromCurrentUser;
  final Function(String, bool)? onReactionToggle;

  const _MessageBubble({
    required this.message,
    required this.isFromCurrentUser,
    this.onReactionToggle,
  });

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isShowingReactions = false;
  
  final List<String> _availableReactions = ['👍', '❤️', '😂', '😮', '😢', '👏'];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggleReactionPanel() {
    setState(() {
      _isShowingReactions = !_isShowingReactions;
    });
    
    if (_isShowingReactions) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
  
  void _addReaction(String reaction) {
    // Ici, nous appellerions la méthode pour ajouter une réaction
    // Pour l'instant, nous fermons simplement le panneau
    if (widget.onReactionToggle != null) {
      // Vérifier si l'utilisateur a déjà réagi avec cette réaction
      final userId = 'current_user_id'; // À remplacer par l'ID réel de l'utilisateur
      final hasReacted = widget.message.reactions[reaction]?[userId] ?? false;
      
      // Inverser l'état de la réaction
      widget.onReactionToggle!(reaction, !hasReacted);
    }
    
    setState(() {
      _isShowingReactions = false;
    });
    _animationController.reverse();
  }
  
  int _getReactionCount(String reaction) {
    final reactionsForType = widget.message.reactions[reaction];
    if (reactionsForType == null) return 0;
    
    return reactionsForType.values.where((hasReacted) => hasReacted).length;
  }
  
  bool _hasUserReacted(String reaction) {
    final userId = 'current_user_id'; // À remplacer par l'ID réel de l'utilisateur
    return widget.message.reactions[reaction]?[userId] ?? false;
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.isFromCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Panneau de réactions
        if (_isShowingReactions)
          ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingXS),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingXS),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _availableReactions.map((reaction) => 
                      GestureDetector(
                        onTap: () => _addReaction(reaction),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            reaction,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),
            ),
          ),
        
        // Bulle de message
        GestureDetector(
          onLongPress: _toggleReactionPanel,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.paddingXS),
            child: Row(
              mainAxisAlignment: widget.isFromCurrentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!widget.isFromCurrentUser)
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: AppDimensions.paddingXS),
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.message.senderName.isNotEmpty
                            ? widget.message.senderName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isFromCurrentUser
                          ? AppColors.accentCyan
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message.content,
                          style: TextStyle(
                            color: widget.isFromCurrentUser ? Colors.white : null,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingXS),
                        Text(
                          _formatTime(widget.message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.isFromCurrentUser
                                ? Colors.white.withAlpha(179)
                                : AppColors.secondaryGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (widget.isFromCurrentUser && widget.message.isSynced)
                  const Padding(
                    padding: EdgeInsets.only(left: AppDimensions.paddingXS),
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.accentCyan,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Affichage des réactions
        if (widget.message.reactions.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              left: widget.isFromCurrentUser ? 0 : 28 + AppDimensions.paddingXS,
              bottom: AppDimensions.paddingS,
            ),
            child: Wrap(
              spacing: AppDimensions.paddingXS,
              children: widget.message.reactions.entries
                  .where((entry) => _getReactionCount(entry.key) > 0)
                  .map((entry) => (
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingXS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _hasUserReacted(entry.key)
                            ? AppColors.accentCyan.withAlpha(51)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(
                          color: _hasUserReacted(entry.key)
                              ? AppColors.accentCyan
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(entry.key),
                          const SizedBox(width: 4),
                          Text(
                            _getReactionCount(entry.key).toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _hasUserReacted(entry.key)
                                  ? AppColors.accentCyan
                                  : AppColors.secondaryGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
