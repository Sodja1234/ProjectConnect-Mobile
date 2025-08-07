// lib/business/controllers/chat_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/services/chat/chat_service_network.dart';
import 'package:odc_mobile_template/main.dart';

import 'chat_state.dart'; // Assurez-vous que votre getIt est configuré ici

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(getIt<ChatServiceNetwork>());
});

class ChatController extends StateNotifier<ChatState> {
  final ChatServiceNetwork _chatService;

  ChatController(this._chatService) : super(ChatState());

  Future<void> fetchUserChats(String token) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final fetchedChats = await _chatService.getUserChats(token);
      if (fetchedChats != null) {
        state = state.copyWith(isLoading: false, chats: fetchedChats);
      } else {
        state = state.copyWith(isLoading: false, error: 'Impossible de récupérer les chats.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Une erreur est survenue.');
    }
  }
}