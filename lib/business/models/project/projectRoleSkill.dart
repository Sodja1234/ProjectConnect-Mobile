import 'package:odc_mobile_template/business/models/role/role.dart';
import 'package:odc_mobile_template/business/models/skill/skill.dart';

class ProjectRoleSkill {
  final int id;
  final String description;
  final Role role;
  final List<Skill> skills;
  final int? candidacies_count;
  final int? invitations_count;

  ProjectRoleSkill({
    required this.id,
    required this.description,
    required this.role,
    required this.skills,
    this.candidacies_count,
    this.invitations_count
  });

  factory ProjectRoleSkill.fromJson(Map<String, dynamic> json) =>
      ProjectRoleSkill(
        id: json['id'],
        description: json['description'],
        role: Role.fromJson(json['role']),
        skills: (json['skills'] as List).map((e) => Skill.fromJson(e)).toList(),
        candidacies_count: json['candidacies_count'],
        invitations_count: json['invitations_count'],
      );

  Map toJson() => {
    'id': id,
    'description': description,
    'role': role.toJson(),
    'skills': skills.map((e) => e.toJson()).toList(),
    'candidacies_count': candidacies_count,
    'invitations_count': invitations_count,
  };
}

