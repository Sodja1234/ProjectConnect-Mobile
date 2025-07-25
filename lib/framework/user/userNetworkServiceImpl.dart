
import 'dart:convert';

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
   var url = '$baseUrl/register';
   print(url);
   var body = registerUser.toJson();
   var response = await httpUtils.postData(url,body: body);
   print(response);
   return;
  }

  @override
  Future<void> verifyOtp(VerifyOtp resendOtp) async {
    var url = '$baseUrl/verify-otp';
    var body =resendOtp.toJson();
    var response = await httpUtils.postData(url,body: body);
    print(response);
    return;
  }

  @override
  Future<void> resendOtp(VerifyOtp verifyOtp) async {
    var url = '$baseUrl/resend-otp';
    var body = verifyOtp.toJson();
    var response = await httpUtils.postData(url, body : body);
    print(response);
    print(url);
    return ;

  }




  }
void main() async {
  //test register
  var service = UserNetworkServiceImpl(
    baseUrl: "http://10.252.252.61:8000/api",
    httpUtils: LocalHttpUtils(),
  );
  try{
    var data=VerifyOtp(email:'email@gmail.com',otp: '170400');
    var r=await service.verifyOtp(data);
    print(data);

  }catch(e, s){
    print(e);
    print(s);
  }


}