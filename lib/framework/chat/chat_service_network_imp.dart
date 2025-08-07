// lib/framework/chat/chat_network_service_impl.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:odc_mobile_template/business/models/chat/chat.dart';
import 'package:odc_mobile_template/framework/utils/http/localHttpUtils.dart';

import '../../business/services/chat/chat_service_network.dart';
import '../../utils/http/HttpRequestException.dart';
import '../../utils/http/HttpUtils.dart';

class ChatNetworkServiceImpl extends ChatServiceNetwork {
  late final String baseUrl;
  late final HttpUtils httpUtils;

  ChatNetworkServiceImpl({required this.baseUrl, required this.httpUtils});

  @override
  Future<List<Chat>?> getUserChats(String token) async {
    try {
      var url = '$baseUrl/chats';
      var responseBody = await httpUtils.getData(url, token: token);

      var decodedData = jsonDecode(responseBody);

      if (decodedData is List) {
        return decodedData.map((chatJson) => Chat.fromJson(chatJson)).toList();
      } else {
        print('Erreur: La réponse de l\'API pour les chats n\'est pas un tableau.');
        return null;
      }
    } on SocketException catch (e) {
      print('Erreur de connexion réseau : $e');
      return null;
    } on HttpRequestException catch (e) {
      print('Erreur HTTP : Statut ${e.statusCode}, Message: ${e.message}');
      return null;
    } on FormatException catch (e) {
      print('Erreur de formatage JSON : La réponse de l\'API n\'est pas un JSON valide.');
      return null;
    } catch (e) {
      print('Exception inattendue : $e');
      return null;
    }
  }

  @override
  Future<Chat?> createChat({required String token, required List<int> userIds}) {
    // Cette méthode n'est pas encore implémentée pour l'instant
    throw UnimplementedError();
  }
}

void main() async {
  // Simuler un token pour les tests
  const String testToken = 'Bearer 14|VfSnuxyK5Y6PbtBRPBPvTV6zHjgFBDhAvNYYe9RM90f0f873';

  var httpUtilsInstance = LocalHttpUtils();

  var chatService = ChatNetworkServiceImpl(
    baseUrl: 'http://10.252.252.58:8000/api', // Vérifiez que l'adresse IP est correcte
    httpUtils: httpUtilsInstance,
  );

  print('Tentative de récupération des chats de l\'utilisateur...');
  List<Chat>? chats = await chatService.getUserChats(testToken);

  if (chats != null && chats.isNotEmpty) {
    print('Chats récupérés avec succès :');
    for (var chat in chats) {
      print('---');
      print('  ID du chat: ${chat.id}');
      print('  Type: ${chat.type}');
      print('  Nom (si groupe): ${chat.name ?? 'N/A'}');
      print('  Utilisateurs: ${chat.users.map((u) => u.name).join(', ')}');
      print('  Dernier message: ${chat.lastMessage?.message ?? 'Aucun message'}');
    }
    print('---');
  } else {
    print('Échec de la récupération des chats ou liste vide.');
  }
}