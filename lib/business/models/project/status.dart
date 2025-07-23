class Status{
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Status({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });
  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'],
      name: json['name']?.toString() ?? '',
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


  factory Status.empty() {
    return Status(id: 0, name: '');
  }
}