import 'package:odc_mobile_template/business/models/user/user.dart'; // Assurez-vous d'importer votre modèle User
import 'package:odc_mobile_template/business/models/message/message.dart'; // Importez le modèle Message

class Chat {
  final int id;
  final String type; // 'private' or 'group'
  final String? name; // For group chats
  final List<User> users;
  final Message? lastMessage; // Le dernier message du chat

  Chat({
    required this.id,
    required this.type,
    this.name,
    required this.users,
    this.lastMessage,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String?,
      users: (json['users'] as List<dynamic>)
          .map((userJson) => User.fromJson(userJson as Map<String, dynamic>))
          .toList(),
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'users': users.map((user) => user.toJson()).toList(),
      'last_message': lastMessage?.toJson(),
    };
  }
}