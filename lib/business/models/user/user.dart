class User {
  final int id;
  final String name;
  final String email;
  final String? slug;
  final bool isVerified;
  final String? role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.slug,
    required this.isVerified,
    this.role,
  });

  // Factory constructor pour créer un User à partir d'un Map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      slug: json['slug'] as String?,
      isVerified: json['is_verified'] as bool,
      role: json['role'] as String?,
    );
  }

  // NOUVEAU : Factory constructor pour un User "vide" ou par défaut
  factory User.empty() {
    return User(
      id: 0, // Utilise une valeur par défaut appropriée pour int
      name: '',
      email: '',
      slug: null, // Ou '' si tu préfères une chaîne vide pour les champs nuls
      isVerified: false, // Valeur par défaut pour bool
      role: null, // Ou ''
    );
  }

  // Méthode pour convertir un User en Map (utile pour la sauvegarde locale ou l'envoi)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'slug': slug,
      'is_verified': isVerified,
      'role': role,
    };
  }
}