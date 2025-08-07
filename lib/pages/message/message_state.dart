// lib/business/states/message_state.dart

import 'package:odc_mobile_template/business/models/message/message.dart';

class MessageState {
  final bool isLoading;
  final List<Message> messages;
  final String? error;

  MessageState({
    this.isLoading = false,
    this.messages = const [],
    this.error,
  });

  MessageState copyWith({
    bool? isLoading,
    List<Message>? messages,
    String? error,
  }) {
    return MessageState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      error: error,
    );
  }
}