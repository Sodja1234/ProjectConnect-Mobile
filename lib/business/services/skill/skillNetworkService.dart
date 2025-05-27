import 'package:odc_mobile_template/business/models/skill/skill.dart';

abstract class SkillNetworkService{
  Future<List<Skill>> getSkill();
}