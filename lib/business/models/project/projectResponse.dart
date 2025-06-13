import 'package:odc_mobile_template/business/models/project/project.dart';

class ProjectResponse {
  final List<Project> projects;
  final PaginationMeta meta;
  final PaginationLinks links;

  ProjectResponse({
    required this.projects,
    required this.meta,
    required this.links,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) => ProjectResponse(
    projects: (json['data'] as List).map((e) => Project.fromJson(e)).toList(),
    meta: PaginationMeta.fromJson(json['meta']),
    links: PaginationLinks.fromJson(json['links']),
  );
}

class PaginationMeta {
  final int currentPage;
  final int from;
  final int lastPage;
  final int perPage;
  final int to;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
    currentPage: json['current_page'],
    from: json['from'],
    lastPage: json['last_page'],
    perPage: json['per_page'],
    to: json['to'],
    total: json['total'],
  );
}

class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory PaginationLinks.fromJson(Map<String, dynamic> json) => PaginationLinks(
    first: json['first'],
    last: json['last'],
    prev: json['prev'],
    next: json['next'],
  );
}
