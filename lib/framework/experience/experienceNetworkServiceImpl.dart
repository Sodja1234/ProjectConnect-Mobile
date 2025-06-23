import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odc_mobile_template/business/models/experience/experience.dart';
import 'package:odc_mobile_template/business/services/experience/experienceNetworkService.dart';
import 'package:odc_mobile_template/utils/http/HttpRequestException.dart';
import '../../utils/http/HttpUtils.dart';
import '../utils/http/localHttpUtils.dart';


class ExperienceNetworkServiceImpl implements ExperienceNetworkService {
  String baseUrl;
  HttpUtils httpUtils;

  ExperienceNetworkServiceImpl(
      {required this.baseUrl, required this.httpUtils});

  @override
  Future<List<Experience>> getExperiences(String token) async{
    var token = '3|la2y7ktTMtHkHQDBiao60w7nOQ4nxHoH007m4LjZ9961a779';
    try {
      var url = '$baseUrl/experiences';
      var response = await httpUtils.getData(url,token: token);

      try {
        var listData = jsonDecode(response);

        if (!listData.containsKey('data')) {
          throw FormatException('Clé "data" manquante dans la réponse JSON');
        }

        var dataList = listData['data'];

        if (dataList is! List) {
          throw FormatException('Le champ "data" n\'est pas une liste');
        }

        var listExperience = dataList
            .map<Experience>((e) => Experience.fromJson(e))
            .toList();

        return listExperience;

      } catch (jsonError, stackTrace) {
        print('Erreur lors du décodage JSON ou conversion : $jsonError');
        print(stackTrace);
        rethrow;
      }

    } catch (e, stackTrace) {
      print('Erreur lors de la récupération des données (réseau ou autre) : $e');
      print(stackTrace);
      rethrow;
    }
  }
}


void main() async {
  var token = '3|la2y7ktTMtHkHQDBiao60w7nOQ4nxHoH007m4LjZ9961a779';
  var service = ExperienceNetworkServiceImpl(
    baseUrl: 'http://10.252.252.8:8000/api',
    httpUtils: LocalHttpUtils(),

  );

  try {
    var experiences = await service.getExperiences(token);

    for (var element in experiences) {
      try {
        print(element.toJson());
      } catch (e) {
        print('Erreur lors de l\'affichage d\'une expérience : $e');
      }
    }

  } catch (e, stackTrace) {
    print('Erreur générale dans le main : $e');
    print(stackTrace);
  }
}

