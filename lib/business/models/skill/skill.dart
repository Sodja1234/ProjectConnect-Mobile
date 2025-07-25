class Skill{
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? experience_percentage;

  Skill({
    required this.id,
    required this.name,
     this.createdAt,
     this.updatedAt,
     this.experience_percentage,

});
  factory Skill.fromJson(Map<String, dynamic> json){
    return Skill(
      id: json['id'],
      name: json['name']?.toString() ?? '',  // converti en String, vide si null
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      experience_percentage: json['experience_percentage']?.toDouble() ?? 0.0
    );
  }
  Map toJson()=>{
    'id': id,
    'name': name,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'experience_percentage': experience_percentage
  };
}