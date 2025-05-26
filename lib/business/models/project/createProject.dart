
import 'package:odc_mobile_template/business/models/project/roleSkill.dart';

class CreateProject {
  String title;
  String description;
  DateTime dateStart;
  DateTime dateEnd;
  double budget;
  String location;
  String visibility;
  List<String> domains;
  List<RoleSkill> roleSkills;

  CreateProject({
    required this.title,
    required this.description,
    required this.dateStart,
    required this.dateEnd,
    required this.budget,
    required this.location,
    required this.visibility,
    required this.domains,
    required this.roleSkills,
  });

  factory CreateProject.fromJson(Map<String, dynamic> json) {
    return CreateProject(
      title: json['title'],
      description: json['description'],
      dateStart: DateTime.parse(json['date_start']),
      dateEnd: DateTime.parse(json['date_end']),
      budget: (json['budget'] as num).toDouble(),
      location: json['location'],
      visibility: json['visibility'],
      domains: List<String>.from(json['domains']),
      roleSkills: (json['role_skills'] as List)
          .map((e) => RoleSkill.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date_start': dateStart.toIso8601String(),
      'date_end': dateEnd.toIso8601String(),
      'budget': budget,
      'location': location,
      'visibility': visibility,
      'domains': domains,
      'role_skills': roleSkills.map((e) => e.toJson()).toList(),
    };
  }


}
