import 'dart:convert';

import 'package:odc_mobile_template/business/models/skill/skill.dart';
import 'package:odc_mobile_template/business/services/skill/skillNetworkService.dart';

import '../../utils/http/HttpUtils.dart';
import '../utils/http/localHttpUtils.dart';

class SkillNetworkServiceImpl implements SkillNetworkService{

  String? baseUrl;
  HttpUtils? httpUtils;

  SkillNetworkServiceImpl({required this.baseUrl, required this.httpUtils});
  @override
  Future<List<Skill>> getSkill() async{

    var url = '$baseUrl/skills';
    var response = await httpUtils!.getData(url);
    var listData = jsonDecode(response);
    var listSkills = listData['data'];
    listSkills =listSkills.map<Skill>((e)=>Skill.fromJson(e)).toList();
    return listSkills;
  }



}

void main()async{
  var service = SkillNetworkServiceImpl(baseUrl: 'http://10.252.252.6:8000/api', httpUtils: LocalHttpUtils());
  var skills = await service.getSkill();
  skills.forEach((element) {
    print(element.toJson());
  });
}