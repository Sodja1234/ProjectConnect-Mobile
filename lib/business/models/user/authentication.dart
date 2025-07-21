// lib/business/models/user/authentication.dart

class Authentication {
  final String email; // Rendu non-nullable car l'email est requis pour l'authentification
  final String password; // Rendu non-nullable car le mot de passe est requis

  // Constructeur avec paramètres requis
  Authentication({
    required this.email,
    required this.password,
  });

  // Factory constructor pour la désérialisation (from JSON)
  factory Authentication.fromJson(Map<String, dynamic> json) {
    return Authentication(
      email: json['email'] as String, // Cast explicite pour la sécurité
      password: json['password'] as String, // Cast explicite
    );
  }

  // Méthode pour la sérialisation (to JSON)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}