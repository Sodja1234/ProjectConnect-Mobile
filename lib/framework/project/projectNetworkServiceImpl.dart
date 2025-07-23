import 'dart:convert';

import 'package:odc_mobile_template/business/models/project/createProject.dart';
import 'package:odc_mobile_template/business/models/project/project.dart';
import 'package:odc_mobile_template/business/models/project/projectResponse.dart';
import 'package:odc_mobile_template/business/models/project/roleSkill.dart';
import 'package:odc_mobile_template/framework/utils/http/localHttpUtils.dart';

import '../../business/services/project/projectNetworkService.dart';
import '../../utils/http/HttpUtils.dart';

class ProjectNetworkServiceImpl extends ProjectNetworkService {
  String baseUrl;
  HttpUtils httpUtils;

  ProjectNetworkServiceImpl({required this.baseUrl, required this.httpUtils});


  @override
  Future<bool?> createProject(CreateProject project, String token) async {
    try {
      var url = '$baseUrl/projects';
      var response = await httpUtils.postData(
          url, token: token, body: project.toJson());
      return true;
    } catch (e) {
      print('Exception lors de la création du projet : $e');
      return false;
    }
  }

  @override
  Future<ProjectResponse?> getProjects({int page = 1, int perPage = 10, String? searchQuery}) async {
    try {
      var url = '$baseUrl/projects?page=$page&per_page=$perPage';
      var response = await httpUtils.getData(url);

      // Décodage de la chaîne JSON
      var data = jsonDecode(response);

      // Construction de l'objet ProjectResponse à partir du JSON
      print(data);
      return ProjectResponse.fromJson(data); // <-- le fix est ici
    } catch (e, stack) {
      print('Exception lors de la récupération des projets : $e');
      print(stack);
      return null;
    }
  }

  @override
  Future<Project?> getProject(String slug) async{
    try{
      var url = '$baseUrl/projects/$slug';
      var response = await httpUtils.getData(url);
      var data =jsonDecode(response);
      print(data);
      return Project.fromJson(data);

    }catch(e,stack){
      print('Exception lors de la récupération des projets : $e');
      print(stack);
      return null;

    }

  }


}
void main() async {

  var service=ProjectNetworkServiceImpl(baseUrl: 'http://10.252.252.54:8000/api', httpUtils: LocalHttpUtils());

 var project= service.getProject("plateforme-collaborative-pour-artistes-independants");
 project.then((value) => print(value));



}
