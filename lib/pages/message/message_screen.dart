import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:odc_mobile_template/pages/intro/appCtrl.dart';
import 'package:odc_mobile_template/business/models/message/message.dart';
import 'package:odc_mobile_template/business/models/chat/chat.dart'; // Importez le modèle Chat
import '../chat/chat_ctrl.dart'; // Importez le contrôleur de chat
import 'message_ctrl.dart';
import 'dart:math'; // Importez dart:math pour max et min

class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen({super.key});

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen>
    with TickerProviderStateMixin {
  String _contactName = 'Chat'; // Valeur par défaut
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late final String _token;
  late final int _chatId;
  late final int _currentUserId;
  bool _isTyping = false;
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  // Define color palette
  final Color primaryColor = const Color(0xFFFF9800); // Orange
  final Color primaryColorLight = const Color(0xFFFFCC80); // Orange clair pour les messages envoyés
  final Color primaryColorDark = const Color(0xFFE65100); // Orange foncé pour les icônes de statut
  final Color secondaryColor = Colors.white; // Blanc pour l'arrière-plan et l'AppBar

  @override
  void initState() {
    super.initState();

    // Animation pour le bouton d'envoi
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.elasticOut,
    ));

    // Écouter les changements dans le champ de texte
    _messageController.addListener(() {
      final hasText = _messageController.text.isNotEmpty;
      if (hasText != _isTyping) {
        setState(() {
          _isTyping = hasText;
        });
        if (hasText) {
          _sendButtonController.forward();
        } else {
          _sendButtonController.reverse();
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pathParameters = GoRouterState.of(context).pathParameters;
      final chatIdString = pathParameters['chatId'];
      if (kDebugMode) {
        print('DEBUG (MessageScreen): chatId récupéré de GoRouter: $chatIdString');
      }
      if (chatIdString != null) {
        final appState = ref.read(appCtrlProvider);
        _token = appState.userToken ?? '';
        _currentUserId = appState.user?.id ?? -1;
        _chatId = int.parse(chatIdString);
        if (kDebugMode) {
          print('DEBUG (MessageScreen): Token utilisé pour fetchMessages: $_token');
          print('DEBUG (MessageScreen): User ID actuel: $_currentUserId');
        }
        if (_token.isNotEmpty && _currentUserId != -1) {
          ref.read(messageControllerProvider.notifier).fetchMessages(_token, _chatId).then((_) {
            _scrollToBottom();
            // Obtenir le nom du contact/groupe à partir des chats disponibles
            _updateContactName();
          });
        } else {
          if (kDebugMode) {
            print('ERREUR (MessageScreen): Token ou ID utilisateur manquant.');
          }
          ref.read(messageControllerProvider.notifier).state = ref.read(messageControllerProvider).copyWith(
              isLoading: false,
              error: 'Erreur d\'authentification.'
          );
        }
      } else {
        if (kDebugMode) {
          print('ERREUR (MessageScreen): chatId manquant dans les paramètres de la route.');
        }
        ref.read(messageControllerProvider.notifier).state = ref.read(messageControllerProvider).copyWith(
            isLoading: false,
            error: 'Erreur de navigation: ID de chat manquant.'
        );
      }
    });
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    }
  }

  void _updateContactName() {
    final chatState = ref.read(chatControllerProvider);
    // Assurez-vous que la liste des chats est chargée avant de chercher
    if (chatState.chats.isEmpty && !chatState.isLoading) {
      // Si les chats ne sont pas encore chargés, essayez de les charger
      // Note: Cela pourrait créer une boucle si fetchUserChats ne met pas à jour l'état correctement
      // Une meilleure approche serait de s'assurer que les chats sont chargés avant d'arriver ici
      // ou de gérer un état de chargement pour le nom du contact.
      // Pour l'instant, nous allons simplement retourner si la liste est vide.
      return;
    }

    final currentChat = chatState.chats.firstWhere(
          (chat) => chat.id == _chatId,
      orElse: () => Chat(id: _chatId, name: 'Chat inconnu', users: [], type: ''), // Fallback si le chat n'est pas trouvé
    );

    String chatDisplayName = currentChat.name ?? 'Chat';
    if (currentChat.name == null && currentChat.users.isNotEmpty && _currentUserId != -1) {
      // Si c'est un chat 1-1 (pas de nom de groupe), trouver le nom de l'autre utilisateur
      final otherUser = currentChat.users.firstWhere(
            (user) => user.id != _currentUserId,
        orElse: () => currentChat.users.first, // Fallback si c'est un chat avec soi-même ou un seul utilisateur
      );
      chatDisplayName = otherUser.name ?? 'Utilisateur inconnu';
    } else if (currentChat.name == null && currentChat.users.isEmpty) {
      chatDisplayName = 'Chat vide';
    }

    setState(() {
      _contactName = chatDisplayName;
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty && _token.isNotEmpty) {
      // Vibration légère pour le feedback
      HapticFeedback.lightImpact();

      final messageText = _messageController.text;
      _messageController.clear();

      // Animation du bouton d'envoi
      _sendButtonController.reverse();

      await ref.read(messageControllerProvider.notifier).sendMessage(
        _token,
        _chatId,
        messageText,
      );

      _scrollToBottom();
    }
  }

  // Fonction pour formater l'horodatage de manière plus claire (heure seulement)
  String _formatMessageTime(DateTime? timestamp) {
    if (timestamp == null) {
      return '';
    }
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Fonction pour formater la date du séparateur comme WhatsApp
  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate.isAtSameMomentAs(today)) {
      return 'Aujourd\'hui';
    } else if (messageDate.isAtSameMomentAs(yesterday)) {
      return 'Hier';
    } else {
      // Format français : jour/mois/année
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  // Fonction pour grouper les messages par date
  List<Widget> _buildGroupedMessages(List<Message> messages, int currentUserId) {
    if (messages.isEmpty) return [];

    List<Widget> widgets = [];

    // Créer une copie des messages et les trier par date (du plus ancien au plus récent)
    List<Message> sortedMessages = List.from(messages);
    sortedMessages.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return a.createdAt!.compareTo(b.createdAt!);
    });

    DateTime? lastDate;

    // Parcourir les messages dans l'ordre chronologique
    for (int i = 0; i < sortedMessages.length; i++) {
      final message = sortedMessages[i];
      final messageDate = message.createdAt;

      if (messageDate != null) {
        final messageDateOnly = DateTime(messageDate.year, messageDate.month, messageDate.day);

        // Si c'est un nouveau jour, ajouter le séparateur de date
        if (lastDate == null || !messageDateOnly.isAtSameMomentAs(lastDate)) {
          widgets.add(_buildDateSeparator(messageDateOnly));
          lastDate = messageDateOnly;
        }
      }

      widgets.add(_buildMessage(message, currentUserId, i));
    }

    // Inverser la liste pour que les messages récents soient en bas (comme WhatsApp)
    return widgets.reversed.toList();
  }

  // Widget pour le séparateur de date style WhatsApp amélioré
  Widget _buildDateSeparator(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _formatDateSeparator(date),
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageControllerProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _contactName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        // Ajout du bouton de retour, toujours visible
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            try {
              GoRouter.of(context).pop();
            } on GoError catch (e) {
              if (kDebugMode) {
                print('DEBUG (MessageScreen): Erreur lors du pop: ${e.message}');
              }
              // Optionnel: Naviguer vers une page par défaut si pop n'est pas possible
              // context.go('/app/chats'); // Exemple: revenir à la liste des chats
            }
          },
        ),
        backgroundColor: secondaryColor,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                }
                if (state.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.error!,
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                if (state.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun message pour le moment',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Commencez la conversation !',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final groupedWidgets = _buildGroupedMessages(state.messages, _currentUserId);

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: groupedWidgets.length,
                  itemBuilder: (context, index) {
                    return groupedWidgets[index];
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: secondaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? primaryColor.withOpacity(0.3)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Écrire un message...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            ScaleTransition(
              scale: _sendButtonAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: _isTyping ? primaryColor : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  boxShadow: _isTyping ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: _isTyping ? secondaryColor : Colors.grey.shade500,
                    size: 20,
                  ),
                  onPressed: _isTyping ? _sendMessage : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Message message, int currentUserId, int index) {
    final isMe = message.sender?.id == currentUserId;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: max(0, min(1, value)), // Utilisation de clamp pour limiter l'opacité
            child: Align(
              alignment: alignment,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 12.0),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? primaryColorLight : Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18.0),
                      topRight: const Radius.circular(18.0),
                      bottomLeft: Radius.circular(isMe ? 18.0 : 4.0),
                      bottomRight: Radius.circular(isMe ? 4.0 : 18.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        Text(
                          message.sender?.name ?? 'Utilisateur inconnu',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                      ],
                      Text(
                        message.message ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatMessageTime(message.createdAt),
                            style: TextStyle(
                              fontSize: 11.0,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4.0),
                            Icon(
                              Icons.done_all,
                              size: 14,
                              color: primaryColorDark,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }
}
