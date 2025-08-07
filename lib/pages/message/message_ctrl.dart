// lib/business/controllers/message_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/services/message/message_service_network.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/business/models/message/message.dart';

import 'message_state.dart';

final messageControllerProvider = StateNotifierProvider<MessageController, MessageState>((ref) {
  return MessageController(getIt<MessageNetworkService>());
});

class MessageController extends StateNotifier<MessageState> {
  final MessageNetworkService _messageService;

  MessageController(this._messageService) : super(MessageState());

  Future<void> fetchMessages(String token, int chatId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final fetchedMessages = await _messageService.getMessages(token, chatId);
      if (fetchedMessages != null) {
        state = state.copyWith(isLoading: false, messages: fetchedMessages);
      } else {
        state = state.copyWith(isLoading: false, error: 'Impossible de récupérer les messages.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Une erreur est survenue lors de la récupération des messages.');
    }
  }

  // Méthode pour envoyer un nouveau message
  Future<void> sendMessage(String token, int chatId, String messageText) async {
    state = state.copyWith(isLoading: true); // Optionnel : indicateur de chargement
    try {
      final success = await _messageService.sendMessage(
        token: token,
        chatId: chatId,
        message: messageText,
      );
      if (success) {
        // En cas de succès, on relance la récupération pour avoir le nouveau message
        await fetchMessages(token, chatId);
      } else {
        state = state.copyWith(isLoading: false, error: "Échec de l'envoi du message.");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Erreur lors de l'envoi du message.");
    }
  }
}