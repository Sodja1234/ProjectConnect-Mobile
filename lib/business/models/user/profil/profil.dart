import 'package:intl/intl.dart';

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? location;
  final String? jobTitle;
  final String? portfolioUrl;
  final String? availability;
  final String? profilePhoto;
  final String? about;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String slug;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.location,
    this.jobTitle,
    this.portfolioUrl,
    this.availability,
    this.profilePhoto,
    this.about,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.slug,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];

    return UserProfile(
      id: userJson['id'],
      name: userJson['name'],
      email: userJson['email'],
      phone: userJson['phone'],
      location: userJson['location'],
      jobTitle: userJson['job_title'],
      portfolioUrl: userJson['portfolio_url'],
      availability: userJson['availability'],
      profilePhoto: userJson['profile_photo'],
      about: userJson['about'],
      emailVerifiedAt: userJson['email_verified_at'] != null
          ? DateTime.parse(userJson['email_verified_at'])
          : null,
      createdAt: DateTime.parse(userJson['created_at']),
      updatedAt: DateTime.parse(userJson['updated_at']),
      slug: userJson['slug'],
    );
  }

  // Helper pour obtenir l'URL complète de la photo de profil
  String? get fullProfilePhotoUrl {
    if (profilePhoto == null) {
      return null;
    }
    // Assurez-vous que c'est l'URL correcte pour accéder aux fichiers stockés de votre backend
    return 'http://localhost:8000/storage/$profilePhoto';
  }

  // Helper pour formater les dates
  String get formattedCreatedAt {
    return DateFormat('dd MMM yyyy').format(createdAt);
  }
}