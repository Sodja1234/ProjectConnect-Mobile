// lib/business/services/user/userNetworkService.dart
import 'package:odc_mobile_template/business/models/user/profil/profil.dart';

abstract class UserProfilNetworkService {
  Future<UserProfile?> getUserProfile(String token);

// Vous pourriez ajouter d'autres méthodes ici, par exemple :
// Future<bool?> updateProfile(UpdateProfileData data, String token);
// Future<bool?> uploadProfilePhoto(File photo, String token);
}