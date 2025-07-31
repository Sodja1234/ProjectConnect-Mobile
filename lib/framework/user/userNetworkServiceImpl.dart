// lib/business/services/user/user_network_service_impl.dart

import 'dart:convert';
import 'package:odc_mobile_template/business/models/user/registerUser.dart';
import 'package:odc_mobile_template/business/models/user/verifyOtp.dart';
import '../../business/models/user/authResponse.dart';
import '../../business/models/user/authentication.dart';
import '../../business/models/user/user.dart';
import '../../business/services/user/userNetworkService.dart';
import '../../utils/http/HttpUtils.dart';
import '../../utils/http/HttpRequestException.dart'; // Assure-toi que ce chemin est correct pour AuthResponse
import '../../business/models/user/auth_response_data.dart'; // Assure-toi que ce chemin est correct pour AuthResponseData


class UserNetworkServiceImpl implements UserNetworkService {
  final String baseUrl;
  final HttpUtils httpUtils;

  UserNetworkServiceImpl({required this.baseUrl, required this.httpUtils});

  @override
  Future<User> recupererInfoUtilisateur() {
    throw UnimplementedError('recupererInfoUtilisateur non implémenté');
  }

  @override
  Future<AuthResponse> seConnecter(Authentication authentication) async {
    final url = '$baseUrl/login'; // Assure-toi que l'URL est correcte, par exemple : '$baseUrl/auth/login' si 'auth' est un préfixe
    final body = authentication.toJson();

    print('DEBUG: Tentative de connexion à l\'URL: $url');
    print('DEBUG: Corps de la requête d\'authentification: $body');

    try {
      final dynamic rawResponseData = await httpUtils.postData(url, body: body);

      print('DEBUG: Réponse brute reçue de l\'API (type: ${rawResponseData.runtimeType}): $rawResponseData');

      Map<String, dynamic> responseMap;
      if (rawResponseData is String) {
        try {
          responseMap = jsonDecode(rawResponseData) as Map<String, dynamic>;
          print('DEBUG: Réponse JSON parsée depuis String: $responseMap');
        } catch (e) {
          print('ERREUR: Impossible de décoder la réponse String en JSON: $rawResponseData');
          throw Exception('Format de réponse non-JSON reçu du serveur (string mal formé ou HTML): $rawResponseData');
        }
      } else if (rawResponseData is Map<String, dynamic>) {
        responseMap = rawResponseData;
        print('DEBUG: Réponse JSON directement reçue en Map: $responseMap');
      } else {
        throw Exception('Format de réponse HTTP inattendu: $rawResponseData (ni String ni Map)');
      }

      // Maintenant, nous parsons la réponse selon la structure JSON que tu as fournie :
      // { "data": { "id": 1, ..., "token": "..." } }

      // 1. Vérifie si la clé 'data' existe et est un Map
      if (!responseMap.containsKey('data') || !(responseMap['data'] is Map<String, dynamic>)) {
        print('ERREUR: La clé "data" est manquante ou n\'est pas un Map dans la réponse.');
        throw Exception('Structure de réponse invalide: la clé "data" est introuvable ou incorrecte.');
      }

      final Map<String, dynamic> dataPayload = responseMap['data'] as Map<String, dynamic>;
      print('DEBUG: Payload "data" extrait: $dataPayload');

      // 2. Parser le payload 'data' dans AuthResponseData
      // AuthResponseData contient toutes les infos utilisateur et le token
      final AuthResponseData authResponseData = AuthResponseData.fromJson(dataPayload);
      print('DEBUG: AuthResponseData parsé: User ID=${authResponseData.id}, Email=${authResponseData.email}');

      // 3. Vérifie si le token est présent et non vide dans AuthResponseData
      if (authResponseData.token.isEmpty) {
        print('ERREUR: Le champ "token" est vide dans les données de l\'AuthResponseData.');
        throw Exception('Token d\'authentification introuvable ou vide dans la réponse.');
      }

      print('Connecté avec succès. User ID: ${authResponseData.id}, Token: ${authResponseData.token.substring(0, 10)}...'); // Affiche seulement les 10 premiers caractères du token pour la sécurité

      // Crée un objet AuthResponse en utilisant AuthResponseData
      // Rappel: Le modèle AuthResponse doit avoir une propriété 'data' de type AuthResponseData
      // et potentiellement une méthode toUser() si nécessaire plus tard.
      return AuthResponse(data: authResponseData);

    } on HttpRequestException catch (e) {
      print('ERREUR HTTP: ${e.message} (StatusCode: ${e.statusCode})');
      throw e;
    } on FormatException catch (e) {
      print('ERREUR DE FORMAT (JSON): ${e.message}');
      throw Exception('Erreur de format de réponse de l\'API. Vérifiez que la réponse est un JSON valide.');
    } catch (e) {
      print('ERREUR INATTENDUE dans seConnecter: $e');
      throw Exception('Erreur inattendue lors de la connexion: $e');
    }
  }

  @override
  Future<void> registerUser(RegisterUser registerUser) async {
    final url = '$baseUrl/register';
    final body = registerUser.toJson();
    print('DEBUG: Tentative d\'enregistrement à l\'URL: $url');
    print('DEBUG: Corps de la requête d\'enregistrement: $body');
    try {
      final response = await httpUtils.postData(url, body: body);
      print('DEBUG: Réponse enregistrement: $response');
    } on HttpRequestException catch (e) {
      print('ERREUR HTTP enregistrement: ${e.message} (StatusCode: ${e.statusCode})');
      throw e;
    } catch (e) {
      print('ERREUR INATTENDUE lors de l\'enregistrement: $e');
      throw Exception('Erreur inattendue lors de l\'enregistrement: $e');
    }
  }

  @override
  Future<void> verifyOtp(VerifyOtp verifyOtp) async {
    final url = '$baseUrl/verify-otp';
    final body = verifyOtp.toJson();
    print('DEBUG: Tentative de vérification OTP à l\'URL: $url');
    print('DEBUG: Corps de la requête vérification OTP: $body');
    try {
      final response = await httpUtils.postData(url, body: body);
      print('DEBUG: Réponse vérification OTP: $response');
    } on HttpRequestException catch (e) {
      print('ERREUR HTTP vérification OTP: ${e.message} (StatusCode: ${e.statusCode})');
      throw e;
    } catch (e) {
      print('ERREUR INATTENDUE lors de la vérification OTP: $e');
      throw Exception('Erreur inattendue lors de la vérification OTP: $e');
    }
  }

  @override
  Future<void> resendOtp(VerifyOtp resendOtp) async {
    final url = '$baseUrl/resend-otp';
    final body = resendOtp.toJson();
    print('DEBUG: Tentative de renvoi OTP à l\'URL: $url');
    print('DEBUG: Corps de la requête renvoi OTP: $body');
    try {
      final response = await httpUtils.postData(url, body: body);
      print('DEBUG: Réponse renvoi OTP: $response');
    } on HttpRequestException catch (e) {
      print('ERREUR HTTP renvoi OTP: ${e.message} (StatusCode: ${e.statusCode})');
      throw e;
    } catch (e) {
      print('ERREUR INATTENDUE lors du renvoi OTP: $e');
      throw Exception('Erreur inattendue lors du renvoi OTP: $e');
    }
  }
}