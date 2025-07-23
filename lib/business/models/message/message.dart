import 'package:odc_mobile_template/business/models/user/user.dart';

class Message {
  final int id;
  final int chatId;
  final int senderId;
  final String message;
  final String createdAt; // Ou DateTime si vous préférez un objet DateTime
  final User sender;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    required this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      chatId: json['chat_id'] as int,
      senderId: json['sender_id'] as int,
      message: json['message'] as String,
      createdAt: json['created_at'] as String,
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'message': message,
      'created_at': createdAt,
      'sender': sender.toJson(),
    };
  }
}