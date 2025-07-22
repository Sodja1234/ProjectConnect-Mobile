// lib/business/services/user/userNetworkServiceImpl.dart
import 'dart:convert'; // Pour jsonDecode si responseData est une String

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:odc_mobile_template/business/models/user/registerUser.dart';

import 'package:odc_mobile_template/business/models/user/verifyOtp.dart';

import '../../business/models/user/authentication.dart';

import '../../business/models/user/user.dart';

import '../../business/services/user/userNetworkService.dart';
import '../../utils/http/HttpUtils.dart';
import '../utils/http/localHttpUtils.dart';
import '../../utils/http/HttpRequestException.dart';
import '../../utils/remoteHttpUtils.dart';
class UserNetworkServiceImpl extends UserNetworkService {
  final String baseUrl;
  final HttpUtils httpUtils;

  UserNetworkServiceImpl({required this.baseUrl, required this.httpUtils});

  @override
  Future<User> recupererInfoUtilisateur() {
    // TODO: implement recupererInfoUtilisateur
    throw UnimplementedError();
  }

  @override
  Future<User> seConnecter(Authentication authentication) async {
    final url = '$baseUrl/login';
    final body = authentication.toJson();

    try {
      final dynamic rawResponseData = await httpUtils.postData(url, body: body);

      // Décodez la chaîne JSON si nécessaire
      Map<String, dynamic> responseMap;
      if (rawResponseData is String) {
        responseMap = jsonDecode(rawResponseData); // Décode la chaîne JSON
      } else if (rawResponseData is Map<String, dynamic>) {
        responseMap = rawResponseData; // C'est déjà un Map
      } else {
        throw Exception('Format de réponse HTTP inattendu: $rawResponseData');
      }

      // Maintenant, travaillez avec responseMap
      if (responseMap.containsKey('data') && responseMap['data'] is Map<String, dynamic>) {
        final Map<String, dynamic> userData = responseMap['data'];
        final User user = User.fromJson(userData); // Parse l'utilisateur

        // AJOUT DU PRINT ICI
        print('Connecté avec les données de l\'utilisateur : ${user.toJson()}');

        return user;
      } else {
        throw Exception('Données utilisateur introuvables ou format incorrect dans la réponse: $responseMap');
      }

    } on HttpRequestException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Erreur inattendue lors de la connexion: $e');
    }
  }

  // @override
  Future<void> registerUser(RegisterUser registerUser) async {
   var url = '$baseUrl/register/';
   var body = registerUser.toJson();
   var response = await httpUtils.postData(url,body: body);
   print(response);
   return;
  }

  @override
  Future<void> resendOtp(VerifyOtp resendOtp) async {
    var url = '$baseUrl/verify-otp';
    var body =resendOtp.toJson();
    var response = await httpUtils.postData(url,body: body);
    print(response);
    return;
  }

  @override
  Future<void> verifyOtp(VerifyOtp verifyOtp) async {
    final url = '$baseUrl/verify-otp';
    final body = verifyOtp.toJson();
    try {
      final dynamic responseData = await httpUtils.postData(url, body: body);
      // Adapter la logique de traitement de la réponse pour verifyOtp
      if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
        print('OTP verification successful: ${responseData['message']}');
      } else {
        print('OTP verification successful with unknown response format: $responseData');
      }
      return;
    } on HttpRequestException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Erreur inattendue lors de la vérification OTP: $e');
    }
  }




