class Experience {
  final int id;
  final String? position;
  final String? company;
  final DateTime? date_start;
  final DateTime? date_end;
  final String? description;

  Experience({
    required this.id,
    this.position,
    this.company,
    this.date_start,
    this.date_end,
    this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'],
      position: json['position'],
      company: json['company'],
      date_start: json['date_start'] != null ? DateTime.parse(json['date_start']) : null,
      date_end: json['date_end'] != null ? DateTime.parse(json['date_end']) : null,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
      'company': company,
      'date_start': date_start?.toIso8601String(),
      'date_end': date_end?.toIso8601String(),
      'description': description,
    };
  }
}
