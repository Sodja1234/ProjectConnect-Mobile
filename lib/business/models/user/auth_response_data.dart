// lib/business/models/user/auth_response_data.dart
import 'package:odc_mobile_template/business/models/user/user.dart'; // Importe le modèle User

class AuthResponseData {
  // Ces champs mappent directement les clés à l'intérieur de l'objet "data" du JSON
  final int id;
  final String name;
  final String email;
  final String? slug;
  final bool isVerified;
  final String token; // Le token est ici, au même niveau que les infos user
  final String? role;

  AuthResponseData({
    required this.id,
    required this.name,
    required this.email,
    this.slug,
    required this.isVerified,
    required this.token,
    this.role,
  });

  // Factory constructor pour créer un AuthResponseData à partir d'un Map (JSON)
  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      slug: json['slug'] as String?,
      isVerified: json['is_verified'] as bool,
      token: json['token'] as String,
      role: json['role'] as String?,
    );
  }

  // Méthode pour convertir un AuthResponseData en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'slug': slug,
      'is_verified': isVerified,
      'token': token,
      'role': role,
    };
  }

  // Méthode utilitaire pour convertir cette AuthResponseData en un objet User
  User toUser() {
    return User(
      id: id,
      name: name,
      email: email,
      slug: slug,
      isVerified: isVerified,
      role: role,
    );
  }
}