//   @override
//   Future<ForgotPasswordResponse> forgotPassword(String email) async {
//     final url = '$baseUrl/forgot-password';
//     final body = {'email': email};
//     try {
//       final dynamic responseData = await httpUtils.postData(url, body: body);
//       if (responseData is Map<String, dynamic>) {
//         return ForgotPasswordResponse.fromJson(responseData);
//       } else {
//         throw Exception('Données de réponse inattendues pour mot de passe oublié: $responseData');
//       }
//     } on HttpRequestException catch (e) {
//       throw e;
//     } catch (e) {
//       throw Exception('Erreur inattendue lors de la demande de mot de passe oublié: $e');
//     }
//   }
//
//   @override
//   Future<ResetPasswordResponse> passwordReset(ResetPasswordRequest data) async {
//     final url = '$baseUrl/reset-password';
//     final body = data.toJson();
//     try {
//       final dynamic responseData = await httpUtils.postData(url, body: body);
//       if (responseData is Map<String, dynamic>) {
//         return ResetPasswordResponse.fromJson(responseData);
//       } else {
//         throw Exception('Données de réponse inattendues pour réinitialisation mot de passe: $responseData');
//       }
//     } on HttpRequestException catch (e) {
//       throw e;
//     } catch (e) {
//       throw Exception('Erreur inattendue lors de la réinitialisation du mot de passe: $e');
//     }
//   }
//
//   @override
//   Future<void> verifyEmail(int userId, String hashToken, {String? token}) async {
//     String url = '$baseUrl/verify-email/$userId/$hashToken';
//     if (token != null) {
//       url += '?token=$token';
//     }
//     try {
//       await httpUtils.postData(url, body: {}); // Envoyer un corps vide pour un POST sans données
//       return;
//     } on HttpRequestException catch (e) {
//       throw e;
//     } catch (e) {
//       throw Exception('Erreur inattendue lors de la vérification de l\'email: $e');
//     }
//   }
 }
GetIt getIt = GetIt.instance;

void main() async {
  // Initialisation nécessaire pour Flutter et les packages
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GetStorage.init();

  print('--- Démarrage du test de connexion ---');

  // 1. Configurer une instance de RemoteHttpUtils et l'enregistrer dans GetIt
  // Ceci simule ce que configureImplementations() ferait pour HttpUtils
  try {
    if (!getIt.isRegistered<HttpUtils>()) {
      var httpUtils = RemoteHttpUtils();
      getIt.registerLazySingleton<HttpUtils>(() => httpUtils);
      print('HttpUtils enregistré dans GetIt.');
    }
  } catch (e) {
    print('Erreur lors de l\'enregistrement de HttpUtils dans GetIt: $e');
    return; // Arrêter si l'initialisation échoue
  }

  // 2. Effectuer la requête CSRF initiale (comme dans main.dart)
  try {
    final HttpUtils httpUtils = getIt<HttpUtils>();
    final String baseUrl = dotenv.env['BASE_URL'] ?? '';
    print('Tentative de récupération du cookie CSRF depuis: $baseUrl/sanctum/csrf-cookie');
    await httpUtils.getData('$baseUrl/sanctum/csrf-cookie');
    print('SUCCÈS: Cookie CSRF Sanctum récupéré.');
  } catch (e) {
    print('ERREUR: Échec de la récupération du cookie CSRF Sanctum au démarrage: $e');
    print('La connexion pourrait échouer si le token CSRF n\'est pas obtenu.');
    // Vous pouvez choisir de sortir ici si le CSRF est critique et que l'API ne répond pas.
    // return;
  }

  // 3. Instancier UserNetworkServiceImpl (en utilisant l'instance HttpUtils de GetIt)
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final UserNetworkService userNetworkService = UserNetworkServiceImpl(
    baseUrl: baseUrl,
    httpUtils: getIt<HttpUtils>(), // Injection de l'instance HttpUtils
  );
  print('UserNetworkServiceImpl initialisé.');

  // 4. Définir les identifiants de test
  final String testEmail = 'line@example.com'; // Utilisez un email d'utilisateur existant
  final String testPassword = 'password'; // Utilisez le mot de passe de cet utilisateur

  final Authentication testAuth = Authentication(
    email: testEmail,
    password: testPassword,
  );

  // 5. Appeler la méthode de connexion
  print('Tentative de connexion avec l\'email: $testEmail');
  try {
    final user = await userNetworkService.seConnecter(testAuth);
    print('SUCCÈS: Connexion réussie !');
    print('Utilisateur connecté: ${user.name} (ID: ${user.id})');
    // Vous pouvez ajouter d'autres appels de test ici, par exemple :
    // await userNetworkService.recupererInfoUtilisateur();
  } catch (e) {
    print('ERREUR LORS DE LA CONNEXION: $e');
    if (e is HttpRequestException) {
      print('Statut Code: ${e.statusCode}');
      print('Message du serveur: ${e.message}');
      print('Corps de la réponse: ${e.body}');
    }
  }

  print('--- Fin du test de connexion ---');
}