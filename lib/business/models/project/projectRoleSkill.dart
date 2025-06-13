import 'package:odc_mobile_template/business/models/role/role.dart';
import 'package:odc_mobile_template/business/models/skill/skill.dart';

class ProjectRoleSkill {
  final int id;
  final String description;
  final Role role;
  final List<Skill> skills;

  ProjectRoleSkill({
    required this.id,
    required this.description,
    required this.role,
    required this.skills,
  });

  factory ProjectRoleSkill.fromJson(Map<String, dynamic> json) =>
      ProjectRoleSkill(
        id: json['id'],
        description: json['description'],
        role: Role.fromJson(json['role']),
        skills: (json['skills'] as List).map((e) => Skill.fromJson(e)).toList(),
      );
}

