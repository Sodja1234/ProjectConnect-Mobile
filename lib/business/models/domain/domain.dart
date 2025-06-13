class Domain{
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Domain({
   required this.id,
     required this.name,
     this.createdAt,
    this.updatedAt,
});
  factory Domain.fromJson(Map<String, dynamic> json) {
    return Domain(
      id: json['id'],
      name: json['name']?.toString() ?? '',  // converti en String, vide si null
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map toJson() => {
    'id': id,
    'name': name,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };


}