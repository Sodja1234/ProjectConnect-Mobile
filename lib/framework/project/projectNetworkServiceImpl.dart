import 'package:odc_mobile_template/business/models/project/createProject.dart';
import 'package:odc_mobile_template/business/models/project/roleSkill.dart';
import 'package:odc_mobile_template/framework/utils/http/localHttpUtils.dart';

import '../../business/services/project/projectNetworkService.dart';
import '../../utils/http/HttpUtils.dart';

class ProjectNetworkServiceImpl extends ProjectNetworkService{
  String baseUrl;
  HttpUtils httpUtils;

  ProjectNetworkServiceImpl({required this.baseUrl,required this.httpUtils});


  @override
  Future<bool?> createProject(CreateProject project, String token)async {
    try {
      var url = '$baseUrl/projects';
      var response = await httpUtils.postData(url,token: token, body: project.toJson());
      return true;
    }catch(e){
      print('Exception lors de la création du projet : $e');
      return false;
    }

  }
}

void main(){
  var roleSkillExample = RoleSkill(
    role: 'Développeur Flutter',
    skill: ['Dart', 'Flutter', 'REST API'],
    description: 'Développe et maintient l\'application mobile',
  );
  var service=ProjectNetworkServiceImpl(baseUrl: 'http://10.252.252.61:8000/api', httpUtils: LocalHttpUtils());
  var token="";
  var body=CreateProject(
    title: 'Application Mobile de Gestion 222222222 ',
    description: 'Une application pour gérer les projets et les tâches',
    dateStart: DateTime(2025, 6, 1),
    dateEnd: DateTime(2025, 12, 31),
    budget: 50000.0,
    location: 'Paris, France',
    visibility: 'public', // ou 'private'
    domains: ['Santé', 'Environnement'],
    roleSkills: [roleSkillExample],
  );;
  service.createProject(body, token);
}