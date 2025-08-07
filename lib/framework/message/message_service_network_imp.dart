// lib/framework/message/message_service_network_impl.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../utils/http/HttpRequestException.dart';
import '../../../utils/http/HttpUtils.dart';
import '../../business/models/message/message.dart';
import '../../business/services/message/message_service_network.dart';
import '../utils/http/localHttpUtils.dart';

class MessageNetworkServiceImpl extends MessageNetworkService {
  late final String baseUrl;
  late final HttpUtils httpUtils;

  MessageNetworkServiceImpl({required this.baseUrl, required this.httpUtils});

  @override
  Future<List<Message>?> getMessages(String token, int chatId) async {
    try {
      var url = '$baseUrl/chats/$chatId/messages';
      var responseBody = await httpUtils.getData(url, token: token);

      // Si la réponse est vide, ou une erreur de l'API qui n'est pas un JSON valide, on ne peut rien faire d'autre que retourner null.
      if (responseBody.isEmpty) {
        if (kDebugMode) {
          print('Erreur: Réponse vide de l\'API pour les messages.');
        }
        return null;
      }

      try {
        var decodedData = jsonDecode(responseBody);

        // On gère les deux formats de réponse attendus.
        if (decodedData is List<dynamic>) {
          // Cas 1 : La réponse est un tableau JSON direct
          List<Message> messages = decodedData
              .map((messageJson) => Message.fromJson(messageJson))
              .toList();
          return messages;
        } else if (decodedData is Map<String, dynamic> && decodedData['data'] != null) {
          // Cas 2 : La réponse est un objet avec une clé 'data'
          List<dynamic> messageDataList = decodedData['data'];
          List<Message> messages = messageDataList
              .map((messageJson) => Message.fromJson(messageJson))
              .toList();
          return messages;
        } else {
          // Cas d'un format JSON non attendu
          if (kDebugMode) {
            print('Erreur: La réponse JSON ne contient pas les données attendues.');
          }
          return null;
        }
      } on FormatException catch (e) {
        if (kDebugMode) {
          print('Erreur de formatage JSON : La réponse de l\'API n\'est pas un JSON valide. Corps de la réponse: $responseBody');
        }
        return null;
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('Erreur de connexion réseau lors de la récupération des messages : $e');
      }
      return null;
    } on HttpRequestException catch (e) {
      if (kDebugMode) {
        print('Erreur HTTP lors de la récupération des messages : Statut ${e.statusCode}, Message: ${e.message}');
      }
      return null;
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('Erreur client HTTP inattendue : $e');
      }
      return null;
    } catch (e, stack) {
      if (kDebugMode) {
        print('Exception inattendue lors de la récupération des messages : $e');
        print(stack);
      }
      return null;
    }
  }

  @override
  Future<bool> sendMessage({
    required String token,
    required String message,
    required int chatId,
  }) async {
    try {
      await httpUtils.postData(
        '$baseUrl/messages',
        token: token,
        body: {
          'chat_id': chatId,
          'message': message,
        },
      );
      return true;
    } on HttpRequestException catch (e) {
      if (kDebugMode) {
        print('Erreur HTTP lors de l\'envoi du message : Statut ${e.statusCode}, Message: ${e.message}');
      }
      return false;
    } catch (e, stack) {
      if (kDebugMode) {
        print('Erreur inattendue lors de l\'envoi du message : $e');
        print(stack);
      }
      return false;
    }
  }
}

// Le reste de votre fichier main() peut rester tel quel.
// Fonction main pour le test unitaire
void main() async {
  // Simuler un token pour les tests.
  const String testToken = 'Bearer 14|VfSnuxyK5Y6PbtBRPBPvTV6zHjgFBDhAvNYYe9RM90f0f873';

  // Utilisez un ID de chat valide.
  const int testChatId = 1;

  var httpUtilsInstance = LocalHttpUtils();

  var messageService = MessageNetworkServiceImpl(
    baseUrl: 'http://10.252.252.58:8000/api',
    httpUtils: httpUtilsInstance,
  );

  print('Tentative de récupération des messages pour le chat ID : $testChatId...');
  List<Message>? messages = await messageService.getMessages(testToken, testChatId);

  if (messages != null && messages.isNotEmpty) {
    print('Messages récupérés avec succès :');
    for (var message in messages) {
      print('---');
      print('  ID du message: ${message.id}');
      print('  Contenu: ${message.message}');
      print('  Envoyé par: ${message.sender?.name} (ID: ${message.sender?.id})');
      print('  Date: ${message.createdAt}');
    }
    print('---');
  } else {
    print('Échec de la récupération des messages ou liste de messages vide.');
  }

  // Exemple d'utilisation de la nouvelle méthode sendMessage
  print('\nTentative d\'envoi d\'un message au chat ID : $testChatId...');
  const String testMessage = 'Bonjour, c\'est un message de test !';
  bool messageSent = await messageService.sendMessage(
    token: testToken,
    chatId: testChatId,
    message: testMessage,
  );

  if (messageSent) {
    print('Message envoyé avec succès !');
  } else {
    print('Échec de l\'envoi du message.');
  }
}