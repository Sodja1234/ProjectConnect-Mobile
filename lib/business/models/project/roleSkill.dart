class RoleSkill {
  String role;
  List<String> skills;
  String description;

  RoleSkill({
    required this.role,
    required this.skills,
    required this.description,
  });

  factory RoleSkill.fromJson(Map<String, dynamic> json) {
    return RoleSkill(
      role: json['role'],
      skills: List<String>.from(json['skills']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'role': role, 'skill': skills, 'description': description};
  }

  RoleSkill copyWith({String? role, List<String>? skills, String? description}) {
    return RoleSkill(
      role: role ?? this.role,
      skills: skills ?? this.skills,
      description: description ?? this.description,
    );
  }
}
