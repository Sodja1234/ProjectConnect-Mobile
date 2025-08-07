// lib/business/models/user/profil/profil.dart
import 'package:intl/intl.dart';

class UserProfile {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? location;
  final String? jobTitle;
  final String? portfolioUrl;
  final String? availability;
  final String? profilePhoto;
  final String? about;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? slug;

  UserProfile({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.location,
    this.jobTitle,
    this.portfolioUrl,
    this.availability,
    this.profilePhoto,
    this.about,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.slug,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      jobTitle: json['job_title'],
      // Il semble que portfolio_url ne soit pas dans la réponse,
      // donc il sera null.
      // Assurez-vous que l'API est correcte si vous vous attendez à cette valeur.
      portfolioUrl: json['portfolio_url'],
      availability: json['is_availability'],
      profilePhoto: json['profile_photo'],
      about: json['about'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      // slug n'est pas dans votre réponse API, donc il sera null.
      slug: json['slug'],
    );
  }

  String? get fullProfilePhotoUrl {
    if (profilePhoto == null) {
      return null;
    }
    return 'http://10.252.252.58:8000/api/storage/$profilePhoto';
  }

  String get formattedCreatedAt {
    if (createdAt == null) {
      return 'N/A';
    }
    return DateFormat('dd MMM yyyy').format(createdAt!);
  }
}