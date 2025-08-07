
class Message {
  final int? id;
  final int? chatId;
  final int? senderId;
  final int? receiverId;
  final int? groupId;
  final String? message;
  final DateTime? createdAt;
  final Sender? sender;

  Message({
    this.id,
    this.chatId,
    this.senderId,
    this.receiverId,
    this.groupId,
    this.message,
    this.createdAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      chatId: json['chat_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      groupId: json['group_id'],
      message: json['message'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      sender: json['sender'] != null ? Sender.fromJson(json['sender']) : null,
    );
  }

  // --- Méthode toJson() ajoutée pour résoudre l'erreur ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'group_id': groupId,
      'message': message,
      'created_at': createdAt?.toIso8601String(),
      'sender': sender?.toJson(), // Assurez-vous que Sender a aussi une méthode toJson()
    };
  }
}

class Sender {
  final int? id;
  final String? name;
  final String? email;
  final String? profilePhoto;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? slug;
  final String? role;

  Sender({
    this.id,
    this.name,
    this.email,
    this.profilePhoto,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.slug,
    this.role,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePhoto: json['profile_photo'],
      emailVerifiedAt: json['email_verified_at'] != null ? DateTime.parse(json['email_verified_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      slug: json['slug'],
      role: json['role'],
    );
  }

  // --- Méthode toJson() ajoutée pour le modèle Sender ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_photo': profilePhoto,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'slug': slug,
      'role': role,
    };
  }
}