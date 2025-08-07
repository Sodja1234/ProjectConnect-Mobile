// lib/business/services/chat/chat_service_network.dart

import 'package:odc_mobile_template/business/models/chat/chat.dart';

abstract class ChatServiceNetwork {
  /// Récupère la liste de tous les chats de l'utilisateur connecté.
  /// Nécessite un jeton d'authentification [token].
  Future<List<Chat>?> getUserChats(String token);

  /// Crée un nouveau chat avec un utilisateur ou un groupe d'utilisateurs.
  /// Nécessite un jeton d'authentification [token] et la liste des IDs des utilisateurs.
  Future<Chat?> createChat({
    required String token,
    required List<int> userIds,
  });
}