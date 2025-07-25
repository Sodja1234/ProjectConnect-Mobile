import 'package:odc_mobile_template/business/models/domain/domain.dart';
import 'package:odc_mobile_template/business/models/project/projectRoleSkill.dart';
import 'package:odc_mobile_template/business/models/project/status.dart';
import 'package:odc_mobile_template/business/models/user/user.dart';

class Project {
  final int? id;
  final String title;
  final String description;
  final String slug;
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
     this.id,
    required this.title,
    required this.slug,
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
      slug: json['slug']??'',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dateStart: json['date_start']?.toString(),
      dateEnd: json['date_end']?.toString(),
      budget: json['budget'] != null ? json['budget'].toString() : null,
      location: json['location'] ?? '',
      visibility: json['visibility'] ?? '',
      createdBy: json['created_by'] != null ? User.fromJson(json['created_by']) : User.empty(),
      updatedBy: json['updated_by'] != null ? User.fromJson(json['updated_by']) : User.empty(),

      status: json['status'] != null ? Status.fromJson(json['status']) : Status.empty(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      domains:
          (json['domains'] as List<dynamic>?)
              ?.map((e) => Domain.fromJson(e))
              .toList() ??
          [],
      projectRolesSkills:
          (json['project_roles_skills'] as List<dynamic>?)
              ?.map((e) => ProjectRoleSkill.fromJson(e))
              .toList() ??
          [],
    );
  }
  factory Project.empty() {
    return Project(
      id: null,
      title: '',
      slug: '',
      description: '',
      dateStart: null,
      dateEnd: null,
      budget: null,
      location: '',
      visibility: '',
      status: Status.empty(),
      createdBy: User.empty(),
      updatedBy: User.empty(),
      createdAt: '',
      updatedAt: '',
      domains: [],
      projectRolesSkills: [],
    );
  }


  Map toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'description': description,
    'date_start': dateStart,
    'date_end': dateEnd,
    'budget': budget,
    'location': location,
    'visibility': visibility,
    'status': status.toJson(),
    'created_by': createdBy.toJson(),
    'updated_by': updatedBy.toJson(),
    'created_at': createdAt,
    'updated_at': updatedAt,
    'domains': domains.map((e) => e.toJson()).toList(),
     'project_roles_skills': projectRolesSkills.map((e) => e.toJson()).toList(),
  };
}
