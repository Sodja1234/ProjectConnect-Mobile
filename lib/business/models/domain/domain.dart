class Domain{
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Domain({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
});
  factory Domain.fromJson(Map<String, dynamic> json) {
    return Domain(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  Map toJson() => {
    'id': id,
    'name': name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };


}