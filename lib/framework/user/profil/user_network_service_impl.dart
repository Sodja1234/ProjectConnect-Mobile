// lib/framework/user/profil/user_network_service_impl.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http; // Import nécessaire pour http.ClientException

import 'package:odc_mobile_template/business/services/user/profil/user_profil_network_service.dart';
import '../../../business/models/user/profil/profil.dart';
import '../../../utils/http/HttpUtils.dart';
import '../../utils/http/localHttpUtils.dart';

class UserProfilNetworkServiceImpl extends UserProfilNetworkService {
  late final String baseUrl;
  late final HttpUtils httpUtils;

  UserProfilNetworkServiceImpl(
      {required this.baseUrl, required this.httpUtils});

  @override
  Future<UserProfile?> getUserProfile(String token) async {
    try {
      var url = '$baseUrl/profile';
      var responseBody = await httpUtils.getData(url, token: token);

      // Ajout d'une ligne pour afficher la réponse de l'API
      print('Réponse brute de l\'API : $responseBody');

      // Assurez-vous de gérer les cas où la réponse est vide
      if (responseBody == null || responseBody.isEmpty) {
        print('Erreur: La réponse de l\'API est vide.');
        return null;
      }

      var data = jsonDecode(responseBody);

      if (data is Map<String, dynamic> && data['data'] != null) {
        // Ajout d'une ligne pour afficher les données passées au modèle
        print('Données envoyées au modèle : ${data['data']}');
        return UserProfile.fromJson(data['data']);
      } else {
        print(
            'Erreur: La réponse JSON ne contient pas la clé "data" ou est mal formée.');
        return null;
      }
    } catch (e, stack) {
      print('Exception inattendue lors de la récupération du profil : $e');
      print(stack);
      return null;
    }
  }
}

void main() async {
  // Simulez un token (en production, il proviendrait de l'authentification)
  const String testToken = 'Bearer 13|TaIY25JL9EO00X0a3Wko5j6h5PdL82AcApaUSH2J67f3c38e';

  // Assurez-vous que votre HttpUtils est configuré pour gérer le token
  var httpUtilsInstance = LocalHttpUtils();

  var userService = UserProfilNetworkServiceImpl(
    // Utilisez l'adresse IP spéciale 10.0.2.2 pour les émulateurs Android.
    // L'adresse IP d'origine (10.252.252.58) causait une erreur "Network is unreachable".
    baseUrl: 'http://10.252.252.58:8000/api',
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