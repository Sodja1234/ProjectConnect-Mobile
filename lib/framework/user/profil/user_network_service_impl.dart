import 'dart:convert'; // Pour jsonDecode

import 'package:odc_mobile_template/business/services/user/profil/user_profil_network_service.dart';
import '../../../business/models/user/profil/profil.dart';
import '../../../utils/http/HttpUtils.dart';
import '../../utils/http/localHttpUtils.dart'; // Votre interface abstraite

class UserProfilNetworkServiceImpl extends UserProfilNetworkService {
  late final String baseUrl;
  late final HttpUtils httpUtils; // Injection de dépendance pour HttpUtils

  UserProfilNetworkServiceImpl({required this.baseUrl, required this.httpUtils});

  @override
  Future<UserProfile?> getUserProfile(String token) async {
    try {
      var url = '$baseUrl/profile'; // L'URL de votre endpoint de profil

      var responseBody = await httpUtils.getData(url, token: token);

      // Décodage de la chaîne JSON
      var data = jsonDecode(responseBody);

      // Assurez-vous que la structure JSON correspond à votre modèle UserProfile.
      // Dans votre exemple, les données de l'utilisateur sont sous la clé "user".
      if (data != null && data['user'] != null) {
        return UserProfile.fromJson(data);
      } else {
        print('Erreur: La réponse JSON ne contient pas la clé "user" ou est vide.');
        return null;
      }
    } catch (e, stack) {
      print('Exception lors de la récupération du profil utilisateur : $e');
      print(stack); // Pour obtenir la trace de la pile en cas d'erreur
      return null;
    }
  }
}

void main() async {
  // Simulez un token (en production, il proviendrait de l'authentification)
  // Remplacez 'YOUR_AUTH_TOKEN_HERE' par un vrai token si nécessaire pour les tests
  const String testToken = 'Bearer 57|OLAWhWAOt0q7F6rBuOkgYO9XcsW8rr16jCtSsO8ie68f1da7';

  // Assurez-vous que votre HttpUtils est configuré pour gérer le token si votre API l'exige
  // Si vous utilisez LocalHttpUtils, il doit être compatible avec HttpUtils
  var httpUtilsInstance = LocalHttpUtils(); // Ou new HttpUtils() si LocalHttpUtils n'est pas nécessaire

  var userService = UserProfilNetworkServiceImpl(
    baseUrl: 'http://10.252.252.3:8000/api', // Pour émulateur Android
    // Ou 'http://192.168.1.X:8000/api' pour appareil physique
    // Ou 'http://localhost:8000/api' pour le simulateur iOS ou le web
    httpUtils: httpUtilsInstance,
  );

  print('Tentative de récupération du profil utilisateur...');
  UserProfile? userProfile = await userService.getUserProfile(testToken);

  if (userProfile != null) {
    print('Profil utilisateur récupéré avec succès :');
    print('  ID: ${userProfile.id}');
    print('  Nom: ${userProfile.name}');
    print('  Email: ${userProfile.email}');
    print('  Titre du poste: ${userProfile.jobTitle ?? 'N/A'}');
    print('  Photo de profil URL: ${userProfile.fullProfilePhotoUrl ?? 'N/A'}');
    print('  Membre depuis: ${userProfile.formattedCreatedAt}');
    print('  À propos: ${userProfile.about ?? 'N/A'}');
  } else {
    print('Échec de la récupération du profil utilisateur.');
  }
}