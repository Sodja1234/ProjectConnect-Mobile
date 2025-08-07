import '../../models/message/message.dart';

abstract class MessageNetworkService {
  /// Récupère une liste de messages pour un chat spécifique depuis l'API.
  /// Nécessite un jeton d'authentification [token] et l'ID du chat [chatId].
  Future<List<Message>?> getMessages(String token, int chatId);

  /// Envoie un nouveau message à un utilisateur ou à un groupe.
  /// Nécessite le jeton d'authentification [token] et le [message] à envoyer.
  /// [chatId] est l'ID du chat.
  Future<bool> sendMessage({
    required String token,
    required String message,
    required int chatId,
  });
}