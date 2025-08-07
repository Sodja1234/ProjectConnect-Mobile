import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:odc_mobile_template/business/models/chat/chat.dart';
import 'package:odc_mobile_template/pages/intro/appCtrl.dart';
import 'chat_ctrl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String token;
  const ChatScreen({Key? key, required this.token}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  // Define color palette
  final Color primaryColor = const Color(0xFFFF9800); // Orange
  final Color secondaryColor = Colors.white;
  final Color accentColor = const Color(0xFFFFB74D); // Orange plus clair pour les badges/indicateurs
  final Color textColor = Colors.grey.shade800;
  final Color subtitleColor = Colors.grey.shade600;
  final Color dividerColor = Colors.grey.shade200;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Chat> _filteredChats = [];
  late int _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = ref.read(appCtrlProvider).user?.id ?? -1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchChatsAndInitializeSearch();
    });

    _searchController.addListener(_performSearch);
  }

  Future<void> _fetchChatsAndInitializeSearch() async {
    await ref.read(chatControllerProvider.notifier).fetchUserChats(widget.token);
    _sortAndFilterChats(); // Appeler la nouvelle fonction de tri et filtrage
  }

  void _performSearch() {
    _sortAndFilterChats(); // Appeler la nouvelle fonction de tri et filtrage
  }

  void _sortAndFilterChats() {
    final allChats = ref.read(chatControllerProvider).chats;
    List<Chat> tempChats = List.from(allChats);

    // Trier les chats par le timestamp du dernier message (du plus récent au plus ancien)
    tempChats.sort((a, b) {
      final DateTime? timeA = a.lastMessage?.createdAt;
      final DateTime? timeB = b.lastMessage?.createdAt;

      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1; // Les chats sans message récent vont à la fin
      if (timeB == null) return -1;
      return timeB.compareTo(timeA); // Tri descendant (plus récent en premier)
    });

    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredChats = tempChats;
      });
    } else {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredChats = tempChats.where((chat) {
          String chatDisplayName = chat.name ?? 'Chat';
          if (chat.name == null && chat.users.isNotEmpty && _currentUserId != -1) {
            final otherUser = chat.users.firstWhere(
                  (user) => user.id != _currentUserId,
              orElse: () => chat.users.first,
            );
            chatDisplayName = otherUser.name ?? 'Utilisateur inconnu';
          }
          final lastMessageText = chat.lastMessage?.message ?? '';

          return chatDisplayName.toLowerCase().contains(query) ||
              lastMessageText.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  // Fonction pour formater l'horodatage de manière plus claire (heure ou date courte)
  String _formatLastMessageTime(DateTime? timestamp) {
    if (timestamp == null) {
      return '';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate.isAtSameMomentAs(today)) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate.isAtSameMomentAs(yesterday)) {
      return 'Hier';
    } else if (now.difference(timestamp).inDays < 7) {
      // Jour de la semaine si moins d'une semaine
      switch (timestamp.weekday) {
        case 1: return 'Lun.';
        case 2: return 'Mar.';
        case 3: return 'Mer.';
        case 4: return 'Jeu.';
        case 5: return 'Ven.';
        case 6: return 'Sam.';
        case 7: return 'Dim.';
        default: return '${timestamp.day}/${timestamp.month}';
      }
    } else {
      // Date complète pour les messages plus anciens
      return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year.toString().substring(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Rechercher...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: InputBorder.none,
          ),
          style: TextStyle(color: textColor, fontSize: 18),
          cursorColor: primaryColor,
        )
            : Text(
          'Mes Chats',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        backgroundColor: secondaryColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: textColor),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: () {
              ref.read(chatControllerProvider.notifier).fetchUserChats(widget.token);
              _searchController.clear();
            },
          ),
        ],
      ),
      body: Builder(
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

          final chatsToDisplay = _isSearching ? _filteredChats : state.chats;

          if (chatsToDisplay.isEmpty) {
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
                    _isSearching ? 'Aucun résultat trouvé.' : 'Aucune conversation trouvée.',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSearching ? 'Essayez une autre recherche.' : 'Commencez une nouvelle discussion !',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: chatsToDisplay.length,
            separatorBuilder: (context, index) => Divider(
              color: dividerColor,
              height: 0.5,
              indent: 80,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final chat = chatsToDisplay[index];

              String chatDisplayName = chat.name ?? 'Chat';
              if (chat.name == null && chat.users.isNotEmpty && _currentUserId != -1) {
                final otherUser = chat.users.firstWhere(
                      (user) => user.id != _currentUserId,
                  orElse: () => chat.users.first,
                );
                chatDisplayName = otherUser.name ?? 'Utilisateur inconnu';
              } else if (chat.name == null && chat.users.isEmpty) {
                chatDisplayName = 'Chat vide';
              }

              final lastMessage = chat.lastMessage;
              final bool isLastMessageFromMe = lastMessage?.sender?.id == _currentUserId;
              final int unreadCount = 0; // chat.unreadCount ?? 0; // À adapter si votre modèle le supporte

              return InkWell(
                onTap: () {
                  context.goNamed(
                    'app_messages_page',
                    pathParameters: {'chatId': chat.id.toString()},
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  color: secondaryColor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: Text(
                          chatDisplayName.isNotEmpty ? chatDisplayName[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chatDisplayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (isLastMessageFromMe)
                                  Icon(
                                    Icons.done_all,
                                    size: 16,
                                    color: unreadCount > 0 ? primaryColor : subtitleColor,
                                  ),
                                if (isLastMessageFromMe) const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    lastMessage?.message ?? 'Aucun message récent',
                                    style: TextStyle(
                                      color: unreadCount > 0 ? textColor : subtitleColor,
                                      fontSize: 14,
                                      fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (lastMessage?.createdAt != null)
                            Text(
                              _formatLastMessageTime(lastMessage?.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: unreadCount > 0 ? primaryColor : subtitleColor,
                                fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                          if (unreadCount > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action pour démarrer un nouveau chat
          // context.goNamed('new_chat_page');
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.chat, color: secondaryColor),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    super.dispose();
  }
}
