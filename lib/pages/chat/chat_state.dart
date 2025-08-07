// lib/business/states/chat_state.dart

import 'package:odc_mobile_template/business/models/chat/chat.dart';

class ChatState {
  final bool isLoading;
  final List<Chat> chats;
  final String? error;

  ChatState({
    this.isLoading = false,
    this.chats = const [],
    this.error,
  });

  ChatState copyWith({
    bool? isLoading,
    List<Chat>? chats,
    String? error,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      chats: chats ?? this.chats,
      error: error,
    );
  }
}