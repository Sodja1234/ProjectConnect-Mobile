// import '../../models/user/user.dart';
//
// abstract class UserLocalService {
//   Future<User?> recupererUser();
//   Future<bool> sauvegarderUser(User user);
//   Future<bool> supprimerUser();
// }
//
//
// lib/business/services/user/userLocalService.dart
import 'dart:convert'; // Pour jsonEncode et jsonDecode
import 'package:odc_mobile_template/business/models/user/user.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Assurez-vous d'importer votre modèle User
//import 'package:shared_preferences/shared_preferences.dart'; // Importez SharedPreferences

class UserLocalService {
  static const String _userKey = 'loggedInUser'; // Clé pour stocker l'utilisateur

  // Méthode pour enregistrer l'utilisateur localement
  Future<void> enregistrerUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson()); // Convertit l'objet User en JSON string
    await prefs.setString(_userKey, userJson);
    print('UserLocalService: User saved locally.');
  }

  // Méthode pour récupérer l'utilisateur localement
  Future<User?> recupererUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      print('UserLocalService: User retrieved from local storage.');
      return User.fromJson(jsonDecode(userJson)); // Convertit JSON string en objet User
    }
    print('UserLocalService: No user found in local storage.');
    return null;
  }

  // Méthode pour supprimer l'utilisateur localement (pour la déconnexion)
  Future<void> supprimerUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    print('UserLocalService: User removed from local storage.');
  }
}