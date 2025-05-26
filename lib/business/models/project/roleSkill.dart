
class RoleSkill {
  String role;
  List<String> skill;
  String description;

  RoleSkill({
    required this.role,
    required this.skill,
    required this.description,
  });

  factory RoleSkill.fromJson(Map<String, dynamic> json) {
    return RoleSkill(
      role: json['role'],
      skill: List<String>.from(json['skill']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'skill': skill,
      'description': description,
    };
  }
}
