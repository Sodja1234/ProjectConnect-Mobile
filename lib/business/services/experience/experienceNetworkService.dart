import 'package:odc_mobile_template/business/models/experience/experience.dart';

abstract class ExperienceNetworkService{
  Future<List<Experience>> getExperiences(String token);
}