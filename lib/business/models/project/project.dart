import 'package:odc_mobile_template/business/models/domain/domain.dart';
import 'package:odc_mobile_template/business/models/project/projectRoleSkill.dart';
import 'package:odc_mobile_template/business/models/project/status.dart';
import 'package:odc_mobile_template/business/models/user/user.dart';

class Project {
final int id;
final String title;
final String description;
final String? dateStart;
final String? dateEnd;
final String? budget;
final Status status;
final String location;
final String visibility;
final User createdBy;
final User updatedBy;
final String createdAt;
final String updatedAt;
final List<Domain> domains;
final List<ProjectRoleSkill> projectRolesSkills;

Project({
  required this.id,
  required this.title,
  required this.description,
  this.dateStart,
  this.dateEnd,
  this.budget,
  required this.location,
  required this.status,
  required this.visibility,
  required this.createdBy,
  required this.updatedBy,
  required this.createdAt,
  required this.updatedAt,
  required this.domains,
  required this.projectRolesSkills,
});

factory Project.fromJson(Map<String, dynamic> json) {
return Project(
id: json['id'],
title: json['title'] ?? '',
description: json['description'] ?? '',
dateStart: json['date_start']?.toString(),
dateEnd: json['date_end']?.toString(),
budget: json['budget'] != null ? json['budget'].toString() : null,
location: json['location'] ?? '',
visibility: json['visibility'] ?? '',
createdBy: User.fromJson(json['created_by']),
updatedBy: User.fromJson(json['updated_by']),
status: Status.fromJson(json['status']),
createdAt: json['created_at'] ?? '',
updatedAt: json['updated_at'] ?? '',
domains: (json['domains'] as List<dynamic>?)
    ?.map((e) => Domain.fromJson(e))
    .toList() ?? [],
projectRolesSkills: (json['project_roles_skills'] as List<dynamic>?)
    ?.map((e) => ProjectRoleSkill.fromJson(e))
    .toList() ?? [],
);
}
}